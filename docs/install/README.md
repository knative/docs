---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Installing Knative

There are three installation methods to install Knative:

- A quickstart experience on a local computer only using a preconfigured extension.
- A YAML installation suitable for production use.
- A Knative Operator installation suitable for production use.

A Knative installation is composed of the Serving and Eventing components. The quickstart implements both. The YAML and Knative Operator installations provide options to install either or both.

Supported platforms are Linux, MacOS, and Windows.

## Installation roadmap

Use the following table to evaluate your installation options.

|  | Quickstart | YAML | Knative Operator |
| --- | --- | --- | --- |
| Purpose  | local   | production     | production  |
| Kubernetes | local deployment of kind or Minikube | existing deployment | existing deployment  |
| Hardware | 3 CPU, 3 GB RAM | One node: 6 CPUs, 6 GB memory, 30 GB disk storage.<br>Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage.   | same as YAML |
| Next steps | Install [CLI Tools](../client/install-kn.md)<br>Install the [Knative Quickstart plugin](quickstart-install.md). | Install [CLI Tools](../client/install-kn.md)<br>Install either or both:<br>- Install [Knative Serving](yaml-install/serving/install-serving-with-yaml.md)<br>- Install [Knative Eventing](yaml-install/eventing/install-eventing-with-yaml.md)| Install [CLI Tools](../client/install-kn.md)<br>Use the [Knative Operator](operator/knative-with-operators.md) to install and configure Knative Serving and Eventing. |

For all installations, you need the Knative CLI and other CLI tools. All installations require a supported Kubernetes version.

System requirements provided are recommendations only. The requirements for your installation might vary, depending on whether you use optional components, such as a networking layer.

## Install optional components

You can extend Knative capabilities with the following components.

| Extension or component | Description |
| --- | -- |
| [Istio](installing-istio.md) | A service mesh platform for microservices. |
| [Cert Manager](installing-cert-manager.md) | Implement TLS certificates for secure HTTPS connections in Knative. |
| [Backstage plugins](installing-backstage-plugins.md) |  Plugins for Knative users and their respective backends. |

## Installation resources

Use the following links to maintain your installations.

- [Upgrading Knative](upgrade/README.md)
- [Uninstall Knative](uninstall.md)
- [Check Knative version](upgrade/check-install-version.md)
- [Troubleshoot Knative installations](troubleshooting.md)

For a list of commercial Knative products, see [Knative offerings](knative-offerings.md).

