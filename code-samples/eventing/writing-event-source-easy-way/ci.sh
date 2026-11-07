#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local image=dev.local/heartbeat-source:ci
  docker build -t "$image" .
  ci_load "$image"
  ci_sink
  # This is a producer, not an HTTP server: run it as a Deployment, not a KService.
  jq -n --arg image "$image" '{
    apiVersion: "apps/v1", kind: "Deployment", metadata: {name: "heartbeat-source"},
    spec: {selector: {matchLabels: {app: "heartbeat-source"}}, template: {
      metadata: {labels: {app: "heartbeat-source"}}, spec: {containers: [{
        name: "source", image: $image, imagePullPolicy: "IfNotPresent",
        env: [{name: "K_SINK", value: "http://ci-sink.default.svc.cluster.local"}]
      }]}}}
  }' | kubectl -n default apply -f -
  kubectl -n default rollout status deployment/heartbeat-source --timeout=120s
  ci_wait_json_log ci-sink '.headers["Ce-Type"] == ["heartbeat.example"] and .headers["Ce-Source"] == ["urn:event:from:heartbeat/example"] and (.body.hello | startswith("World # "))'
}
