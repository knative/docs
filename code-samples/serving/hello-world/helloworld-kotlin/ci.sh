#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  ci_hello dev.local/helloworld-kotlin:ci 'Hello Kotlin Sample v1!'
}
