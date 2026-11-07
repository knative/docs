#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  local image=dev.local/bookstore-bad-word-filter:ci
  ci_function_build "$image"
  ci_deploy bad-word-filter "$image"
  ci_event_check bad-word-filter / '{"reviewText":"This book is wonderful"}' \
    '(.data // .) | .reviewText == "This book is wonderful" and .badWordResult == "good"'
  ci_event_check bad-word-filter / '{"reviewText":"fuck this book"}' \
    '(.data // .) | .badWordResult == "bad"'
}
