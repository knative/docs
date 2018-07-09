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

# This is a collection of useful bash functions and constants, intended
# to be used in test scripts and the like. It doesn't do anything when
# called from command line.

# Default GKE version to be used
readonly GKE_VERSION=latest

# Useful environment variables
[[ -n "${PROW_JOB_ID}" ]] && IS_PROW=1 || IS_PROW=0
readonly IS_PROW
readonly DOCS_ROOT_DIR="$(dirname $(readlink -f ${BASH_SOURCE}))/.."

# Simple header for logging purposes.
function header() {
  echo "================================================="
  echo ${1^^}
  echo "================================================="
}

# Simple subheader for logging purposes.
function subheader() {
  echo "-------------------------------------------------"
  echo $1
  echo "-------------------------------------------------"
}

# Waits until all pods are running in the given namespace or Completed.
# Parameters: $1 - namespace.
function wait_until_pods_running() {
  echo -n "Waiting until all pods in namespace $1 are up"
  for i in {1..150}; do  # timeout after 5 minutes
    local pods="$(kubectl get pods -n $1 2>/dev/null | grep -v NAME)"
    local not_running=$(echo "${pods}" | grep -v Running | grep -v Completed | wc -l)
    if [[ -n "${pods}" && ${not_running} == 0 ]]; then
      echo -e "\nAll pods are up:"
      kubectl get pods -n $1
      return 0
    fi
    echo -n "."
    sleep 2
  done
  echo -e "\n\nERROR: timeout waiting for pods to come up"
  kubectl get pods -n $1
  return 1
}

# Sets the given user as cluster admin.
# Parameters: $1 - user
#             $2 - cluster name
#             $3 - cluster zone
function acquire_cluster_admin_role() {
  # Get the password of the admin and use it, as the service account (or the user)
  # might not have the necessary permission.
  local password=$(gcloud --format="value(masterAuth.password)" \
      container clusters describe $2 --zone=$3)
  kubectl --username=admin --password=$password \
      create clusterrolebinding cluster-admin-binding \
      --clusterrole=cluster-admin \
      --user=$1
}
