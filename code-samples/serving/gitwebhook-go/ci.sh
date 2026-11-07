#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local image=dev.local/gitwebhook-go:ci payload signature logs
  docker build -t "$image" .
  kubectl -n default create configmap ci-github-api --from-file="server.py=$CI_ROOT/hack/sample-ci/github-api.py"
  kubectl -n default run ci-github-api --image=python:3.14-slim --restart=Never \
    --overrides='{"spec":{"volumes":[{"name":"code","configMap":{"name":"ci-github-api"}}],"containers":[{"name":"ci-github-api","image":"python:3.14-slim","command":["python","/test/server.py"],"volumeMounts":[{"name":"code","mountPath":"/test"}]}]}}'
  kubectl -n default expose pod ci-github-api --port=8080
  kubectl -n default wait --for=condition=Ready pod/ci-github-api --timeout=120s
  kubectl -n default create secret generic githubsecret \
    --from-literal=personalAccessToken=ci-token --from-literal=webhookSecret=ci-secret
  ci_manifest service.yaml "$image"
  ci_env gitwebhook GITHUB_API_URL http://ci-github-api.default.svc.cluster.local:8080
  payload='{"action":"opened","number":1,"pull_request":{"title":"CI pull request"},"repository":{"name":"sample","owner":{"login":"ci"}}}'
  signature=$(printf '%s' "$payload" | python3 -c \
    'import hashlib,hmac,sys; print("sha1=" + hmac.new(b"ci-secret",sys.stdin.buffer.read(),hashlib.sha1).hexdigest())')
  ci_request gitwebhook / -H 'Content-Type: application/json' \
    -H 'X-GitHub-Event: pull_request' -H 'X-GitHub-Delivery: smoke-test' \
    -H "X-Hub-Signature: $signature" --data "$payload" -o /dev/null
  local found=false
  for _attempt in {1..30}; do
    logs=$(kubectl -n default logs ci-github-api)
    if jq -Rse 'split("\n") | map(fromjson?) | any(.[]; .path == "/repos/ci/sample/pulls/1" and .body.title == "CI pull request (looks pretty legit)")' <<< "$logs"; then
      found=true
      break
    fi
    sleep 2
  done
  [[ "$found" == true ]]
  local status
  status=$(ci_request gitwebhook / -H 'Content-Type: application/json' \
    -H 'X-GitHub-Event: pull_request' -H 'X-Hub-Signature: sha1=invalid' \
    --data "$payload" -o /dev/null -w '%{http_code}' || true)
  [[ "$status" == 4* ]]
}
