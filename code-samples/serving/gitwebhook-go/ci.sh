#!/usr/bin/env bash
# Source from this sample directory; the caller owns cluster setup and ingress forwarding.
IMAGE=dev.local/gitwebhook-go:ci
API_IMAGE=dev.local/github-api-fixture:ci
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
  docker build -t "$API_IMAGE" --build-arg APP_PATH=./testdata/github-api .
)

deploy() (
  set -euo pipefail
  kind load docker-image "$IMAGE" "$API_IMAGE" --name "${CLUSTER_NAME:-kind}"
  # Exercise the real webhook against a local API, never github.com.
  kubectl -n default run ci-github-api --image="$API_IMAGE" \
    --image-pull-policy=IfNotPresent --restart=Never
  kubectl -n default expose pod ci-github-api --port=8080
  kubectl -n default wait --for=condition=Ready pod/ci-github-api --timeout=120s
  kubectl -n default create secret generic githubsecret \
    --from-literal=personalAccessToken=ci-token --from-literal=webhookSecret=ci-secret
  kubectl patch --local -f service.yaml --type=json -p "$(
    jq -cn --arg image "$IMAGE" '[
      {op: "replace", path: "/spec/template/spec/containers/0/image", value: $image},
      {op: "add", path: "/spec/template/spec/containers/0/imagePullPolicy", value: "IfNotPresent"},
      {op: "add", path: "/spec/template/spec/containers/0/env/-", value: {name: "GITHUB_API_URL", value: "http://ci-github-api.default.svc.cluster.local:8080"}}
    ]'
  )" -o yaml | kubectl -n default apply -f -
  kubectl -n default wait -f service.yaml --for=condition=Ready --timeout=300s
)

test() (
  set -euo pipefail
  local service_url service_host payload expected_path signature logs status
  service_url=$(kubectl -n default get -f service.yaml -o jsonpath='{.status.url}')
  service_host=${service_url#*://}
  [[ "$service_host" =~ ^[a-zA-Z0-9.-]+$ ]]
  payload='{"action":"opened","number":1,"pull_request":{"title":"CI pull request"},"repository":{"name":"sample","owner":{"login":"ci"}}}'
  expected_path=$(jq -r '"/repos/\(.repository.owner.login)/\(.repository.name)/pulls/\(.number)"' <<< "$payload")
  signature=$(printf '%s' "$payload" | python3 -c \
    'import hashlib,hmac,sys; print("sha1=" + hmac.new(b"ci-secret",sys.stdin.buffer.read(),hashlib.sha1).hexdigest())')
  curl -fsS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/" \
    -H 'Content-Type: application/json' -H 'X-GitHub-Event: pull_request' \
    -H 'X-GitHub-Delivery: smoke-test' -H "X-Hub-Signature: $signature" --data "$payload" -o /dev/null
  local found=false
  for _attempt in {1..30}; do
    logs=$(kubectl -n default logs ci-github-api)
    if jq -Rse --arg path "$expected_path" '
      split("\n") | map(fromjson?) |
      any(.[]; .path == $path and .body.title == "CI pull request (looks pretty legit)")
    ' <<< "$logs"; then
      found=true
      break
    fi
    sleep 2
  done
  [[ "$found" == true ]]
  status=$(curl -sS --max-time 30 -H "Host: $service_host" "$SAMPLE_URL/" \
    -H 'Content-Type: application/json' -H 'X-GitHub-Event: pull_request' \
    -H 'X-Hub-Signature: sha1=invalid' --data "$payload" -o /dev/null -w '%{http_code}')
  [[ "$status" == 4* ]]
)
