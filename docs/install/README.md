---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Installing Knative

You can install Knative in two ways:

- A full implementation for production on an existing Kubernetes deployment.
- A quickstart implementation with a Minikube option. Use this implementation for a preconfigured, local distribution for prototyping purposes.

Installations assume are running MacOS or Linux.

## Installation roadmap

Use the following table to get you started with your Knative installations.

| Task | Quickstart installation | Production installation |
| -- | -- | -- |
| Kubernetes check | kind, minikube | Existing local deployment of Kubernetes 1.28 or newer. |
| Verify Hardware | 3 CPU, 3 GB RAM | One node: 6 CPUs, 6 GB memory, 30 GB disk storage.<br>Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage. |
| Next steps | Install the [Knative Quickstart plugin](quickstart-install.md). | Use a YAML-based installation for either or both of these components:<br>- Install [Knative Serving](yaml-install/serving/install-serving-with-yaml.md)<br>- Install [Knative Eventing](yaml-install/eventing/install-eventing-with-yaml.md)<br>Use the [Knative Operator](operator/knative-with-operators.md) to install and configure a production-ready deployment. |

For all installations, you need the Knative CLI and other CLI tools. See [Install Knative CLI](../client/install-kn.md).

Other installation resources:

- [Ugrading Knative](install/upgrade/README.md)
- [Uninstall Knative](uninstall.md)
- [Check Knative version](upgrade/check-install-version.md)
- [Troubleshoot Knative installations](troublehooting.md)


See the [Serving Architecture](../serving/architecture.md) for an explanation of Knative components and the general networking.

For a list of commercial Knative products, see [Knative offerings](knative-offerings.md).


