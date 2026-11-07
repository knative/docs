#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  ci_bookstore_frontend dev.local/bookstore-start-frontend:ci
}
