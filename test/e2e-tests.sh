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

# This script runs the end-to-end tests for build templates.

# If you already have a Knative cluster setup and kubectl pointing
# to it, call this script with the --run-tests arguments and it will use
# the cluster and run the tests.

# Calling this script without arguments will create a new cluster in
# project $PROJECT_ID, run the tests and delete the cluster.

source "$(dirname $(readlink -f ${BASH_SOURCE}))/library.sh"

# Test cluster parameters and location of test files
readonly E2E_CLUSTER_NAME=docs-e2e-cluster${BUILD_NUMBER}
readonly E2E_NETWORK_NAME=docs-e2e-net${BUILD_NUMBER}
readonly E2E_CLUSTER_ZONE=us-central1-a
readonly E2E_CLUSTER_NODES=2
readonly E2E_CLUSTER_MACHINE=n1-standard-2
readonly TEST_RESULT_FILE=/tmp/docs-e2e-result
readonly ISTIO_YAML=https://storage.googleapis.com/knative-releases/latest/istio.yaml
readonly SERVING_RELEASE=https://storage.googleapis.com/knative-releases/latest/release.yaml

# This script.
readonly SCRIPT_CANONICAL_PATH="$(readlink -f ${BASH_SOURCE})"

# Helper functions.

function exit_if_test_failed() {
  [[ $? -eq 0 ]] && return 0
  [[ -n $1 ]] && echo "ERROR: $1"
  echo "***************************************"
  echo "***           TEST FAILED           ***"
  echo "***    Start of information dump    ***"
  echo "***************************************"
  echo ">>> All resources:"
  kubectl get all --all-namespaces
  echo "***************************************"
  echo "***           TEST FAILED           ***"
  echo "***     End of information dump     ***"
  echo "***************************************"
  exit 1
}

# Script entry point.

cd ${DOCS_ROOT_DIR}

# Show help if bad arguments are passed.
if [[ -n $1 && $1 != "--run-tests" ]]; then
  echo "usage: $0 [--run-tests]"
  exit 1
fi

# No argument provided, create the test cluster.

if [[ -z $1 ]]; then
  header "Creating test cluster"
  # Smallest cluster required to run the end-to-end-tests
  CLUSTER_CREATION_ARGS=(
    --gke-create-args="--enable-autoscaling --min-nodes=1 --max-nodes=${E2E_CLUSTER_NODES} --scopes=cloud-platform"
    --gke-shape={\"default\":{\"Nodes\":${E2E_CLUSTER_NODES}\,\"MachineType\":\"${E2E_CLUSTER_MACHINE}\"}}
    --provider=gke
    --deployment=gke
    --gcp-node-image=cos
    --cluster="${E2E_CLUSTER_NAME}"
    --gcp-zone="${E2E_CLUSTER_ZONE}"
    --gcp-network="${E2E_NETWORK_NAME}"
    --gke-environment=prod
  )
  if (( ! IS_PROW )); then
    CLUSTER_CREATION_ARGS+=(--gcp-project=${PROJECT_ID:?"PROJECT_ID must be set to the GCP project where the tests are run."})
  fi
  # SSH keys are not used, but kubetest checks for their existence.
  # Touch them so if they don't exist, empty files are create to satisfy the check.
  touch $HOME/.ssh/google_compute_engine.pub
  touch $HOME/.ssh/google_compute_engine
  # Assume test failed (see more details at the end of this script).
  echo -n "1"> ${TEST_RESULT_FILE}
  kubetest "${CLUSTER_CREATION_ARGS[@]}" \
    --up \
    --down \
    --extract "gke-${GKE_VERSION}" \
    --test-cmd "${SCRIPT_CANONICAL_PATH}" \
    --test-cmd-args --run-tests
  result="$(cat ${TEST_RESULT_FILE})"
  echo "Test result code is $result"
  exit $result
fi

# --run-tests passed as first argument, run the tests.

# Install Knative Serving if not using an existing cluster
if (( IS_PROW )) || [[ -n ${PROJECT_ID} ]]; then
  header "Starting Knative Serving"
  acquire_cluster_admin_role $(gcloud config get-value core/account) ${E2E_CLUSTER_NAME} ${E2E_CLUSTER_ZONE}
  subheader "Installing Istio"
  kubectl apply -f ${ISTIO_YAML}
  wait_until_pods_running istio-system
  exit_if_test_failed "could not install Istio"
  kubectl label namespace default istio-injection=enabled

  subheader "Installing Knative Serving"
  kubectl apply -f ${SERVING_RELEASE}
  exit_if_test_failed "could not install Knative Serving"

  wait_until_pods_running knative-serving
  wait_until_pods_running build-system
fi

# TODO(#30): Add tests.
header "TODO(#30): Write integration tests"

# kubetest teardown might fail and thus incorrectly report failure of the
# script, even if the tests pass.
# We store the real test result to return it later, ignoring any teardown
# failure in kubetest.
# TODO(adrcunha): Get rid of this workaround.
echo -n "0"> ${TEST_RESULT_FILE}
echo "**************************************"
echo "***        ALL TESTS PASSED        ***"
echo "**************************************"
exit 0
