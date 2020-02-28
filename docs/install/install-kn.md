---
title: "Installing the Knative CLI"
weight: 10
type: "docs"
---

This guide provides details about how you can install the Knative `kn` client (CLI) using various methods.

## Install `kn` using an executable binary

To install the `kn` Client, you must download the executable binary for your system. Links to the latest stable executable binary releases are available on the [`kn` release page](https://github.com/knative/client/releases).

You must place the executable binary in your system path, and make sure that it is executable.

### Install `kn` using nightly executable binary

Nightly executable binaries are available for users who want to install the most recent pre-release features of `kn`. These binaries include all `kn` features, even those not included in the latest stable release.

**WARNING:** Nightly executable binaries include features which may not be included in the latest stable Knative release, and are therefore not considered to be stable.

To install the `kn` Client, you must download the executable binary for your system. Links to the latest nightly executable binaries are available here:

- [macOS](https://storage.googleapis.com/knative-nightly/client/latest/kn-darwin-amd64)
- [Linux](https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64)
- [Windows](https://storage.googleapis.com/knative-nightly/client/latest/kn-windows-amd64.exe)

You must place the executable binary in your system path, and make sure that it is executable.

## `kn` container images

The `kn` container images are available for users who require these for additional use cases. For example, if you want to use the `kn` container image with [Tekton](https://github.com/tektoncd/catalog/tree/master/kn).

Links to either the nightly container image or the latest stable container image are available here:

- [Nightly container image](https://gcr.io/knative-nightly/knative.dev/client/cmd/kn)
- [Latest release](https://gcr.io/knative-releases/knative.dev/client/cmd/kn)
