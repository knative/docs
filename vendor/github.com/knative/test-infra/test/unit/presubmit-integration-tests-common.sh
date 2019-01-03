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

source $(dirname $0)/../../scripts/presubmit-tests.sh

function failed() {
  echo $1
  exit 1
}

function pre_integration_tests() {
  PRE_INTEGRATION_TESTS=1
}

function integration_tests() {
  CUSTOM_INTEGRATION_TESTS=1
}

function post_integration_tests() {
  POST_INTEGRATION_TESTS=1
}

function build_tests() {
  return 0
}

function unit_tests() {
  return 0
}

PRE_INTEGRATION_TESTS=0
CUSTOM_INTEGRATION_TESTS=0
POST_INTEGRATION_TESTS=0

trap check_results EXIT
