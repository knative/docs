#!/usr/bin/env bash

# Copyright 2018 The Knative Authors
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

set -o errexit
set -o nounset
set -o pipefail

source $(dirname $0)/../vendor/knative.dev/test-infra/scripts/library.sh

cd ${REPO_ROOT_DIR}

# The list of dependencies that we track at HEAD and periodically
# float forward in this repository.
FLOATING_DEPS=(
  "knative.dev/test-infra"
)

# Parse flags to determine any we should pass to dep.
DEP_FLAGS=()
while [[ $# -ne 0 ]]; do
  parameter=$1
  case ${parameter} in
    --upgrade) DEP_FLAGS=( -update ${FLOATING_DEPS[@]} ) ;;
    *) abort "unknown option ${parameter}" ;;
  esac
  shift
done
readonly DEP_FLAGS

# Ensure we have everything we need under vendor/
dep ensure ${DEP_FLAGS[@]}

# Remove the cmd dir from eventing.
rm -rf vendor/github.com/knative/eventing/cmd/
