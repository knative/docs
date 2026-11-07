#!/usr/bin/env bash
# Source from this sample directory; the caller owns cluster setup and ingress forwarding.
IMAGE=dev.local/helloworld-nodejs:ci
SAMPLE_URL=http://127.0.0.1:18080

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
  kind load docker-image "$IMAGE"
  kubectl patch --local -f service.yaml --type=json -p "$(
    jq -cn --arg image "$IMAGE" '[
      {op: "replace", path: "/spec/template/spec/containers/0/image", value: $image},
      {op: "add", path: "/spec/template/spec/containers/0/imagePullPolicy", value: "IfNotPresent"}
    ]'
  )" -o yaml | kubectl --namespace default apply -f -
  kubectl --namespace default wait -f service.yaml --for=condition=Ready --timeout=300s
)

test() (
  set -euo pipefail
  local service_url service_host
  service_url=$(kubectl --namespace default get -f service.yaml -o jsonpath='{.status.url}')
  service_host=${service_url#*://}
  [[ "$service_host" =~ ^[a-zA-Z0-9.-]+$ ]]
  local body
  body=$(curl -fsS --max-time 30 \
    -H "Host: $service_host" "$SAMPLE_URL/")
  [[ $body == 'Hello Node.js Sample v1!' ]]
)
