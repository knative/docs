#!/usr/bin/env sh

set -x

NAME=${1:-knative-docs-dev}
PORT=${2:-8000}
IMAGE=${3:-knative-docs-dev}

docker run --name "${NAME}" -d -p "${PORT}:8000" -v "${PWD}:/site" ${IMAGE} serve --dirtyreload --dev-addr=0.0.0.0:8000
echo "Dev environment running with live reloading enabled. Open http://localhost:${PORT} to see the site"
echo "For live logs run:"
echo "docker logs -f ${NAME}"
