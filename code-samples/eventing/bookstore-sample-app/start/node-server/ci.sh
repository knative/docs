#!/usr/bin/env bash
# Source from this directory; the workflow owns the disposable cluster.
source "$(git rev-parse --show-toplevel)/code-samples/ci/lib.sh"

main() (
  set -euo pipefail
  trap ci_cleanup EXIT
  local image=dev.local/bookstore-start-node:ci
  docker build -t "$image" .
  ci_bookstore_node "$image"
)
