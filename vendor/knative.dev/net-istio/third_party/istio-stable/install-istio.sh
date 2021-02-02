#!/usr/bin/env bash

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

source $(dirname $0)/../download-istio.sh

# Download Istio
download_istio 1.7.6
trap cleanup_istio EXIT

# Install Istio
${ISTIO_DIR}/bin/istioctl install -f "$(dirname $0)/$1"

# Enable mTLS STRICT in mesh mode
if [[ $MESH -eq 1 ]]; then
  kubectl apply -f "$(dirname $0)/extra/global-mtls.yaml"
fi
