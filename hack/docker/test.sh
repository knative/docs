#!/usr/bin/env sh

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
IMAGE=${1:-ghcr.io/knative/knative-docs:latest}

set -x

docker pull ${IMAGE}
docker run --rm -v "${SCRIPT_DIR}/../../:/site" -it --entrypoint "" ${IMAGE} hack/build.sh
