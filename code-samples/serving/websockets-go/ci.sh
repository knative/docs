#!/usr/bin/env bash
# Source from this sample directory; the caller owns cluster setup and ingress forwarding.
IMAGE=dev.local/websockets-go:ci
CLIENT_IMAGE=dev.local/websocket-client:ci

main() (
  set -euo pipefail
  build
  deploy
  test
)

build() (
  set -euo pipefail
  docker build -t "$IMAGE" .
  docker build -t "$CLIENT_IMAGE" --build-arg APP_PATH=./cmd/client .
)

deploy() (
  set -euo pipefail
  kind load docker-image "$IMAGE" "$CLIENT_IMAGE" --name "${CLUSTER_NAME:-kind}"
  kubectl patch --local -f config/service.yaml --type=json -p "$(
    jq -cn --arg image "$IMAGE" '[
      {op: "replace", path: "/spec/template/spec/containers/0/image", value: $image},
      {op: "add", path: "/spec/template/spec/containers/0/imagePullPolicy", value: "IfNotPresent"}
    ]'
  )" -o yaml | kubectl -n default apply -f -
  kubectl -n default wait -f config/service.yaml --for=condition=Ready --timeout=300s
)

test() (
  set -euo pipefail
  local service_url service_host
  service_url=$(kubectl -n default get -f config/service.yaml -o jsonpath='{.status.url}')
  service_host=${service_url#*://}
  [[ "$service_host" =~ ^[a-zA-Z0-9.-]+$ ]]
  kubectl -n default run websocket-client --image="$CLIENT_IMAGE" \
    --image-pull-policy=IfNotPresent --restart=Never --command -- /app \
    --url ws://kourier.kourier-system.svc.cluster.local/ws --host "$service_host"
  kubectl -n default wait --for=jsonpath='{.status.phase}'=Succeeded \
    pod/websocket-client --timeout=120s
  kubectl -n default logs websocket-client
)
