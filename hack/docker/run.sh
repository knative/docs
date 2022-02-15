#!/usr/bin/env sh

set -x

PORT=${2:-8000}
IMAGE=${3:-ghcr.io/knative/knative-docs:latest}

docker run --rm -p "${PORT}:8000" -v "${PWD}:/site" ${IMAGE} serve --dirtyreload --dev-addr=0.0.0.0:8000

