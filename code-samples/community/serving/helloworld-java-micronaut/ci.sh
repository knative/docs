#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  ci_hello dev.local/helloworld-java-micronaut:ci 'Hello World: Micronaut Sample v1'
}
