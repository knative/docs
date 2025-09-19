---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Installing Knative

There are three ways to install Knative:

- A quickstart implementation on a local computer only using a preconfigured extension.
- A production implementation using YAML.
- A Knative Operator implmemntation using CLI tools and other resources.

Installations assume are running MacOS or Linux.

## Installation roadmap

Use the following table to get started with your Knative installation.

|  | Quickstart | YAML | Knative Operator |
| -- | -- | -- | --- |
| Purpose  | local        | production | production |  
| Kubernetes | local only or minikube | existing deployment | existing deployment |
| Hardware | 3 CPU, 3 GB RAM | One node: 6 CPUs, 6 GB memory, 30 GB disk storage.<br>Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage. | One node: 6 CPUs, 6 GB memory, 30 GB disk storage.<br>Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage. |
| Next steps | Install the [Knative Quickstart plugin](quickstart-install.md). | Use a YAML-based installation for either or both of these components:<br>- Install [Knative Serving](yaml-install/serving/install-serving-with-yaml.md)<br>- Install [Knative Eventing](yaml-install/eventing/install-eventing-with-yaml.md)| <br>Use the [Knative Operator](operator/knative-with-operators.md) to install and configure a production-ready deployment. |

For all installations, you need the Knative CLI and other CLI tools. See [Install Knative CLI](../client/install-kn.md).

Other installation resources:

- [Upgrading Knative](upgrade/README.md)
- [Uninstall Knative](uninstall.md)
- [Check Knative version](upgrade/check-install-version.md)
- [Troubleshoot Knative installations](troubleshooting.md)

For a list of commercial Knative products, see [Knative offerings](knative-offerings.md).