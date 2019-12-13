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
REFDOCS_VER="v0.1.5"

KNATIVE_SERVING_REPO="github.com/knative/serving"
KNATIVE_SERVING_IMPORT_PATH="knative.dev/serving"
KNATIVE_SERVING_COMMIT="${KNATIVE_SERVING_COMMIT:?specify the \$KNATIVE_SERVING_COMMIT variable}"
KNATIVE_SERVING_OUT_FILE="serving.md"

KNATIVE_EVENTING_REPO="github.com/knative/eventing"
KNATIVE_EVENTING_IMPORT_PATH="knative.dev/eventing"
KNATIVE_EVENTING_COMMIT="${KNATIVE_EVENTING_COMMIT:?specify the \$KNATIVE_EVENTING_COMMIT variable}"
KNATIVE_EVENTING_OUT_FILE="eventing/eventing.md"

KNATIVE_EVENTING_CONTRIB_REPO="github.com/knative/eventing-contrib"
KNATIVE_EVENTING_CONTRIB_IMPORT_PATH="knative.dev/eventing-contrib"
KNATIVE_EVENTING_CONTRIB_COMMIT="${KNATIVE_EVENTING_CONTRIB_COMMIT:?specify the \$KNATIVE_EVENTING_CONTRIB_COMMIT variable}"
KNATIVE_EVENTING_CONTRIB_OUT_FILE="eventing/eventing-contrib.md"

cleanup_refdocs_root=
cleanup_repo_clone_root=
trap cleanup EXIT

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
    local refdocs_bin gopath out_file repo_root api_dir
    refdocs_bin="$1"
    gopath="$2"
    template_dir="$3"
    out_file="$4"
    repo_root="$5"
    api_dir="$6"

    (
        cd "${repo_root}"
        env GOPATH="${gopath}" "${refdocs_bin}" \
            -out-file "${out_file}" \
            -api-dir "${api_dir}" \
            -template-dir "${template_dir}" \
            -config "${SCRIPTDIR}/reference-docs-gen-config.json"
    )
}

cleanup() {
    if [ -d "${cleanup_refdocs_root}" ]; then
        echo "Cleaning up tmp directory: ${cleanup_refdocs_root}"
        rm -rf -- "${cleanup_refdocs_root}"
    fi
    if [ -d "${cleanup_repo_clone_root}" ]; then
        echo "Cleaning up tmp directory: ${cleanup_repo_clone_root}"
        rm -rf -- "${cleanup_repo_clone_root}"
    fi
}

main() {
    if [[ -n "${GOPATH:-}" ]]; then
        fail "GOPATH should not be set."
    fi
    if ! command -v "go" 1>/dev/null ; then
        fail "\"go\" is not in PATH"
    fi
    if ! command -v "git" 1>/dev/null ; then
        fail "\"git\" is not in PATH"
    fi

    # install and place the refdocs tool
    local refdocs_bin refdocs_bin_expected refdocs_dir template_dir
    refdocs_dir="$(mktemp -d)"
    cleanup_refdocs_root="${refdocs_dir}"
    # clone repo for ./templates
    git clone --quiet --depth=1 "${REFDOCS_REPO}" "${refdocs_dir}"
    template_dir="${refdocs_dir}/template"
    # install bin
    install_go_bin "${REFDOCS_PKG}@${REFDOCS_VER}"
    # move bin to final location
    refdocs_bin="${refdocs_dir}/refdocs"
    refdocs_bin_expected="$(go env GOPATH)/bin/$(basename ${REFDOCS_PKG})"
    mv "${refdocs_bin_expected}" "${refdocs_bin}"
    [[ ! -f "${refdocs_bin}" ]] && fail "refdocs failed to install"

    local clone_root out_dir
    clone_root="$(mktemp -d)"
    cleanup_repo_clone_root="${clone_root}"
    out_dir="$(mktemp -d)"

    local knative_serving_root
    knative_serving_root="${clone_root}/src/${KNATIVE_SERVING_IMPORT_PATH}"
    clone_at_commit "https://${KNATIVE_SERVING_REPO}.git" "${KNATIVE_SERVING_COMMIT}" \
        "${knative_serving_root}"
    gen_refdocs "${refdocs_bin}" "${clone_root}" "${template_dir}" \
        "${out_dir}/${KNATIVE_SERVING_OUT_FILE}" "${knative_serving_root}" "./pkg/apis"

    local knative_eventing_root
    knative_eventing_root="${clone_root}/src/${KNATIVE_EVENTING_IMPORT_PATH}"
    clone_at_commit "https://${KNATIVE_EVENTING_REPO}.git" "${KNATIVE_EVENTING_COMMIT}" \
        "${knative_eventing_root}"
    gen_refdocs "${refdocs_bin}" "${clone_root}" "${template_dir}" \
        "${out_dir}/${KNATIVE_EVENTING_OUT_FILE}" "${knative_eventing_root}" "./pkg/apis"

    local knative_eventing_contrib_root
    knative_eventing_contrib_root="${clone_root}/src/${KNATIVE_EVENTING_CONTRIB_IMPORT_PATH}"
    clone_at_commit "https://${KNATIVE_EVENTING_CONTRIB_REPO}.git" "${KNATIVE_EVENTING_CONTRIB_COMMIT}" \
        "${knative_eventing_contrib_root}"
    gen_refdocs "${refdocs_bin}" "${clone_root}" "${template_dir}" \
        "${out_dir}/${KNATIVE_EVENTING_CONTRIB_OUT_FILE}" "${knative_eventing_contrib_root}" "."

    log "SUCCESS: Generated docs written to ${out_dir}/."
    log "Opening the ${out_dir}/ directory. You can now copy these API files"
    log "from ${out_dir}/, into the 'docs/reference/' directory of knative/docs."
    if command -v xdg-open >/dev/null; then
        xdg-open "${out_dir}/"
    elif command -v open >/dev/null; then
        open "${out_dir}/"
    fi
}

main "$@"
