#!/usr/bin/env bash
# Test both components together; the caller owns the disposable cluster.
SERVING_IMAGE=dev.local/multi-serving:ci
SIDECAR_IMAGE=dev.local/multi-sidecar:ci
SAMPLE_URL=${SAMPLE_URL:-http://127.0.0.1:18080}

main() (
  set -euo pipefail
  build
  deploy
  test
)

build() (
  set -euo pipefail
  docker build -t "$SERVING_IMAGE" servingcontainer
  docker build -t "$SIDECAR_IMAGE" sidecarcontainer
)

deploy() (
  set -euo pipefail
  kind load docker-image "$SERVING_IMAGE" "$SIDECAR_IMAGE" --name "${CLUSTER_NAME:-kind}"
  kubectl patch --local -f service.yaml --type=json -p "$(
    jq -cn --arg serving "$SERVING_IMAGE" --arg sidecar "$SIDECAR_IMAGE" '[
      {op: "replace", path: "/spec/template/spec/containers/0/image", value: $serving},
      {op: "add", path: "/spec/template/spec/containers/0/imagePullPolicy", value: "IfNotPresent"},
      {op: "replace", path: "/spec/template/spec/containers/1/image", value: $sidecar},
      {op: "add", path: "/spec/template/spec/containers/1/imagePullPolicy", value: "IfNotPresent"}
    ]'
  )" -o yaml | kubectl -n default apply -f -
  kubectl -n default wait -f service.yaml --for=condition=Ready --timeout=300s
)

test() (
  set -euo pipefail
  local service_url service_host body
  service_url=$(kubectl -n default get -f service.yaml -o jsonpath='{.status.url}')
  service_host=${service_url#*://}
  [[ "$service_host" =~ ^[a-zA-Z0-9.-]+$ ]]
  body=$(curl -fsS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/")
  [[ "$body" == 'Yay!! multi-container works' ]]
)
