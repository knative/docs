#!/usr/bin/env bash
# Source from this sample directory; the caller owns cluster setup and ingress forwarding.
IMAGE=dev.local/grpc-ping-go:ci

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
  kubectl patch --local -f service.yaml --type=json -p "$(
    jq -cn --arg image "$IMAGE" '[
      {op: "replace", path: "/spec/template/spec/containers/0/image", value: $image},
      {op: "add", path: "/spec/template/spec/containers/0/imagePullPolicy", value: "IfNotPresent"}
    ]'
  )" -o yaml | kubectl -n default apply -f -
  kubectl -n default wait -f service.yaml --for=condition=Ready --timeout=300s
)

test() (
  set -euo pipefail
  local service_url service_host logs
  service_url=$(kubectl -n default get -f service.yaml -o jsonpath='{.status.url}')
  service_host=${service_url#*://}
  [[ "$service_host" =~ ^[a-zA-Z0-9.-]+$ ]]
  kubectl -n default run grpc-client --image="$IMAGE" --image-pull-policy=IfNotPresent \
    --restart=Never --command -- /client --insecure \
    --server_addr=kourier.kourier-system.svc.cluster.local:80 --server_host_override="$service_host"
  kubectl -n default wait --for=jsonpath='{.status.phase}'=Succeeded pod/grpc-client --timeout=180s
  logs=$(kubectl -n default logs grpc-client)
  grep -Fq 'Ping got hello - pong' <<< "$logs"
  [[ $(grep -c 'Got pong ' <<< "$logs") == 20 ]]
)
