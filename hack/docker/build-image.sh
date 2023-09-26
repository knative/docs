#!/usr/bin/env sh

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

set -x

docker buildx build --platform linux/arm64,linux/amd64 -t "ghcr.io/knative/knative-docs:latest" --push -f $SCRIPT_DIR/Dockerfile $SCRIPT_DIR/../..
