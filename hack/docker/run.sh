#!/usr/bin/env bash

NAME=${1:-mkdocs}
PORT=${2:-8000}
IMAGE=${3:-mkdocs}

docker run --name "${NAME}" -d -p "${PORT}:${PORT}" -v "${PWD}:/site" mkdocs serve -f /site/mkdocs.yml --livereload -a "0.0.0.0:${PORT}"
echo "Dev environment running with live reloading enabled. Open http://localhost:${PORT} to see the site"
echo "For live logs use:" 
echo "docker logs -f ${NAME}"
