#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/hack/sample-ci/lib.sh"

sample_test() {
  ci_hello dev.local/helloworld-swift:ci '<html><meta charset="UTF-8"><body>Hello Swift</body></html>'
}
