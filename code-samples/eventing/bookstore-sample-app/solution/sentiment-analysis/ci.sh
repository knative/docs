#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

main() (
  set -euo pipefail
  trap ci_cleanup EXIT
  local image=dev.local/bookstore-sentiment-analysis:ci body
  ci_function_build "$image"
  ci_deploy sentiment-analysis "$image"
  body=$(ci_event sentiment-analysis / '{"reviewText":"This book is wonderful","badWordResult":"good"}')
  jq -e '(.data // .) | .reviewText == "This book is wonderful" and .badWordResult == "good" and .sentimentResult == "positive"' <<< "$body"
  body=$(ci_event sentiment-analysis / '{"reviewText":"This book is terrible","badWordResult":"bad"}')
  jq -e '(.data // .) | .badWordResult == "bad" and .sentimentResult == "negative"' <<< "$body"
)
