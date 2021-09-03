#!/usr/bin/env bash

# Copyright 2020 The Knative Authors
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

source "$(dirname $0)/../library.sh"

generate "1.8.4" "$(dirname $0)"

# Temporarily disable mTLS STRICT in mesh mode
# see: this (https://github.com/knative-sandbox/net-istio/issues/503)
# To reenable this create the file extra/istio-mesh.yaml with the following
#
# ---
# apiVersion: "security.istio.io/v1beta1"
# kind: "PeerAuthentication"
# metadata:
#   name: "default"
#   namespace: "istio-system"
# spec:
#   mtls:
#     mode: STRICT

