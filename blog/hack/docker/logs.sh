#!/usr/bin/env sh

set -x

NAME=${1:-knative-docs-dev}
docker logs -f ${NAME}
