---
title: "Installing Knative"
weight: 05
type: "docs"
aliases:
  - /docs/install/knative-with-any-k8s
  - /docs/install/knative-with-aks
  - /docs/install/knative-with-ambassador
  - /docs/install/knative-with-contour
  - /docs/install/knative-with-docker-for-mac
  - /docs/install/knative-with-gke
  - /docs/install/knative-with-gardener
  - /docs/install/knative-with-gloo
  - /docs/install/knative-with-icp
  - /docs/install/knative-with-iks
  - /docs/install/knative-with-microk8s
  - /docs/install/knative-with-minikube
  - /docs/install/knative-with-minishift
  - /docs/install/knative-with-pks
  - /docs/install/any-kubernetes-cluster
showlandingtoc: "false"
---

You can install the Serving component, Eventing component, or both on your cluster by using one of the following deployment options:

- Using a [YAML-based installation](./prerequisites.md)
- Using the [Knative Operator](./knative-with-operators).
- Following the documentation for vendor managed [Knative offerings](../knative-offerings).

You can also [upgrade an existing Knative installation](./upgrade-installation).

**NOTE:** Knative installation instructions assume you are running Mac or Linux with a bash shell.
<!-- TODO: Link to provisioning guide for advanced installation -->

## Next steps

- Install the [Knative CLI](../client/install-kn) to use `kn` commands.
