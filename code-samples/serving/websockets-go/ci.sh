#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

main() (
  set -euo pipefail
  trap ci_cleanup EXIT
  local image=dev.local/websockets-go:ci
  docker build -t "$image" .
  ci_manifest config/service.yaml "$image"
  ci_websocket --url "${CI_URL/http:/ws:}/ws" --host "$(ci_host websockets-server)" \
    --echo 'Hello through Knative WebSockets'
)
