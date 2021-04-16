#!/usr/bin/env bash

IMAGE=${1:-mkdocs}


SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
ROOT_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)


docker build -t ${IMAGE} ${SCRIPT_DIR}

