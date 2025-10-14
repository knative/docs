---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Installing Knative

There are three installation methods to install Knative:

- A quickstart experience on a local computer only by using a preconfigured extension.
- A YAML installation suitable for production use.
- A Knative Operator installation suitable for production use.

A Knative installation is composed of the Serving and Eventing components. The quickstart implements both. The YAML and Knative Operator installations provide options to install either or both.

Supported platforms are Linux, MacOS, and Windows.

## Installation roadmap

Use the following table to evaluate your installation method.

|  | Quickstart | YAML | Knative Operator |
| --- | --- | --- | --- |
| Purpose  | local   | production     | production  |
| Kubernetes | local deployment of kind or Minikube | existing deployment | existing deployment  |
| Hardware | 3 CPU, 3 GB RAM | One node: 6 CPUs, 6 GB memory, 30 GB disk storage.<br>Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage.   | same as YAML |

Use the following steps to install Knative depending on your installation method.

**Quickstart**:

  1. Install the [CLI Tools](../client/install-kn.md).
  1. Install the [Knative Quickstart plugin](../getting-started/quickstart-install.md).

**YAML**:

  1. Install the [CLI Tools](../client/install-kn.md).
  1. Install either or both:
       - Install [Knative Serving](yaml-install/serving/install-serving-with-yaml.md).
       - Install [Knative Eventing](yaml-install/eventing/install-eventing-with-yaml.md).

**Operator**:

  1. Install the [CLI Tools](../client/install-kn.md) including the Knative Operator CLI plugin.
  1. Install using the Knative Operator, and with it the Serving and Eventing components, by either of the following:
       - The [Knative Operator](./operator/knative-with-operators.md) using K8S Manifests or via Helm.
       - The [Knative Operator CLI](./operator/knative-with-operator-cli.md).

All installations require a supported Kubernetes version.

System requirements provided are recommendations only. The requirements for your installation  may vary depending on whether you use optional components, such as a networking layer.

For a list of commercial Knative products, see [Knative offerings](knative-offerings.md).

## Installation resources

Use the following links to maintain your installations.

- [Upgrading Knative](upgrade/README.md)
- [Uninstall Knative](uninstall.md)
- [Check Knative version](upgrade/check-install-version.md)
- [Troubleshoot Knative installations](troubleshooting.md)
