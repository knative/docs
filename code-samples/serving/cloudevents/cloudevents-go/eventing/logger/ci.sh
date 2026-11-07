#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

main() (
  set -euo pipefail
  local image=dev.local/cloudevents-logger:ci status
  docker build -t "$image" .
  ci_deploy cloudevents-logger "$image"
  status=$(ci_event cloudevents-logger / '{"message":"logger smoke test"}' -o /dev/null -w '%{http_code}')
  [[ "$status" == 204 ]]
  ci_wait_json_log cloudevents-logger '.body.message == "logger smoke test" and .headers["Ce-Id"] == ["smoke-test"]'
  status=$(ci_event cloudevents-logger /fail '{"message":"failed delivery"}' \
    -o /dev/null -w '%{http_code}' || true)
  [[ "$status" == 503 ]]
  ci_wait_json_log cloudevents-logger '.body.message == "failed delivery"'
)
