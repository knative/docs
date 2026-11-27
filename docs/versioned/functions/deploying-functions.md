---
audience: developer
components:
  - functions
function: how-to
---

# Deploying functions

--8<-- "deploy-func-intro.md"

## Prerequisites

- You have a Kubernetes cluster with Knative Serving installed, and your kubeconfig
  selects the intended cluster and namespace. For a disposable environment,
  [set up a learning cluster](../getting-started/quickstart-install.md) and check
  its context before returning here. Local Functions development alone does not
  create a cluster.

- You have a Docker daemon running on your local machine for the container builder.
  Quickstart uses an existing container engine; it does not install one.

- You have access to a container registry and are able to push images to this registry. Note that some image registries set newly pushed images to private by default. If you are deploying a function for the first time, you may need to ensure that your images are set to public.

## Procedure

For a first deployment, follow the [worked deployment tutorial](../getting-started/about-knative-functions.md#deploy-to-knative-optional),
which covers cluster setup, registry login, and the full image name. This is also
the next step if you are coming from the local Functions track.

In the commands below, `<registry>` means the registry **and your account namespace**.
For example, `docker.io/alice` means Alice's Docker Hub namespace, and
`ghcr.io/alice` means her GitHub Container Registry namespace. Substitute your own
account; do not type the angle brackets. The CLI uses that prefix with the
function's project name to construct the image name. The worked tutorial instead
uses `--image` to set the complete destination explicitly.

--8<-- "proc-deploying-function.md"
