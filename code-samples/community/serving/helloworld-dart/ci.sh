#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  ci_hello dev.local/helloworld-dart:ci 'Hello Dart Sample v1'
}
