#!/usr/bin/env sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PORT=${1:-8000}
IMAGE=${2:-ghcr.io/knative/knative-docs:latest}

# The published docs image is amd64; Docker Desktop can emulate it on ARM.
docker pull --platform linux/amd64 "$IMAGE"
docker run --rm --platform linux/amd64 \
  -p "127.0.0.1:${PORT}:8000" -v "${SCRIPT_DIR}/../../:/site" \
  --entrypoint mkdocs "$IMAGE" \
  serve --livereload --config-file mkdocs.local.yml --dev-addr=0.0.0.0:8000

