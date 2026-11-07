#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  ci_hello dev.local/helloworld-java-spring:ci 'Hello Spring Boot Sample v1!'
}
