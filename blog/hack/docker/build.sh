#!/usr/bin/env sh

set -x

IMAGE=${1:-knative-docs-dev}

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
ROOT_DIR=$(cd "${SCRIPT_DIR}/../.."; pwd -P)

docker build -t ${IMAGE} -f ${SCRIPT_DIR}/Dockerfile ${ROOT_DIR}
