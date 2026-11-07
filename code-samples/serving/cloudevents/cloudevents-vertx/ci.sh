#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

main() (
  set -euo pipefail
  local image=dev.local/cloudevents-vertx:ci body headers
  ci_maven_image "$image" 21 jib.architecture
  ci_manifest service.yaml "$image"
  headers=$(mktemp)
  trap 'rm -f "$headers"' EXIT
  body=$(ci_event cloudevents-vertx / '{"message":"Vert.x smoke test"}' -D "$headers")
  jq -e '.message == "Vert.x smoke test"' <<< "$body"
  grep -iq '^ce-specversion: 1.0' "$headers"
  grep -iq '^ce-source: https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-vertx' "$headers"
  ci_sink
  ci_env cloudevents-vertx K_SINK http://ci-sink.default.svc.cluster.local
  ci_event cloudevents-vertx / '{"message":"Vert.x forwarded event"}' -o /dev/null
  ci_wait_json_log ci-sink '.body.message == "Vert.x forwarded event" and .headers["Ce-Source"] == ["https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-vertx"]'
)
