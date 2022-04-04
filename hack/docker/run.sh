#!/usr/bin/env sh

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
PORT=${2:-8000}
IMAGE=${3:-ghcr.io/knative/knative-docs:latest}

set -x

docker pull ${IMAGE}
docker run --rm -p "${PORT}:8000" -v "${SCRIPT_DIR}/../../:/site" ${IMAGE} serve --dirtyreload --dev-addr=0.0.0.0:8000

