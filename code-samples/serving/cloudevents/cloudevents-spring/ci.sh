#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local image=dev.local/cloudevents-spring:ci
  ci_maven_image "$image" 25 image.architecture
  ci_manifest service.yaml "$image"
  ci_event_response cloudevents-spring '{"message":"Spring smoke test"}' \
    '.message == "Spring smoke test"' \
    ce-type org.knative.examples.cloudevents.spring.Response
  ci_event_delivery cloudevents-spring '{"message":"Spring forwarded event"}' \
    '.body.message == "Spring forwarded event" and .headers["Ce-Type"] == ["org.knative.examples.cloudevents.spring.Response"]'
}
