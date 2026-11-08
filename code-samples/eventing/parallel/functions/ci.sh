#!/usr/bin/env bash
# Source from this sample directory; the caller owns cluster setup and ingress forwarding.
IMAGE=dev.local/parallel-functions:ci
SAMPLE_URL=${SAMPLE_URL:-http://127.0.0.1:18080}

main() (
  set -euo pipefail
  build
  deploy
  test
)

build() (
  set -euo pipefail
  docker build -t "$IMAGE" .
)

deploy() (
  set -euo pipefail
  kind load docker-image "$IMAGE" --name "${CLUSTER_NAME:-kind}"
  jq -n --arg image "$IMAGE" '{
    apiVersion: "serving.knative.dev/v1", kind: "Service",
    metadata: {name: "parallel-functions", namespace: "default"},
    spec: {template: {spec: {containers: [{image: $image, imagePullPolicy: "IfNotPresent"}]}}}
  }' | kubectl apply -f -
  kubectl -n default wait --for=condition=Ready ksvc/parallel-functions --timeout=300s
)

test() (
  set -euo pipefail
  local service_url service_host path matching_minute skipped_minute body status
  service_url=$(kubectl -n default get ksvc/parallel-functions -o jsonpath='{.status.url}')
  service_host=${service_url#*://}
  [[ "$service_host" =~ ^[a-zA-Z0-9.-]+$ ]]
  curl -fsS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/healthz" -o /dev/null
  send_event() {
    local path=$1
    shift
    curl -fsS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/$path" \
      -H 'Content-Type: application/json' -H 'Ce-Specversion: 1.0' \
      -H 'Ce-Id: smoke-test' -H 'Ce-Type: dev.knative.samples.test' -H 'Ce-Source: /smoke-test' \
      --data '{"message":"original"}' "$@"
  }
  while read -r path matching_minute skipped_minute; do
    body=$(send_event "$path" -H "Ce-Time: 2026-01-01T00:${matching_minute}:00Z")
    jq -e '.message == "original"' <<< "$body"
    [[ -z $(send_event "$path" -H "Ce-Time: 2026-01-01T00:${skipped_minute}:00Z") ]]
  done <<'CASES'
filter/even 00 01
switch/0 00 01
filter/odd 01 00
switch/1 01 00
CASES
  body=$(send_event transform/even)
  jq -e '.message == "we are even!"' <<< "$body"
  body=$(send_event transform/odd)
  jq -e '.message == "this is odd!"' <<< "$body"
  status=$(curl -sS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/filter/even" \
    -H 'Content-Type: application/json' --data '{}' -o /dev/null -w '%{http_code}')
  [[ "$status" == 400 ]]
)
