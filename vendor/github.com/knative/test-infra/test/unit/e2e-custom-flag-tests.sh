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

# This script runs the end-to-end tests.

# If you already have a Knative cluster setup and kubectl pointing
# to it, call this script with the --run-tests arguments and it will use
# the cluster and run the tests.

# Calling this script without arguments will create a new cluster in
# project $PROJECT_ID, run the tests and delete the cluster.

source $(dirname $0)/../../scripts/e2e-tests.sh

function parse_flags() {
  if [[ "$1" == "--smoke-test-custom-flag" ]]; then
    echo ">> All tests passed"
    exit 0
  fi
  fail_test "Unexpected flag $1 passed"
}

# Script entry point.

echo ">> Testing e2e custom flag"
initialize --smoke-test-custom-flag
