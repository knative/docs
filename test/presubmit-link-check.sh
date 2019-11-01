#!/bin/bash

# Copyright 2019 The Knative Authors
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

source $(dirname $0)/../vendor/knative.dev/test-infra/scripts/presubmit-tests.sh

initialize_environment
if (( IS_PRESUBMIT_EXEMPT_PR )) || (( ! IS_DOCUMENTATION_PR )); then
  header "Commit only contains changes that don't require link checks, skipping"
  exit 0
fi

# Force presubmit link checking only.
export DISABLE_MD_LINTING=1
$(dirname $0)/presubmit-tests.sh --build-tests
