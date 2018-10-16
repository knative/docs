#!/bin/bash

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

# This script runs the presubmit tests, in the right order.
# It is started by prow for each PR.
# For convenience, it can also be executed manually.

source $(dirname $0)/../vendor/github.com/knative/test-infra/scripts/presubmit-tests.sh

function build_tests() {
  header "TODO(#67): Write build tests"
}

function unit_tests() {
  header "TODO(#66): Write unit tests"
}

function integration_tests() {
  ./test/e2e-tests.sh
}

main $@
