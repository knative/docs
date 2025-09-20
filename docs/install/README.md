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

Installations assume are running MacOS or Linux.

## Installation roadmap

Use the following considerations to choose the desired installation method and the steps to proceed.

- Quickstart installation: For learning about Knative and experimenting with its capabilities.
  
  - Kubernetes: Requires a local only deployment of Kubernetes which can a Minikube.

    - Install a local deployment of Kubernetes using kind.
    - Install Minikube, a tool that runs a single-node Kubernetes cluster on your local machine.

  - Minimum hardware requirement: 3 CPUs, 3 GB of RAM.
  - Next steps:

    - Install [CLI Tools](../client/install-kn.md)
    - Install the [Knative Quickstart plugin](quickstart-install.md)
  
- YAML or the Knative Operator installation: For a production implementation.

  - Kubernetes: Requires a cluster running a supported version of Kubernetes.

  - Minimum hardware requirement:

    - One node: 6 CPUs, 6 GB memory, 30 GB disk storage.
    - Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage.

  - Next steps:

    - Install [CLI Tools](../client/install-kn.md)
    - Install using YAML or the Knative Operator:
  
      - Install either or both of the components:

        - Install [Knative Serving](yaml-install/serving/install-serving-with-yaml.md)
        - Install [Knative Eventing](yaml-install/eventing/install-eventing-with-yaml.md)

      - [Knative Operator](operator/knative-with-operators.md). This method provides options for choosing components.

For all installations, you need the Knative CLI and other CLI tools. All installations require a supported Kubernetes version.

Other installation resources:

- [Upgrading Knative](upgrade/README.md)
- [Uninstall Knative](uninstall.md)
- [Check Knative version](upgrade/check-install-version.md)
- [Troubleshoot Knative installations](troubleshooting.md)

For a list of commercial Knative products, see [Knative offerings](knative-offerings.md).