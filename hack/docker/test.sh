#!/usr/bin/env sh

if [ -z $GITHUB_TOKEN ]; then
    echo "Please set a value for the GITHUB_TOKEN environmental variable"
    exit 1
fi

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
IMAGE=${1:-ghcr.io/knative/knative-docs:latest}

set -x

docker pull ${IMAGE}
docker run --rm -v "${SCRIPT_DIR}/../../:/site" -e GITHUB_TOKEN -it --entrypoint "" ${IMAGE} hack/build.sh
