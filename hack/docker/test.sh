#!/usr/bin/env sh

set -x

NAME=${1:-knative-docs-dev}
PORT=${2:-8000}
IMAGE=${3:-ghcr.io/knative/knative-docs:latest}

docker run --rm -v "${PWD}:/site" -it --entrypoint "" ${IMAGE} hack/build.sh
