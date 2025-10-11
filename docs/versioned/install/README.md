---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Installing Knative

This page provides guidance for Kubernetes administrators on how to install Knative on an existing Kubernetes cluster. Knative has three components: Eventing, Serving, and Functions and the CLI client tools `kn` and `func`. Serving and Eventing are installed into clusters. Functions is not installed into clusters because it is operated by the client `func` CLI tool.

Supported platforms are Linux, MacOS, and Windows.

## Installation roadmap

Use the following table to determine your installation method. If you just want to get an understanding of Knative functionality at this time, install the quickstart.

|  | Quickstart | YAML-based | Knative Operator |
| --- | --- | --- | --- |
| Purpose  | local   | production     | production  |
| Kubernetes deployment | local, either `kind` or `Minikube` | existing  | existing  |
| Hardware | 3 CPU, 3 GB RAM | One node: 6 CPUs, 6 GB memory, 30 GB disk storage.<br>Multiple nodes: 2 CPUs each, 4 GB memory, 20 GB disk storage.   | same as YAML |

Use the following steps to install Knative depending on your installation method.

**Quickstart**:

  1. Install the [CLI Tools](../client/install-kn.md).
  1. Install the [Knative Quickstart plugin](../getting-started/quickstart-install.md).

**YAML-based**:

Install using all YAML files. This option is the most useful if you're using GitOps tools such as Flux or ArgoCD to apply manifests checked into a Git repository. This is the lowest common denominator approach, giving you granular control of the process and resource definitions.

  1. Install the [CLI Tools](../client/install-kn.md).
  1. Install either or both:
       - Install [Knative Serving](../install/yaml-install/serving/install-serving-with-yaml.md).
       - Install [Knative Eventing](../install/yaml-install/eventing/install-eventing-with-yaml.md).

**Knative Operator**:

Install using the Knative Operator as installed with Manifests or Helm, or install using the Knative Operator as installed with the Knative Operator CLI plugin.

  1. Install the [CLI Tools](../client/install-kn.md) including the Knative Operator CLI plugin.
  1. Install using the Knative Operator, and with it the Serving and Eventing components, by either of the following:
       - The [Knative Operator](../install/operator/knative-with-operators.md) using K8S Manifests or via Helm.
       - The [Knative Operator CLI](../install/operator/knative-with-operator-cli.md).

All installations require a supported Kubernetes version. System requirements provided are recommendations only. The requirements for your installation m may, depending on whether you use optional components, such as a networking layer.

For a list of commercial Knative products, see [Knative offerings](../install/knative-offerings.md).

## Installation assumptions and options

The installation assumes you, as a Kubernetes administrator, are familiar with the following:

- Kubernetes and Kubernetes administration.
- The `kubectl` CLI tool. You can use existing Kubernetes management tools (policy, quota, etc) to manage Knative workloads.
- Using cluster-admin permissions or equivalent to to install software and manage resources in all clusters in the namespace. For information about permissions, see [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/AC).
- Familiarity with Cloud Native Computing Foundation (CNCF) projects such as Prometheus, Istio, and Strimzi, many of which can be used alongside Knative, is recommended.

Serving and Eventing support multiple underlying transports plugins within the same cluster. Serving supports pods with pluggable network ingress routes, and Eventing supports pods with pluggable message transports (e.g. Kafka, RabbitMQ).

Knative has default lightweight messaging implementation if you don't already have a solution. Knative also has Kourier, a default lightweight HTTP routing implementation, if you don't already have an ingress that meets the requirements.

Knative supports installing additional plugins after the initial installation, you so your initial choices don't lock you in. For example, you can migrate from one message transport or network ingress to another without losing messages.

The following table summarizes installation options in regard to the CLI tools.

| Install option | Resources | kubectl CLI | kn CLI |
| --- | --- | --- | --- |
| YAML-based | All YAML prepared | Install components | not used |
| Knative Operator |  |Install components | not used |
| Knative Operator | Install Knative Operator CLI plugin | not used | Install components |

## YAML and Knative Operator installations compared

You install Knative using YAML files and other resources either aided or not by the Knative Operator. The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components. It allows you to automate applying the content, along with patching the contents to customize them. This option alleviates complexity by using the Knative Operator and is compatible with a GitOps approach. It also gives you a separation of the core Knative application definition and the ConfigMap and other changes you make. You install the Knative Operator either by using the Knative CLI Operator Plugin or by using KS8 Manifests or by Helm.

Here are the considerations for installing using YAML or the Knative Operator:

| YAML-based install | Knative Operator install|
| --- | --- |
| You can see exactly what you get. | You specify choices at a higher level. |
| You can adjust any parameters by editing them directly. | Not every setting is exposed. |
| If you make changes, you have to keep track of what you changed when you want to upgrade. | It's easy to separate your customizations from the base installation. |
| Version and audit control as YAML files are stored in a GitHub repository.| Manage custom resources using command-line tools or manifests. |

## Extensibility plugins

Knative utilizes existing infrastructure already have installed on your cluster, while standardizing the developer-facing interface between similar components. You can add the following resources to extend the cluster infrastructure.

Networking plugins:

- Kourier
    Lightweight ingress that leverages envoy proxy. See [Kore Technologies](https://github.com/knative-extensions/net-kourier).
- Istio
    Service mesh from [Istio](https://istio.io). See [Installing Istio for Knative](../install/installing-istio.md).
- Contour
    General-purpose ingress with a goal of enabling multi-team delegation. See [Contour](https://projectcontour.io/).
- Gateway API
    The Kubernetes [Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/) (beta).

Messaging plugins:

- Kafka
    Distributed event streaming platform from [Apache Kafka](https://kafka.apache.org). In-order, high-thoughput but moderate complexity. See [Install Kafka for Knative](../install/eventing/kafka-install.md).
- RabbitMQ
    A messaging and streaming broker from [RabbitMQ](https://www.rabbitmq.com). In-order, moderate throughput and complexity. See [Install RabbitMQ for Knative](../install/eventing/rabbitmq-install.md)
- NATS
    An event streaming platform from [NATS](https://nats.io). Low complexity.

Knative Eventing also includes a no-dependency in-memory (non-durable) messaging implementation.

## Integration plugins

These plugins facilitate Knative operations.

- cert-manager
    For requesting TLS certificates in secure HTTPS connections, see [Install cert-manager](../install/installing-cert-manager.md).
- Backstage
    Plugins for handling Knative backends. See [Installing backstage plugins](../install/installing-backstage-plugins.md).

## Installation resources

Use the following links to maintain your installations.

- [Upgrading Knative](../install/upgrade/README.md)
- [Uninstall Knative](../install/uninstall.md)
- [Check Knative version](../install/upgrade/upgrade/check-install-version.md)
- [Troubleshoot Knative installations](../install/troubleshooting.md)
