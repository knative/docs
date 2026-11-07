#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local image=dev.local/grpc-ping-go:ci host logs
  ci_docker_service "$image"
  host=$(ci_host grpc-ping)
  kubectl -n default run grpc-client --image="$image" --image-pull-policy=IfNotPresent \
    --restart=Never --command -- /client --insecure \
    --server_addr=kourier.kourier-system.svc.cluster.local:80 --server_host_override="$host"
  kubectl -n default wait --for=jsonpath='{.status.phase}'=Succeeded pod/grpc-client --timeout=180s
  logs=$(kubectl -n default logs grpc-client)
  grep -Fq 'Ping got hello - pong' <<< "$logs"
  [[ $(grep -c 'Got pong ' <<< "$logs") == 20 ]]
}
