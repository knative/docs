#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
IMAGE=${IMAGE:-knative-docs:local}
PORT=${PORT:-8000}
COMMAND=${1:-serve}
if [ "$#" -gt 0 ]; then shift; fi

usage() {
    printf '%s\n' \
        'Usage: ./hack/docker/run.sh [serve|build|release] [options]' \
        '' \
        '  serve    Live preview at http://127.0.0.1:8000/docs/ (default)' \
        '  build    Build this checkout only into site/' \
        '  release  Assemble all published versions (requires GITHUB_TOKEN)' \
        '' \
        'Examples:' \
        '  PORT=8001 ./hack/docker/run.sh' \
        '  ./hack/docker/run.sh serve --dirtyreload' \
        '  ./hack/docker/run.sh build --strict'
}

case "$COMMAND" in
    -h|--help|help) usage; exit 0 ;;
    serve|build) ;;
    release)
        if [ -z "${GITHUB_TOKEN:-}" ]; then
            printf '%s\n' 'Set GITHUB_TOKEN before running a full release build.' >&2
            exit 1
        fi
        ;;
    *) usage >&2; exit 2 ;;
esac

# Build locally for the host architecture. Docker caches unchanged dependencies.
docker build -t "$IMAGE" -f "$ROOT/hack/docker/Dockerfile" "$ROOT"

case "$COMMAND" in
    serve)
        exec docker run --rm --init -p "127.0.0.1:${PORT}:8000" -v "$ROOT:/site" \
            "$IMAGE" serve --livereload -f mkdocs.local.yml -a 0.0.0.0:8000 "$@"
        ;;
    build)
        exec docker run --rm --init -v "$ROOT:/site" \
            "$IMAGE" build -f mkdocs.local.yml "$@"
        ;;
    release)
        exec docker run --rm --init -v "$ROOT:/site" -e GITHUB_TOKEN \
            --entrypoint bash "$IMAGE" ./hack/build.sh "$@"
        ;;
esac
