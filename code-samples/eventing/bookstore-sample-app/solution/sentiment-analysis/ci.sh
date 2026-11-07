#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local image=dev.local/bookstore-sentiment-analysis:ci
  ci_function_build "$image"
  ci_deploy sentiment-analysis "$image"
  ci_event_check sentiment-analysis / '{"reviewText":"This book is wonderful","badWordResult":"good"}' \
    '(.data // .) | .reviewText == "This book is wonderful" and .badWordResult == "good" and .sentimentResult == "positive"'
  ci_event_check sentiment-analysis / '{"reviewText":"This book is terrible","badWordResult":"bad"}' \
    '(.data // .) | .badWordResult == "bad" and .sentimentResult == "negative"'
}
