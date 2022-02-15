#!/usr/bin/env sh

set -x

NAME=${1:-knative-docs-dev}
PORT=${2:-8000}
IMAGE=${3:-ghcr.io/knative/knative-docs:latest}

docker rm "${NAME}" --force 1> /dev/null 2> /dev/null

docker run --name "${NAME}" -d -p "${PORT}:8000" -v "${PWD}:/site" ${IMAGE} serve --dirtyreload --dev-addr=0.0.0.0:8000
echo "Dev environment running with live reloading enabled. Open http://localhost:${PORT} to see the site"
docker logs -f ${NAME}
