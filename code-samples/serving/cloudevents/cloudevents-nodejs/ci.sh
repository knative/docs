#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  ci_docker_service dev.local/cloudevents-nodejs:ci
  ci_event_check service.yaml / '{"name":"Knative"}' \
    '(.data // .).message == "Hello, Knative"'
}
