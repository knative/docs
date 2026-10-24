#!/bin/sh

# Copyright 2021 The Knative Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# uv manages Python and the locked environment; no activation needed.
set -eu

# Hide Material's MkDocs 2 banner without suppressing build diagnostics.
export NO_MKDOCS_2_WARNING=1

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

usage() {
    printf '%s\n' \
        'Usage: ./hack/mkdocs.sh [serve|build|setup] [--all-versions] [MkDocs options]' \
        '' \
        '  serve  Live working copy at http://127.0.0.1:8000/docs/ (default)' \
        '  build  Build into site/ (working copy by default)' \
        '  setup  Sync the local environment with uv.lock' \
        '' \
        '  --all-versions  Add cached releases; edit the working copy at /development/' \
        '' \
        'Examples:' \
        '  ./hack/mkdocs.sh --all-versions' \
        '  ./hack/mkdocs.sh serve --dev-addr 127.0.0.1:8001' \
        '  ./hack/mkdocs.sh serve --dirtyreload' \
        '  ./hack/mkdocs.sh build --strict' \
        '' \
        'Requires uv: https://docs.astral.sh/uv/getting-started/installation/' \
        'No manual Python setup, GitHub token, or Docker needed.'
}

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
case "${1:-}" in
    -h|--help|help) usage; exit 0 ;;
    serve|build|setup) COMMAND=$1; shift ;;
    ""|-*) ;; # MkDocs options without a subcommand default to live preview.
    *) usage >&2; exit 2 ;;
esac

if ! command -v uv >/dev/null 2>&1; then
    printf '%s\n' 'Install uv: https://docs.astral.sh/uv/getting-started/installation/' >&2
    exit 1
fi

if [ "$COMMAND" = setup ]; then exec uv sync --locked; fi
if [ "$COMMAND" = serve ]; then
    exec uv run --locked python -m watchdog.watchmedo auto-restart \
        --directory hack --patterns '*.py' --recursive --debug-force-polling \
        --debounce-interval 0.5 --no-restart-on-command-exit \
        -- python -m mkdocs serve --livereload --config-file "$CONFIG" "$@"
fi
exec uv run --locked mkdocs build --config-file "$CONFIG" "$@"
