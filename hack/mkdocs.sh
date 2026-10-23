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

# Use an isolated Python environment; no activation or global pip install needed.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

usage() {
    printf '%s\n' \
        'Usage: ./hack/mkdocs.sh [serve|build|setup] [MkDocs options]' \
        '' \
        '  serve  Live preview at http://127.0.0.1:8000 (default)' \
        '  build  Build this checkout only into site/' \
        '  setup  Install or refresh the local Python environment' \
        '' \
        'Examples:' \
        '  ./hack/mkdocs.sh serve --dev-addr 127.0.0.1:8001' \
        '  ./hack/mkdocs.sh serve --dirtyreload' \
        '  ./hack/mkdocs.sh build --strict' \
        '' \
        'Requires Python 3 with venv and pip. No GitHub token or Docker needed.'
}

COMMAND=${1:-serve}
if [ "$#" -gt 0 ]; then shift; fi
case "$COMMAND" in
    -h|--help|help) usage; exit 0 ;;
    serve|build|setup) ;;
    *) usage >&2; exit 2 ;;
esac

if [ ! -x .venv/bin/python ]; then
    "${PYTHON:-python3}" -m venv .venv
fi
if [ "$COMMAND" = setup ] || ! cmp -s requirements.txt .venv/.docs-requirements.txt; then
    # Existing environments created by tools such as uv may not include pip.
    if ! .venv/bin/python -m pip --version >/dev/null 2>&1; then
        .venv/bin/python -m ensurepip --upgrade
    fi
    .venv/bin/python -m pip install -r requirements.txt
    cp requirements.txt .venv/.docs-requirements.txt
fi

if [ "$COMMAND" = setup ]; then exit 0; fi
if [ "$COMMAND" = serve ]; then
    exec .venv/bin/python -m mkdocs serve --livereload --config-file mkdocs.local.yml "$@"
fi
exec .venv/bin/python -m mkdocs build --config-file mkdocs.local.yml "$@"
