#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/code-samples/ci/lib.sh"

main() (
  set -euo pipefail
  local image=dev.local/parallel-functions:ci path body
  docker build -t "$image" .
  ci_deploy parallel-functions "$image"
  ci_request parallel-functions /healthz -o /dev/null
  for path in filter/even switch/0; do
    body=$(ci_event parallel-functions "/$path" '{"message":"original"}' -H 'Ce-Time: 2026-01-01T00:00:00Z')
    jq -e '.message == "original"' <<< "$body"
    [[ -z $(ci_event parallel-functions "/$path" '{"message":"original"}' -H 'Ce-Time: 2026-01-01T00:01:00Z') ]]
  done
  for path in filter/odd switch/1; do
    body=$(ci_event parallel-functions "/$path" '{"message":"original"}' -H 'Ce-Time: 2026-01-01T00:01:00Z')
    jq -e '.message == "original"' <<< "$body"
    [[ -z $(ci_event parallel-functions "/$path" '{"message":"original"}' -H 'Ce-Time: 2026-01-01T00:00:00Z') ]]
  done
  body=$(ci_event parallel-functions /transform/even '{"message":"original"}')
  jq -e '.message == "we are even!"' <<< "$body"
  body=$(ci_event parallel-functions /transform/odd '{"message":"original"}')
  jq -e '.message == "this is odd!"' <<< "$body"
  local status
  status=$(ci_request parallel-functions /filter/even -H 'Content-Type: application/json' \
    --data '{}' -o /dev/null -w '%{http_code}' || true)
  [[ "$status" == 400 ]]
)
