#!/usr/bin/env sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
IMAGE=${IMAGE:-knative-docs:local}
PORT=${PORT:-8000}
CONFIG=mkdocs.local.yml
for argument in "$@"; do
    shift
    if [ "$argument" = --all-versions ]; then
        CONFIG=mkdocs.versions.yml
    else
        set -- "$@" "$argument"
    fi
done
COMMAND=serve

usage() {
    printf '%s\n' \
        'Usage: ./hack/docker/run.sh [serve|build|release] [--all-versions] [options]' \
        '' \
        '  serve    Live working copy at http://127.0.0.1:8000/docs/ (default)' \
        '  build    Build into site/ (working copy by default)' \
        '  release  Assemble all published versions (requires GITHUB_TOKEN)' \
        '' \
        '  --all-versions  Add cached releases; edit the working copy at /development/' \
        '' \
        'Examples:' \
        '  ./hack/docker/run.sh --all-versions' \
        '  PORT=8001 ./hack/docker/run.sh' \
        '  ./hack/docker/run.sh serve --dirtyreload' \
        '  ./hack/docker/run.sh build --strict'
}

case "${1:-}" in
    -h|--help|help) usage; exit 0 ;;
    serve|build) COMMAND=$1; shift ;;
    release)
        COMMAND=release
        shift
        if [ -z "${GITHUB_TOKEN:-}" ]; then
            printf '%s\n' 'Set GITHUB_TOKEN before running a full release build.' >&2
            exit 1
        fi
        ;;
    ""|-*) ;; # MkDocs options without a subcommand default to live preview.
    *) usage >&2; exit 2 ;;
esac

# Build locally for the host architecture. Docker caches unchanged dependencies.
docker build -t "$IMAGE" -f "$ROOT/hack/docker/Dockerfile" "$ROOT"

case "$COMMAND" in
    serve)
        exec docker run --rm --init -p "127.0.0.1:${PORT}:8000" -v "$ROOT:/site" \
            --entrypoint python "$IMAGE" -m watchdog.watchmedo auto-restart \
            --directory hack --patterns '*.py' --recursive --debug-force-polling \
            --debounce-interval 0.5 --no-restart-on-command-exit \
            -- python -m mkdocs serve --livereload -f "$CONFIG" -a 0.0.0.0:8000 "$@"
        ;;
    build)
        exec docker run --rm --init -v "$ROOT:/site" \
            "$IMAGE" build -f "$CONFIG" "$@"
        ;;
    release)
        exec docker run --rm --init -v "$ROOT:/site" -e GITHUB_TOKEN \
            --entrypoint bash "$IMAGE" ./hack/build.sh "$@"
        ;;
esac
