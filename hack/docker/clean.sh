#!/usr/bin/env bash

NAME=${1:-mkdocs}

echo "Cleaning up old container '${NAME}'..."
docker rm "${NAME}" --force 1> /dev/null 2> /dev/null

echo "Finished clean up"
