#!/usr/bin/env bash
# One integration test covers changes to either component and the shared manifest.
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local serving=dev.local/multi-serving:ci sidecar=dev.local/multi-sidecar:ci body
  docker build -t "$serving" servingcontainer
  docker build -t "$sidecar" sidecarcontainer
  ci_load "$serving"
  ci_load "$sidecar"
  kubectl patch --local -f service.yaml --type=json -p "$(
    jq -cn --arg serving "$serving" --arg sidecar "$sidecar" '[
      {op: "replace", path: "/spec/template/spec/containers/0/image", value: $serving},
      {op: "add", path: "/spec/template/spec/containers/0/imagePullPolicy", value: "IfNotPresent"},
      {op: "replace", path: "/spec/template/spec/containers/1/image", value: $sidecar},
      {op: "add", path: "/spec/template/spec/containers/1/imagePullPolicy", value: "IfNotPresent"}
    ]'
  )" -o yaml | kubectl -n default apply -f -
  kubectl -n default wait --for=condition=Ready ksvc/multi-container --timeout=300s
  body=$(ci_request multi-container /)
  [[ "$body" == 'Yay!! multi-container works' ]]
}
