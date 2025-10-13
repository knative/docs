---
audience: administrator
components:
  - serving
  - eventing
function: reference
---
# Overview

This page provides guidance for administrators on how to manage Knative on an existing Kubernetes cluster.

As a Kubernetes Administrator, your responsibilities comprise keeping the Kubernetes ecosystem running optimally and enabling your developers to create apps with seamless access to resources, networking, and all parts of the ecosystem. Knative aims to make your tasks easier by providing a Kubernetes ConfigMap for every resource. You can implement version control and strategically set default values so that installations of plugins are seamless.

For example, in Knative Eventing you can deliver events to the broker to route to your function using an in-memory option or a third party plugin for messages and streaming. You can change from one plugin to another seamlessly by your ConfigMap configurations.

## Knative installations

See the [Installation roadmap](../install/README.md#installation-roadmap) for prerequisites and installation steps. Your first installation decision is whether to use a YAML-based installation or use the Knative operator. This section describes those differences.

A Knative installation assumes you, as a Kubernetes administrator, are familiar with the following:

- Kubernetes and Kubernetes administration.
- The `kubectl` CLI tool. You can use existing Kubernetes management tools (policy, quota, etc) to manage Knative workloads.
- Using cluster-admin permissions or equivalent to to install software and manage resources in all clusters in the namespace. For information about permissions, see [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/AC).
- Familiarity with Cloud Native Computing Foundation (CNCF) projects such as Prometheus, Istio, and Strimzi, many of which can be used alongside Knative, is recommended.

The following table summarizes installation options in regard to the CLI tools.

| Install option | Resources | kubectl CLI | kn CLI |
| --- | --- | --- | --- |
| YAML-based | All YAML prepared | Install components | not used |
| Knative Operator |  |Install components | not used |
| Knative Operator | Install Knative Operator CLI plugin | not used | Install components |

### YAML and Knative Operator installations compared

You install Knative using YAML files and other resources either aided or not by the Knative Operator. The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components. It allows you to automate applying the content, along with patching the contents to customize them. This option alleviates complexity by using the Knative Operator and is compatible with a GitOps approach. It also gives you a separation of the core Knative application definition and the ConfigMap and other changes you make. You install the Knative Operator either by using the Knative CLI Operator Plugin or by using KS8 Manifests or by Helm.

Here are the considerations for installing using YAML or the Knative Operator:

| YAML-based install | Knative Operator install|
| --- | --- |
| You can see exactly what you get. | You specify choices at a higher level. |
| You can adjust any parameters by editing them directly. | Not every setting is exposed. |
| If you make changes, you have to keep track of what you changed when you want to upgrade. | It's easy to separate your customizations from the base installation. |
| Version and audit control as YAML files are stored in a GitHub repository.| Manage custom resources using command-line tools or manifests. |

## Configuring Knative

Like Kubernetes, Knative uses YAML to express the different components that can operate in the system, including extensions to the system. Configurations are made throughout the ecosystem, and comprise core objects (such as pods), core objects with custom resource definitions (CRD), and extension resources for administrators and developers.

Configurations are scoped by namespace. Knative follows the Kubernetes development of model namespaces. Each development team is assigned a namespace for developers to create and edit resources in that namespace. Namespaces should generally act as independent units. This can be enforced with tools like RBAC, quota, and policy.

Namespaces can be isolation boundary between teams, the degree to which depends panning and adherence to the namespace strategy. As an administrator, you can enforce that strategy and also provide access to additional resources related to their namespace in other services, such as observability (logs, metrics, tracing) and dashboards.

You make configurations by editing label values in resource definition YAML files, setting key values pairs in ConfigMaps, and often using `kubectl` to apply the changed. Some configurations can be made with the Knative Operator and also the programming language go.

### Configuration tasks

Upon installing Knative, you can access the default settings and adjust as needed.

| To configure | See topic |
| --- | --- |
| Broker defaults | [Configure broker defaults](../eventing/configuration/broker-configuration.md)
| ConfigMap defaults | [Configuring the Defaults ConfigMap](../serving/configuration/config-defaults.md) |
| Domain names |[Configuring domain names](../serving/using-a-custom-domain.md)|
| Event source defaults | [Configure event source defaults](../eventing/configuration/sources-configuration.md)|
| Kafka channel defaults | [Configure Channels for Apache Kafka](../eventing/configuration/kafka-channel-configuration.md)|
| Replace default ingress gateway | [Configuring the ingress gateway](../https://knative.dev/development/serving/setting-up-custom-ingress-gateway.md)|

Use these configurations as to accommodate new apps and other development:

Deployment resources
Istio access to deployed services
Namespace exclusion

Configurations for maintenance:

Garbage collection
High availability
Rollout duration
Kafka autoscaling

Configurations for Security:

encryption: cert-manager
encryption: external domain
encryption: local domain
encryption: system internal

Configurations for Extensions:

Kafka features
Queue proxy extensions
Sugar Controller

## Authorizations

Developers often need access to additional resources related to their namespace in other services, such as observability (logs, metrics, tracing) and dashboards (e.g. Grafana / Backstage). It's expected that the administrator will provision this access alongside creating the namespace and assigning permissions.

## Upgrades

