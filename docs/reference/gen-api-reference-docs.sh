#!/usr/bin/env bash
#
# This script is for generating API reference docs for Knative components.

# Copyright 2018 Knative authors
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
set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

REFDOCS_PKG="github.com/ahmetb/gen-crd-api-reference-docs"
REFDOCS_REPO="https://${REFDOCS_PKG}.git"
REFDOCS_VER="5c208a6"

KNATIVE_SERVING_REPO="github.com/knative/serving"
KNATIVE_SERVING_COMMIT="v0.2.3"
KNATIVE_SERVING_OUT_FILE="reference/serving.md"

KNATIVE_BUILD_REPO="github.com/knative/build"
KNATIVE_BUILD_COMMIT="v0.2.0"
KNATIVE_BUILD_OUT_FILE="reference/build.md"

KNATIVE_EVENTING_REPO="github.com/knative/eventing"
KNATIVE_EVENTING_COMMIT="v0.2.1"
KNATIVE_EVENTING_OUT_FILE="reference/eventing/eventing.md"

KNATIVE_EVENTING_SOURCES_REPO="github.com/knative/eventing-sources"
KNATIVE_EVENTING_SOURCES_COMMIT="v0.2.1"
KNATIVE_EVENTING_SOURCES_OUT_FILE="reference/eventing/eventing-sources.md"

log() {
    echo "$@" >&2
}

fail() {
    log "error: $*"
    exit 1
}

install_go_bin() {
    local pkg
    pkg="$1"
    (
        cd "$(mktemp -d)"
        go mod init tmp
        go get -u "$pkg"
        # will be downloaded to "$(go env GOPATH)/bin/$(basename $pkg)"
    )
}

repo_tarball_url() {
    local repo commit
    repo="$1"
    commit="$2"
    echo "https://$repo/archive/$commit.tar.gz"
}

dl_and_extract() {
    # TODO(ahmetb) remove this function. no longer dl'ing tarballs since they
    # won't have a .git dir to infer the commit ID from to be used by refdocs.
    local url dest
    url="$1"
    dest="$2"
    mkdir -p "${dest}"
    curl -sSLf "$url" | tar zxf - --directory="$dest"  --strip 1
}

clone_at_commit() {
    local repo commit dest
    repo="$1"
    commit="$2"
    dest="$3"
    mkdir -p "${dest}"
    git clone "${repo}" "${dest}"
    git --git-dir="${dest}/.git" --work-tree="${dest}" checkout --detach --quiet "${commit}"
}

gen_refdocs() {
    local refdocs_bin gopath out_file repo_root
    refdocs_bin="$1"
    gopath="$2"
    out_file="$3"
    repo_root="$4"

    (
        cd "${repo_root}"
        env GOPATH="${gopath}" "${refdocs_bin}" \
            -out-file "${gopath}/out/${out_file}" \
            -api-dir "./pkg/apis" \
            -config "${SCRIPTDIR}/knative-refdocs-gen-config.json"
    )
}


main() {
    if [[ -n "${GOPATH:-}" ]]; then
        fail "GOPATH should not be set."
    fi
    if ! command -v "go" 1>/dev/null ; then
        fail "\"go\" is not in PATH"
    fi

    # install and place the refdocs tool
    local refdocs_bin refdocs_bin_expected refdocs_dir
    refdocs_dir="$(mktemp -d)"
    refdocs_bin="${refdocs_dir}/refdocs"
    # clone repo for ./templates
    git clone --quiet --depth=1 "${REFDOCS_REPO}" "${refdocs_dir}"
    # install bin
    install_go_bin "${REFDOCS_PKG}@${REFDOCS_VER}"
    # move bin to final location
    refdocs_bin_expected="$(go env GOPATH)/bin/$(basename ${REFDOCS_PKG})"
    mv "${refdocs_bin_expected}" "${refdocs_bin}"
    [[ ! -f "${refdocs_bin}" ]] && fail "refdocs failed to install"

    local clone_root
    clone_root="$(mktemp -d)"

    local knative_serving_root
    knative_serving_root="${clone_root}/src/${KNATIVE_SERVING_REPO}"
    clone_at_commit "https://${KNATIVE_SERVING_REPO}.git" "${KNATIVE_SERVING_COMMIT}" \
        "${knative_serving_root}"
    gen_refdocs "${refdocs_bin}" "${clone_root}" "${KNATIVE_SERVING_OUT_FILE}" \
        "${knative_serving_root}"

    local knative_build_root
    knative_build_root="${clone_root}/src/${KNATIVE_BUILD_REPO}"
    clone_at_commit "https://${KNATIVE_BUILD_REPO}.git" "${KNATIVE_BUILD_COMMIT}" \
        "${knative_build_root}"
    gen_refdocs "${refdocs_bin}" "${clone_root}" "${KNATIVE_BUILD_OUT_FILE}" \
        "${knative_build_root}"

    local knative_eventing_root
    knative_eventing_root="${clone_root}/src/${KNATIVE_EVENTING_REPO}"
    clone_at_commit "https://${KNATIVE_EVENTING_REPO}.git" "${KNATIVE_EVENTING_COMMIT}" \
        "${knative_eventing_root}"
    gen_refdocs "${refdocs_bin}" "${clone_root}" "${KNATIVE_EVENTING_OUT_FILE}" \
        "${knative_eventing_root}"

    local knative_eventing_sources_root
    knative_eventing_sources_root="${clone_root}/src/${KNATIVE_EVENTING_SOURCES_REPO}"
    clone_at_commit "https://${KNATIVE_EVENTING_SOURCES_REPO}.git" "${KNATIVE_EVENTING_SOURCES_COMMIT}" \
        "${knative_eventing_sources_root}"
    gen_refdocs "${refdocs_bin}" "${clone_root}" "${KNATIVE_EVENTING_SOURCES_OUT_FILE}" \
        "${knative_eventing_sources_root}"

    log "Generated files written to ${clone_root}/out/."
    if command -v open >/dev/null; then
        open "${clone_root}/out/"
    fi
}

main "$@"
