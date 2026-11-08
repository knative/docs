#!/usr/bin/env bash
# Source from this sample directory; the caller owns cluster setup and ingress forwarding.
IMAGE=dev.local/cloudevents-logger:ci
SAMPLE_URL=${SAMPLE_URL:-http://127.0.0.1:18080}

main() (
  set -euo pipefail
  build
  deploy
  test
)

build() (
  set -euo pipefail
  docker build -t "$IMAGE" .
)

deploy() (
  set -euo pipefail
  kind load docker-image "$IMAGE" --name "${CLUSTER_NAME:-kind}"
  jq -n --arg image "$IMAGE" '{
    apiVersion: "serving.knative.dev/v1", kind: "Service",
    metadata: {name: "cloudevents-logger", namespace: "default"},
    spec: {template: {spec: {containers: [{image: $image, imagePullPolicy: "IfNotPresent"}]}}}
  }' | kubectl apply -f -
  kubectl -n default wait --for=condition=Ready ksvc/cloudevents-logger --timeout=300s
)

test() (
  set -euo pipefail
  local service_url service_host status logs
  service_url=$(kubectl -n default get ksvc/cloudevents-logger -o jsonpath='{.status.url}')
  service_host=${service_url#*://}
  [[ "$service_host" =~ ^[a-zA-Z0-9.-]+$ ]]
  status=$(curl -fsS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/" \
    -H 'Content-Type: application/json' -H 'Ce-Specversion: 1.0' \
    -H 'Ce-Id: smoke-test' -H 'Ce-Type: dev.knative.samples.test' -H 'Ce-Source: /smoke-test' \
    --data '{"message":"logger smoke test"}' -o /dev/null -w '%{http_code}')
  [[ "$status" == 204 ]]
  logs=$(kubectl -n default logs -l serving.knative.dev/service=cloudevents-logger -c user-container --tail=100)
  jq -Rse 'split("\n") | map(fromjson?) | any(.[]; .body.message == "logger smoke test" and .headers["Ce-Id"] == ["smoke-test"])' <<< "$logs"
  status=$(curl -sS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/fail" \
    -H 'Content-Type: application/json' --data '{"message":"failed delivery"}' \
    -o /dev/null -w '%{http_code}')
  [[ "$status" == 503 ]]
  logs=$(kubectl -n default logs -l serving.knative.dev/service=cloudevents-logger -c user-container --tail=100)
  jq -Rse 'split("\n") | map(fromjson?) | any(.[]; .body.message == "failed delivery")' <<< "$logs"
)
