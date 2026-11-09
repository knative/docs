#!/usr/bin/env bash
# Source from this sample directory; the caller owns cluster setup and ingress forwarding.
IMAGE=dev.local/cloudevents-spring:ci
SINK_IMAGE=dev.local/cloudevents-sink:ci
SAMPLE_URL=${SAMPLE_URL:-http://127.0.0.1:18080}

main() (
  set -euo pipefail
  build
  deploy
  test
)

build() (
  set -euo pipefail
  local arch
  arch=$(docker info --format '{{.Architecture}}')
  case "$arch" in x86_64) arch=amd64 ;; aarch64) arch=arm64 ;; esac
  # Jib exports a tar; neither a host Maven installation nor a registry is needed.
  docker run --rm -v "$PWD:/workspace" -w /workspace maven:3-eclipse-temurin-25 \
    mvn -B compile jib:buildTar "-Dimage.architecture=$arch" "-Djib.to.image=$IMAGE"
  docker load -i target/jib-image.tar
  docker build -t "$SINK_IMAGE" "$(git rev-parse --show-toplevel)/code-samples/serving/cloudevents/cloudevents-go/eventing/logger"
)

deploy() (
  set -euo pipefail
  kind load docker-image "$IMAGE" "$SINK_IMAGE" --name "${CLUSTER_NAME:-kind}"
  kubectl patch --local -f service.yaml --type=json -p "$(
    jq -cn --arg image "$IMAGE" '[
      {op: "replace", path: "/spec/template/spec/containers/0/image", value: $image},
      {op: "add", path: "/spec/template/spec/containers/0/imagePullPolicy", value: "IfNotPresent"}
    ]'
  )" -o yaml | kubectl -n default apply -f -
  kubectl -n default wait -f service.yaml --for=condition=Ready --timeout=300s
)

test() (
  set -euo pipefail
  local service_url service_host headers response generation logs
  service_url=$(kubectl -n default get -f service.yaml -o jsonpath='{.status.url}')
  service_host=${service_url#*://}
  [[ "$service_host" =~ ^[a-zA-Z0-9.-]+$ ]]
  headers=$(mktemp)
  trap 'rm -f "$headers"' EXIT
  send_event() {
    local data=$1
    shift
    curl -fsS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/" \
      -H 'Content-Type: application/json' -H 'Ce-Specversion: 1.0' \
      -H 'Ce-Id: smoke-test' -H 'Ce-Type: dev.knative.samples.test' -H 'Ce-Source: /smoke-test' \
      --data "$data" "$@"
  }
  response=$(send_event '{"message":"Spring smoke test"}' -D "$headers")
  jq -e '.message == "Spring smoke test"' <<< "$response"
  grep -iq '^ce-specversion: 1.0' "$headers"
  grep -iq '^ce-type: org.knative.examples.cloudevents.spring.Response' "$headers"
  kubectl -n default create deployment cloudevents-sink --image="$SINK_IMAGE"
  kubectl -n default expose deployment cloudevents-sink --port=80 --target-port=8080
  kubectl -n default rollout status deployment/cloudevents-sink --timeout=120s
  kubectl -n default patch ksvc/cloudevents-spring --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/env","value":[{"name":"K_SINK","value":"http://cloudevents-sink.default.svc.cluster.local"}]}]'
  generation=$(kubectl -n default get ksvc/cloudevents-spring -o jsonpath='{.metadata.generation}')
  kubectl -n default wait --for=jsonpath='{.status.observedGeneration}'="$generation" ksvc/cloudevents-spring --timeout=300s
  kubectl -n default wait --for=condition=Ready ksvc/cloudevents-spring --timeout=300s
  send_event '{"message":"Spring forwarded event"}' -o /dev/null
  for _attempt in {1..30}; do
    logs=$(kubectl -n default logs deployment/cloudevents-sink --tail=200)
    if jq -Rse 'split("\n") | map(fromjson?) | any(.[]; .body.message == "Spring forwarded event" and .headers["Ce-Type"] == ["org.knative.examples.cloudevents.spring.Response"])' <<< "$logs"; then
      return 0
    fi
    sleep 2
  done
  printf 'Forwarded event not found:\n%s\n' "$logs" >&2
  return 1
)
