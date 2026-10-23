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
        'Usage: ./hack/mkdocs.sh [serve|build|setup] [MkDocs options]' \
        '' \
        '  serve  Live preview at http://127.0.0.1:8000 (default)' \
        '  build  Build this checkout only into site/' \
        '  setup  Sync the local environment with uv.lock' \
        '' \
        'Examples:' \
        '  ./hack/mkdocs.sh serve --dev-addr 127.0.0.1:8001' \
        '  ./hack/mkdocs.sh serve --dirtyreload' \
        '  ./hack/mkdocs.sh build --strict' \
        '' \
        'Requires uv: https://docs.astral.sh/uv/getting-started/installation/' \
        'No manual Python setup, GitHub token, or Docker needed.'
}

COMMAND=${1:-serve}
if [ "$#" -gt 0 ]; then shift; fi
case "$COMMAND" in
    -h|--help|help) usage; exit 0 ;;
    serve|build|setup) ;;
    *) usage >&2; exit 2 ;;
esac

if ! command -v uv >/dev/null 2>&1; then
    printf '%s\n' 'Install uv: https://docs.astral.sh/uv/getting-started/installation/' >&2
    exit 1
fi

if [ "$COMMAND" = setup ]; then exec uv sync --locked; fi
if [ "$COMMAND" = serve ]; then
    exec uv run --locked mkdocs serve --livereload --config-file mkdocs.local.yml "$@"
fi
exec uv run --locked mkdocs build --config-file mkdocs.local.yml "$@"
