#!/usr/bin/env bash

# Originally stolen almost literally from
# https://github.com/openshift-cloud-functions/knative-operators/blob/master/etc/scripts/install-on-minishift.sh
# just added 'anyuid' add-on, as per manual steps documentation.

# WARNING: this totally destroys and recreates your `knative` profile,
# thereby guaranteeing (hopefully) a clean environment upon successful
# completion.

if minishift status | head -1 | grep "Running" >/dev/null; then
  echo "Please stop your running minishift to acknowledge this script will destroy it."
  exit 1
fi

set -ex

OPENSHIFT_VERSION=${OPENSHIFT_VERSION:-v3.11.0}
MEMORY=${MEMORY:-10GB}
CPUS=${CPUS:-4}
DISK_SIZE=${DISK_SIZE:-50g}

# blow away everything in the knative profile
minishift profile delete knative --force || true

# configure knative profile
minishift profile set knative
minishift config set openshift-version ${OPENSHIFT_VERSION}
minishift config set memory ${MEMORY}
minishift config set cpus ${CPUS}
minishift config set disk-size ${DISK_SIZE}
minishift config set image-caching true
minishift addons enable admin-user
minishift addons enable anyuid

# Start minishift
minishift start

eval "$(minishift oc-env)"

oc login -u admin -p admin

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# "$DIR/install.sh" -q
