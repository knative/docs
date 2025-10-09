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
- A Knative Operator installation suitable for production use. For details, see [Installing with the Knative Operator](#installing-with-the-knative-operator)

Along with core components, a Knative installation is composed of the Serving and Eventing components. The quickstart implements both. The YAML and Knative Operator installations provide options to install either or both.

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

System requirements provided are recommendations only. The requirements for your installation m may, depending on whether you use optional components, such as a networking layer.

For a list of commercial Knative products, see [Knative offerings](knative-offerings.md).

## Installing with the Knative Operator

You install Knative using YAML files and other resources either aided or not by the Knative Operator. The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components. It allows you to automate applying the content, along with patching the contents to customize them. You install the Knative Operator either by using the Knative CLI Operator Plugin or by using KS8 Manifests or by Yelm.

Here are the considerations for installing using YAML or the Knative Operator:

| YAML-based install | Knative Operator install|
| --- | --- |
| You can see exactly what you get. | You specify choices at a higher level. |
| You can adjust any parameters by editing them directly. | Not every setting is exposed. |
| If you make changes, you have to keep track of what you changed when you want to upgrade. | It's easy to separate your customizations from the base installation. |
| Version and audit control as YAML files are stored in a GitHub repository.| No version or audit control. |

You can install Knative in the following ways:

- Use a [YAML-based installation](/install/yaml-install/README.md) with `kubectl`.

    This option is the most useful if you're using delivery solutions such as Flux or ArgoCD to apply manifests checked into a Git repository. This is the lowest common denominator approach, giving you granular control of the process and resource definitions.

- Install the [Knative Operator](/install/operator/knative-with-operators.md) using Manifests or Yelm, and then use `kubectl` to install Knative components.

    This option alleviates complexity by using the Knative Operator, while still enabling purpose-built manageability using popular tools. It also gives you a separation of the core Knative application definition and the ConfigMap and other changes you make.

- Install the [Knative Operator CLI plugin](/install/operator/knative-with-operator-cli.md) and install the Knative Operator and the Knative CLI `kn` to  Knative components.

    This is the easiest install option and suitable for using if customization is not a concern.

The following table summarizes the options.

| Install option | Resources | kubectl CLI | kn CLI |
| --- | --- | --- | --- |
| YAML-based | All YAML prepared | Install components | not used |
| Knative Operator | Install Knative Operator using Manifests or Yelm |Install components | not used |
| Knative Operator | Install Knative Operator CLI plugin | not used | Install components |

Knative supports subsequent installs after the initial installation, you so your initial choices don't lock you in. For example, you can migrate from one message transport or network ingress to another without losing messages.

## Plugins

A Knative installation includes the following plugins:

Networking plugins

- Kourier (internal no-dependency option)
- Istio (service mesh)
- Courier (general-purpose ingress)
- Gateway API (beta)

Messaging plugins

- In-memory (internal no-dependency option)
- Kafka (in-order, high-thoughput but moderate complexity)
- RabbitMQ (configurable order, moderate throughput and complexity)
- NATS (low complexity)

## Installation resources

Use the following links to maintain your installations.

- [Upgrading Knative](upgrade/README.md)
- [Uninstall Knative](uninstall.md)
- [Check Knative version](upgrade/check-install-version.md)
- [Troubleshoot Knative installations](troubleshooting.md)
