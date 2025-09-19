---
audience: developer
components:
  - eventing
  - functions
  - serving
function: how-to
---

# Installing CLI Tools

You will need two CLI tools for Knative:

- Knative CLI - kn
- Kubernetes CLI - kubectl

--8<-- "install-kn.md"

## Install Kubernetes CLI

Install the [Kubernetes CLI (`kubectl`)](https://kubernetes.io/docs/tasks/tools/install-kubectl){target=_blank} to run commands against Kubernetes clusters. You can use `kubectl` to deploy applications, inspect and manage cluster resources, and view logs.

--8<-- "security-prereqs-binaries.md"

## Install kn using the nightly-built binary

!!! warning
    Nightly container images include features which may not be included in the latest Knative release and are not considered to be stable.


Nightly-built executable binaries are available for users who want to install the latest pre-release build of `kn`.

Links to the latest nightly-built executable binaries are available here:

- [macOS](https://storage.googleapis.com/knative-nightly/client/latest/kn-darwin-amd64){target=_blank}
- [Linux](https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64){target=_blank}
- [Windows](https://storage.googleapis.com/knative-nightly/client/latest/kn-windows-amd64.exe){target=_blank}

## Using kn with Tekton

See the [Tekton documentation](http://hub.tekton.dev/tekton/task/kn){target=_blank}.
