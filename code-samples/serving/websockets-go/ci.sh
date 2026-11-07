#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local image=dev.local/websockets-go:ci
  ci_docker_service "$image" config/service.yaml
  ci_websocket --url "${CI_URL/http:/ws:}/ws" --host "$(ci_host websockets-server)" \
    --echo 'Hello through Knative WebSockets'
}
