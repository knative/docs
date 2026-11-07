#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  kubectl -n default apply -f secret.yaml
  ci_hello dev.local/secrets-go:ci 'Secret file loaded.'
}
