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

source $(dirname $0)/../vendor/knative.dev/test-infra/scripts/e2e-tests.sh

function install_istio() {
  ISTIO_VERSION=istio-stable
  echo ">> Bringing up Istio"
  echo ">> Running Istio installer"
  chmod +x ./vendor/knative.dev/net-istio/third_party/istio-stable/install-istio.sh
  ./vendor/knative.dev/net-istio/third_party/istio-stable/install-istio.sh istio-ci-no-mesh.yaml || return 1
}

function test_setup() {
  install_istio
  start_latest_knative_serving
}

# Script entry point.

initialize $@ --skip-istio-addon

go_test_e2e ./test/e2e || fail_test

success
