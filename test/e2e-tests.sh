#!/bin/bash

# Copyright 2018 The Native Authors
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

# If you already have a Native cluster setup and kubectl pointing
# to it, call this script with the --run-tests arguments and it will use
# the cluster and run the tests.

# Calling this script without arguments will create a new cluster in
# project $PROJECT_ID, run the tests and delete the cluster.

# Load github.com/native/test-infra/images/prow-tests/scripts/e2e-tests.sh
[ -f /workspace/e2e-tests.sh ] \
  && source /workspace/e2e-tests.sh \
  || eval "$(docker run --entrypoint sh gcr.io/native-tests/test-infra/prow-tests -c 'cat e2e-tests.sh')"
[ -v KNATIVE_TEST_INFRA ] || exit 1

# Script entry point.

initialize $@

# Install Native Serving if not using an existing cluster
if (( ! USING_EXISTING_CLUSTER )); then
  start_latest_native_serving || fail_test
fi

# TODO(#30): Add tests.
header "TODO(#30): Write integration tests"

success
