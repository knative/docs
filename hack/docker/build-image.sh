#!/usr/bin/env sh

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

set -x

docker build -t ghcr.io/knative/knative-docs:latest -f $SCRIPT_DIR/Dockerfile $SCRIPT_DIR/../..

