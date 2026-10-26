#!/usr/bin/env bash
# Source from this sample directory; main runs only when the caller invokes it.
IMAGE=dev.local/eventing-helloworld-python:ci

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
  kubectl apply -f https://github.com/knative/eventing/releases/latest/download/eventing-crds.yaml
  kubectl wait --for=condition=Established --timeout=120s \
    crd/brokers.eventing.knative.dev crd/triggers.eventing.knative.dev
  kubectl apply -f https://github.com/knative/eventing/releases/latest/download/eventing-core.yaml
  kubectl -n knative-eventing wait deployment --all --for=condition=Available --timeout=300s
  kubectl apply -f https://github.com/knative/eventing/releases/latest/download/in-memory-channel.yaml
  kubectl apply -f https://github.com/knative/eventing/releases/latest/download/mt-channel-broker.yaml
  kubectl -n knative-eventing wait deployment --all --for=condition=Available --timeout=300s

  kind load docker-image "$IMAGE" --name "${CLUSTER_NAME:-kind}"
  sed "s|docker.io/{username}/helloworld-python|$IMAGE|" sample-app.yaml | kubectl apply -f -
  kubectl -n knative-samples wait --for=condition=Ready --timeout=300s \
    ksvc/helloworld-python ksvc/event-display broker/default \
    trigger/helloworld-python trigger/event-display
)

test() (
  set -euo pipefail
  local broker_url status logs
  broker_url=$(kubectl -n knative-samples get broker default -o jsonpath='{.status.address.url}')
  kubectl -n knative-samples run curl --image=curlimages/curl --restart=Never --command -- sleep 300
  trap 'status=$?; kubectl -n knative-samples delete pod curl --ignore-not-found --wait=false || status=1; exit "$status"' EXIT
  kubectl -n knative-samples wait --for=condition=Ready pod/curl --timeout=120s
  status=$(kubectl -n knative-samples exec curl -- curl -fsS --max-time 30 \
    -o /dev/null -w '%{http_code}' "$broker_url" \
    -H 'Ce-Id: hello-python' -H 'Ce-Specversion: 1.0' \
    -H 'Ce-Type: dev.knative.samples.helloworld' \
    -H 'Ce-Source: dev.knative.samples/helloworldsource' \
    -H 'Content-Type: application/json' \
    -d '{"msg":"Hello World from the curl pod."}')
  [[ "$status" == 202 ]]

  for _attempt in {1..30}; do
    logs=$(kubectl -n knative-samples logs -l serving.knative.dev/service=event-display \
      -c user-container --tail=100 2>/dev/null || true)
    if grep -Fq 'specversion: 1.0' <<< "$logs" && \
       grep -Fq 'type: dev.knative.samples.hifromknative' <<< "$logs" && \
       grep -Fq 'source: knative/eventing/samples/hello-world' <<< "$logs" && \
       grep -Fq '"msg": "Hi from helloworld-python app!"' <<< "$logs"; then
      printf '%s\n' "$logs"
      return 0
    fi
    sleep 2
  done
  echo 'Timed out waiting for the CloudEvent reply at event-display' >&2
  return 1
)
