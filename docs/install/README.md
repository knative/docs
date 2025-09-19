---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Installing Knative

There are three installation methods to install Knative:

- A quickstart implementation on a local computer only using a preconfigured extension.
- A production implementation using YAML.
- A Knative Operator implmemntation using CLI tools and other resources.

Installations assume are running MacOS or Linux.

## Installation roadmap

Use the following table to evaulate the installtion methods for Knative installations.

|  | Quickstart | YAML | Knative Operator |
| --- | --- | --- | --- |
| Implementation  | local        | production | production |  
| Kubernetes | local deployment only or Minikube | existing deployment | existing deployment |
| Hardware | 3 CPU, 3 GB RAM | One node: 6 CPUs, 6 GB memory, 30 GB disk storage.<br>Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage. | One node: 6 CPUs, 6 GB memory, 30 GB disk storage.<br>Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage. |
| Next steps | Install [CLI Tools](../client/install-kn.md)<br>Install the [Knative Quickstart plugin](quickstart-install.md). | Install [CLI Tools](../client/install-kn.md)<br>Install either or both:<br>- Install [Knative Serving](yaml-install/serving/install-serving-with-yaml.md)<br>- Install [Knative Eventing](yaml-install/eventing/install-eventing-with-yaml.md)| Install [CLI Tools](../client/install-kn.md)<br>Use the [Knative Operator](operator/knative-with-operators.md) to install and configure Knative Serving and Eventing. |

For all installations, you need the Knative CLI and other CLI tools. All installations require a supported Kubernetes version.

Other installation resources:

- [Upgrading Knative](upgrade/README.md)
- [Uninstall Knative](uninstall.md)
- [Check Knative version](upgrade/check-install-version.md)
- [Troubleshoot Knative installations](troubleshooting.md)

For a list of commercial Knative products, see [Knative offerings](knative-offerings.md).