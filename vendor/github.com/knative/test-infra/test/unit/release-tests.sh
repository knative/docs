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

source $(dirname $0)/../../scripts/release.sh

set -e

# Call a function and verify its return value and output.
# Parameters: $1 - expected return code.
#             $2 - expected output ("" if no output is expected)
#             $3 ..$n - function to call and its parameters.
function test_function() {
  local expected_retcode=$1
  local expected_string=$2
  local output="$(mktemp)"
  local output_code="$(mktemp)"
  shift 2
  echo -n "$(trap '{ echo $? > ${output_code}; }' EXIT ; "$@")" &> ${output}
  local retcode=$(cat ${output_code})
  if [[ ${retcode} -ne ${expected_retcode} ]]; then
    cat ${output}
    echo "Return code ${retcode} doesn't match expected return code ${expected_retcode}"
    return 1
  fi
  if [[ -n "${expected_string}" ]]; then
    local found=1
    grep "${expected_string}" ${output} > /dev/null || found=0
    if (( ! found )); then
      cat ${output}
      echo "String '${expected_string}' not found"
      return 1
    fi
  else
    if [[ -s ${output} ]]; then
      ls ${output}
      cat ${output}
      echo "Unexpected output"
      return 1
    fi
  fi
  echo "'$@' returns code ${expected_retcode} and displays '${expected_string}'"
}

function mock_branch_release() {
  set -e
  BRANCH_RELEASE=1
  TAG=sometag
  function git() {
	echo $@
  }
  function hub() {
	echo $@
  }
  branch_release "$@" 2>&1
}

function call_function() {
  set -e
  local init=$1
  shift
  eval ${init}
  "$@" 2>&1
}

echo ">> Testing initialization"

test_function 1 "error: missing version" initialize --version
test_function 1 "error: version format" initialize --version a
test_function 1 "error: version format" initialize --version 0.0
test_function 0 "" initialize --version 1.0.0

test_function 1 "error: missing branch" initialize --branch
test_function 1 "error: branch name must be" initialize --branch a
test_function 1 "error: branch name must be" initialize --branch 0.0
test_function 0 "" initialize --branch release-0.0

test_function 1 "error: missing release notes" initialize --release-notes
test_function 1 "error: file a doesn't" initialize --release-notes a
test_function 0 "" initialize --release-notes $(mktemp)

echo ">> Testing release branching"

test_function 0 "" branch_release
test_function 129 "usage: git tag" call_function BRANCH_RELEASE=1 branch_release
test_function 1 "No such file" call_function BRANCH_RELEASE=1 branch_release "K Foo" "a.yaml b.yaml"
test_function 0 "release create" mock_branch_release "K Foo" "$(mktemp) $(mktemp)"

echo ">> Testing validation tests"

test_function 0 "Running release validation" run_validation_tests true
test_function 0 "" call_function SKIP_TESTS=1 run_validation_tests true
test_function 0 "i_passed" run_validation_tests "echo i_passed"
test_function 1 "validation tests failed" run_validation_tests false

echo ">> All tests passed"
