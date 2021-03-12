#!/usr/bin/env bash

# Copyright 2021 The Knative Authors
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

function download_istio() {
  # Find the right arch so we can download the correct istioctl version
  case "${OSTYPE}" in
    darwin*) ARCH=osx ;;
    linux*) ARCH=linux-amd64 ;;
    msys*) ARCH=win ;;
    *) echo "** unknown OS '${OSTYPE}'" ; exit 1 ;;
  esac

  # Download and unpack Istio

  if [ $1 = "HEAD" ]; then
    ISTIO_VERSION=$(curl https://storage.googleapis.com/istio-build/dev/latest)
  else
    ISTIO_VERSION=$1
  fi

  ISTIO_TARBALL=istio-${ISTIO_VERSION}-${ARCH}.tar.gz

  if [ $1 = "HEAD" ]; then
    DOWNLOAD_URL=https://storage.googleapis.com/istio-build/dev/${ISTIO_VERSION}/${ISTIO_TARBALL}
  else
    DOWNLOAD_URL=https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/${ISTIO_TARBALL}
  fi

  SYSTEM_NAMESPACE="${SYSTEM_NAMESPACE:-"knative-serving"}"

  ISTIO_TMP=$(mktemp -d)
  pushd $ISTIO_TMP
  wget --no-check-certificate $DOWNLOAD_URL
  if [ $? != 0 ]; then
    echo "Failed to download Istio release: $DOWNLOAD_URL"
    exit 1
  fi
  tar xzf ${ISTIO_TARBALL}
  ISTIO_DIR="${ISTIO_TMP}/istio-${ISTIO_VERSION}"
  echo "Istio was downloaded to ${ISTIO_DIR}"
  popd
}

function cleanup_istio() {
  echo "Deleting $ISTIO_TMP"
  rm -rf $ISTIO_TMP
}
