---
title: "Installing the `kn` Client"
linkTitle: "Installing the `kn` Client"
weight: 10
type: "docs"
---

## Install `kn` using the nightly executable binary
To install the `kn` Client, you must download the executable binary for your system. Links to the latest nightly executable binary are available here:
  - [macOS](https://storage.googleapis.com/knative-nightly/client/latest/kn-darwin-amd64)
  - [Linux](https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64)
  - [Windows](https://storage.googleapis.com/knative-nightly/client/latest/kn-windows-amd64.exe)

You must place the executable binary in your system path, and make sure that it is executable.

## Install `kn` using Go
1. Check out the [Client repository](https://github.com/knative/client).
1. Run the command:
  ```
  go install ./cmd/kn
  ```

## `kn` container images
The `kn` container images are available here:
- [Nightly container image](gcr.io/knative-nightly/knative.dev/client/cmd/kn)
- [Latest release](gcr.io/knative-releases/knative.dev/client/cmd/kn)
