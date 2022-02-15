#!/usr/bin/env sh

set -x

IMAGE=${1:-ghcr.io/knative/knative-docs:latest}

docker run --rm -v "${PWD}:/site" -it --entrypoint "" ${IMAGE} hack/build.sh
