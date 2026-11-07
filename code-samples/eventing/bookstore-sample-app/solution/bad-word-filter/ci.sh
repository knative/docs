#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/code-samples/ci/lib.sh"

main() (
  set -euo pipefail
  trap ci_cleanup EXIT
  local image=dev.local/bookstore-bad-word-filter:ci body
  ci_function_build "$image"
  ci_deploy bad-word-filter "$image"
  body=$(ci_event bad-word-filter / '{"reviewText":"This book is wonderful"}')
  jq -e '(.data // .) | .reviewText == "This book is wonderful" and .badWordResult == "good"' <<< "$body"
  body=$(ci_event bad-word-filter / '{"reviewText":"fuck this book"}')
  jq -e '(.data // .) | .badWordResult == "bad"' <<< "$body"
)
