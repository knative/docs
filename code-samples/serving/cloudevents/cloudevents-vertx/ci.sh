#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local image=dev.local/cloudevents-vertx:ci
  ci_maven_image "$image" 21 jib.architecture
  ci_manifest service.yaml "$image"
  ci_event_response cloudevents-vertx '{"message":"Vert.x smoke test"}' \
    '.message == "Vert.x smoke test"' \
    ce-source https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-vertx
  ci_event_delivery cloudevents-vertx '{"message":"Vert.x forwarded event"}' \
    '.body.message == "Vert.x forwarded event" and .headers["Ce-Source"] == ["https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-vertx"]'
}
