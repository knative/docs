#!/usr/bin/env bash
# Source from this sample directory; the caller owns the disposable cluster.
IMAGE=dev.local/heartbeat-source:ci
SINK_IMAGE=dev.local/heartbeat-sink:ci

main() (
  set -euo pipefail
  build
  deploy
  test
)

build() (
  set -euo pipefail
  docker build -t "$IMAGE" .
  # Reuse the existing capture-logger sample as an HTTP sink, not a new sample.
  docker build -t "$SINK_IMAGE" "$(git rev-parse --show-toplevel)/code-samples/serving/cloudevents/cloudevents-go/eventing/logger"
)

deploy() (
  set -euo pipefail
  kind load docker-image "$IMAGE" "$SINK_IMAGE" --name "${CLUSTER_NAME:-kind}"
  kubectl -n default create deployment heartbeat-sink --image="$SINK_IMAGE"
  kubectl -n default expose deployment heartbeat-sink --port=80 --target-port=8080
  kubectl -n default rollout status deployment/heartbeat-sink --timeout=120s
  # The producer has no HTTP listener, so it runs as a Deployment, not a KService.
  jq -n --arg image "$IMAGE" '{
    apiVersion: "apps/v1", kind: "Deployment", metadata: {name: "heartbeat-source"},
    spec: {selector: {matchLabels: {app: "heartbeat-source"}}, template: {
      metadata: {labels: {app: "heartbeat-source"}}, spec: {containers: [{
        name: "source", image: $image, imagePullPolicy: "IfNotPresent",
        env: [{name: "K_SINK", value: "http://heartbeat-sink.default.svc.cluster.local"}]
      }]}}}
  }' | kubectl -n default apply -f -
  kubectl -n default rollout status deployment/heartbeat-source --timeout=120s
)

test() (
  set -euo pipefail
  local logs
  for _attempt in {1..30}; do
    logs=$(kubectl -n default logs deployment/heartbeat-sink --tail=200)
    if jq -Rse 'split("\n") | map(fromjson?) | any(.[]; .headers["Ce-Type"] == ["heartbeat.example"] and .headers["Ce-Source"] == ["urn:event:from:heartbeat/example"] and (.body.hello | startswith("World # ")))' <<< "$logs"; then
      return 0
    fi
    sleep 2
  done
  printf 'Timed out waiting for heartbeat events:\n%s\n' "$logs" >&2
  return 1
)
