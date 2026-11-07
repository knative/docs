#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/code-samples/ci/lib.sh"

main() (
  set -euo pipefail
  trap ci_cleanup EXIT
  local image=dev.local/bookstore-solution-frontend:ci body
  docker build -t "$image" .
  ci_bookstore_deploy config/100-front-end-deployment.yaml "$image"
  kubectl -n default rollout status deployment/bookstore-frontend --timeout=300s
  ci_forward service/bookstore-frontend-svc 18081 80
  body=$(curl -fsS --max-time 30 http://127.0.0.1:18081/)
  grep -Fq 'Building serverless applications on Knative' <<< "$body"
  grep -Fq 'Comments' <<< "$body"
  curl -fsS --max-time 30 http://127.0.0.1:18081/images/knative-logo.png -o /dev/null
)
