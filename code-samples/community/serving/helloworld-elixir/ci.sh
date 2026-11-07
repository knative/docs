#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  ci_docker_service dev.local/helloworld-elixir:ci
  local body
  body=$(ci_request service.yaml /)
  # The HTML contains the literal label $TARGET, not a shell variable.
  # shellcheck disable=SC2016
  [[ "$body" == *'<p>$TARGET = elixir Sample v1</p>'* ]]
}
