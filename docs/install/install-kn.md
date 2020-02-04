---
title: "Installing the Knative CLI"
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
  ```bash
  go install ./cmd/kn
  ```

## `kn` container images
The `kn` container images are available here:
- [Nightly container image](https://gcr.io/knative-nightly/knative.dev/client/cmd/kn)
- [Latest release](https://gcr.io/knative-releases/knative.dev/client/cmd/kn)
