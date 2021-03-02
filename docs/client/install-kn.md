---
title: "Installing the kn CLI"
weight: 10
type: "docs"
aliases:
  - /docs/install/install-kn
  - /docs/client/connecting-kn-to-your-cluster
---

This guide provides details about how you can install the Knative `kn` client (CLI) using various methods.

## Install kn using an executable binary

You can install `kn` by downloading the executable binary for your system and placing it in the system path.

Links to the latest stable executable binary releases are available on the <a href="https://github.com/knative/client/releases" target="_blank">`kn` release page</a>.


### Install kn using nightly executable binary

Nightly executable binaries are available for users who want to install the latest pre-release build of `kn`.

**WARNING:** Nightly executable binaries include features which may not be included in the latest Knative release and are not considered to be stable.

Links to the latest nightly executable binaries are available here:

- <a href="https://storage.googleapis.com/knative-nightly/client/latest/kn-darwin-amd64" target="_blank">macOS</a>
- <a href="https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64" target="_blank">Linux</a>
- <a href="https://storage.googleapis.com/knative-nightly/client/latest/kn-windows-amd64.exe" target="_blank">Windows</a>

## Install kn using Go

1. Check out the `kn` client repository:

      ```
      git clone https://github.com/knative/client.git
      cd client/
      ```

1. Build an executable binary:

      ```
      hack/build.sh -f
      ```

1. Move `kn` into your system path, and verify that `kn` commands are working properly. For example:

      ```
      kn version
      ```

## Install kn using brew

For macOs, you can install `kn` by using <a href="https://github.com/knative/homebrew-client" target="_blank">brew</a>.

## Installing kn using container images

**WARNING:** Nightly container images include features which may not be included in the latest Knative release and are not considered to be stable.

Links to images are available here:

- <a href="https://gcr.io/knative-releases/knative.dev/client/cmd/kn" target="_blank">Latest release</a>
- <a href="https://gcr.io/knative-nightly/knative.dev/client/cmd/kn" target="_blank">Nightly container image</a>

You can run `kn` from a container image. For example:

```
docker run --rm -v "$HOME/.kube/config:/root/.kube/config" gcr.io/knative-releases/knative.dev/client/cmd/kn:latest service list
```

## Using kn with Tekton

See the <a href="http://hub.tekton.dev/tekton/task/kn" target="_blank">Tekton documentation</a>.

## Connecting the kn CLI to your cluster

The `kn` Client uses your `kubectl` client configuration, the kubeconfig file, to connect to your cluster. This file is usually automatically created when you create a Kubernetes cluster. `kn` looks for your kubeconfig file in the default location of `$HOME/.kube/config`.

For more information about kubeconfig files, see <a href="https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/" target="_blank">Organizing Cluster Access Using kubeconfig Files</a>.

### Using kubeconfig files with your platform

Instructions for using `kubeconfig` files are available for the following platforms:

- <a href="https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html" target="_blank">Amazon EKS</a>
- <a href="https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl" target="_blank">Google GKE</a>
- <a href="https://cloud.ibm.com/docs/containers?topic=containers-getting-started" target="_blank">IBM IKS</a>
- <a href="https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/administrator-cli-commands.html#create-kubeconfig" target="_blank">Red Hat OpenShift Cloud Platform</a>
- Starting <a href="https://minikube.sigs.k8s.io/docs/start/" target="_blank">minikube</a> writes this file automatically, or provides an appropriate context in an existing configuration file.
