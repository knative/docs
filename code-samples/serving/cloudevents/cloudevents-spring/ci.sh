#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

main() (
  set -euo pipefail
  local image=dev.local/cloudevents-spring:ci body headers
  ci_maven_image "$image" 25 image.architecture
  ci_manifest service.yaml "$image"
  headers=$(mktemp)
  trap 'rm -f "$headers"' EXIT
  body=$(ci_event cloudevents-spring / '{"message":"Spring smoke test"}' -D "$headers")
  jq -e '.message == "Spring smoke test"' <<< "$body"
  grep -iq '^ce-specversion: 1.0' "$headers"
  grep -iq '^ce-type: org.knative.examples.cloudevents.spring.Response' "$headers"
  ci_sink
  ci_env cloudevents-spring K_SINK http://ci-sink.default.svc.cluster.local
  ci_event cloudevents-spring / '{"message":"Spring forwarded event"}' -o /dev/null
  ci_wait_json_log ci-sink '.body.message == "Spring forwarded event" and .headers["Ce-Type"] == ["org.knative.examples.cloudevents.spring.Response"]'
)
