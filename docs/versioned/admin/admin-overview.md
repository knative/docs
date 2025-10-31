---
audience: administrator
components:
  - serving
  - eventing
function: explanation
---
# Overview

This page provides guidance for administrators on how to manage Knative on an existing Kubernetes cluster.

```mermaid
---
config:
  theme: redux
---
flowchart TD
    Dev(["Application Developers"])
    dev-acts@{ shape: text, label: "Manages k8s objects defined by" }
    subgraph Knative
        Serving
        Eventing
    end
    subgraph Plugins
        net-istio["Istio"]
        net-contour["Contour"]
        net-gateway-api["Gateway API"]
        event-kafka["Kafka"]
        event-rabbitmq["RabbitMQ"]
        event-nats["NATS"]
    end
    event-impl@{ shape: text, label: "implements" }
    net-impl@{ shape: text, label: "implements" }
    admin-acts@{ shape: text, label: "Installs and configures" }
    Admin(["Cluster Administrators"])

    Dev --- dev-acts
    dev-acts --> Serving & Eventing
    
    admin-acts --- Admin
    Plugins & Knative --- admin-acts
    %% The ~~~ ... --> syntax is used to force backwards arrows;
    %% See https://github.com/mermaid-js/mermaid/issues/2629 for details.
    Serving ~~~ net-impl --> Serving
    Eventing ~~~ event-impl --> Eventing

    net-impl --- net-istio & net-contour & net-gateway-api
    event-impl --- event-kafka & event-rabbitmq & event-nats
```

As a cluster administrator, your responsibilities include managing the Kubernetes environment, installing cluster-wide components, and enabling developers to deploy applications on the cluster. Knative aims to simplify developer tasks, while aligning with existing management tools and processes.

Knative includes a plugin system to integrate with existing infrastructure in the cluster, enabling Knative resources such as Routes and Brokers to be implemented using one of multiple underlying suppliers. For example, a Knative Eventing app can deliver events to a Broker that triggers a function based on the received event. In a testing cluster, the delivery might use an in-memory option, while a staging or production environment might use a cloud-provided Kafka service.

Of particular interest to cluster administrators is that Knative supports customizable _default values_ on the parameters defined in resource YAML files. These configurations reduce the amount of environment configuration tasks developers needs to consider.

## Knative installations

See the [Installation roadmap](../install/README.md#installation-roadmap) for prerequisites and installation steps. Your first installation decision is whether to use a YAML-based installation or use the Knative Operator. The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components. If you just need to get acquainted with Knative at this time, you can install the [quickstart](../getting-started/quickstart-install.md).

## Configuring Knative components

Knative configurations are performed by the following methods:

- Editing YAML manifests and applying with the `kubectl` tool

    Modify resource definitions directly, including labels, annotations, and field values. You can use Kubernetes features such as [OPA](https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/) and [Kyverno](https://kyverno.io) to enforce specific values on a resource type, or use ConfigMaps in plugin installations to set values at the cluster level.

- Using ConfigMaps

    Store and manage configuration data as key-value pairs. ConfigMaps are frequently used to tune platform-wide behavior. Most of the Knative ConfigMaps are in the `knative-serving` and `knative-eventing` namespaces. Their settings apply to all the relevant Knative components in all namespaces.

- Using the Knative Operator

    Some platform-wide settings can be managed declaratively using the Knative Operator, installed with the `kn` Knative CLI plugin. For more information, see [Installing CLI tools](../client/README.md)

## Configuration summaries

Knative uses Kubernetes YAML manifests to define and configure system components. These manifests include core resources, custom resource definitions (CRDs), and extensibility features. As with Kubernetes, these configuration resources are declarative and can be managed using the `kubectl` CLI tool or with continuous delivery tools.

The following sections provide an overview of the current configurations procedures of interest to Administrators. You make these configurations using `kubectl`, some by applying YAML files you create.

### Network configuration summaries

| Configuration | ConfigMap | Description |
| -- | --- | --- |
| [Ingress gateway](../serving/setting-up-custom-ingress-gateway.md)| `config-istio` | For new clusters, you can configure your own gateway and underlying service. |
| [Istio authorization](../serving/istio-authorization.md) | NA | Grant authorization to your deployed Knative services. |
| [Domain names](../serving/using-a-custom-domain.md) | `config-domain` | Configure and publish domains. |

### Serving configuration summaries

| Configuration | ConfigMap | Description |
| -- | --- | --- |
| [Deployment resources](../serving/configuration/deployment.md) | `config-deployment` | Kubernetes deployment resources that back Knative services. |
| [Defaults ConfigMap](../serving/configuration/config-defaults.md) | `config-defaults` | Default resource values such as performance, hardware, and storage settings. |
| [Rollout duration for revisions](../serving/configuration/rolling-out-latest-revision-configmap.md) | `config-network` | Adjust rollout durations to accommodate longer request queues. |
| [Garbage collection](../serving/revisions/revision-admin-config-options.md) | `config-gc` | Disable and enable collection and set retention time values. |
| [Encryption Overview](../serving/encryption/encryption-overview.md) | `config-network` | Provides links to procedures for encrypting external domains, the local cluster, and system internal. |
| [Cert-manager integration](../serving/encryption/configure-certmanager-integration.md) | NA | Describes how to manage automatic certificate provisioning. |
| [High-availability components](../serving/config-ha.md) | NA | Configure ensure that APIs stay operational if a disruption occurs. |
| [Namespace exclusion from the Knative webhook](../serving/webhook-customizations.md) | NA | For performance concerns during an upgrade. |

### Compressed view test - Serving

| Configuration and ConfigMap (if applicable) |
| --  |
| [Deployment resources](../serving/configuration/deployment.md) - `config-deployment` <br> [Defaults ConfigMap](../serving/configuration/config-defaults.md) - `config-defaults` <br> [Rollout duration for revisions](../serving/configuration/rolling-out-latest-revision-configmap.md) - `config-network` <br> [Garbage collection](../serving/revisions/revision-admin-config-options.md) - `config-gc` <br> [Encryption Overview](../serving/encryption/encryption-overview.md)- `config-network` <br> [Cert-manager integration](../serving/encryption/configure-certmanager-integration.md) <br>  [High-availability components](../serving/config-ha.md) <br> [Namespace exclusion from the Knative webhook](../serving/webhook-customizations.md) |



### Eventing configuration summaries

| Configuration | ConfigMap | Description |
| -- | --- | --- |
| [Broker defaults](../eventing/configuration/broker-configuration.md) | `config-br-defaults` | Specify your own broker class and channel, or use the default `MTChannelBasedBroker` Broker class and  the ConfigMap of channel defaults. |
| [Channel defaults](../eventing/configuration/channel-configuration.md) | `default-ch-webhook` | Default configurations and labels to use for the channel. |
| [Apache Kafka Channel defaults](../eventing/configuration/kafka-channel-configuration.md) | `kafka-channel` | Defines how KafkaChannel instances are created. Requires that KafkaChannel custom resource definitions (CRD) are installed.|
| [Kafka Broker features](../eventing/brokers/broker-types/kafka-broker/configuring-kafka-features.md) | `config-kafka-features` | Configure options for Broker interactions with Apache Kafka clusters. |
| [Event source defaults](../eventing/configuration/sources-configuration.md) |`config-ping-defaults` | Configure the PingSource default resources and the maximum data size for CloudEvents it produces. |
| [Sugar Controller](../eventing/sugar/README.md) |`config-sugar` | Configure the Sugar controller, which reacts to label configurations to produce or control eventing resources. See also [Knative Eventing Sugar Controller](../eventing/sugar/README.md). |
| [KEDA Autoscaling of Knative Kafka Resources](../eventing/configuration/keda-configuration.md) |`config-kafka-features` | Configure how KEDA scales a KafkaSource, trigger, or subscription. Note: This feature is is Alpha pre-release. |

## Resource scoping and namespaces

Knative resources are namespaced. Knative adheres to the Kubernetes model of namespace-based isolation that lets you manage development teams and resources by assigning them to namespaces.

Namespaces can also isolate boundaries for tooling such as logs, metrics, tracing, CI/CD integrations, and dashboards. The extent of this isolation depends on both the enforcement strategy and how consistently teams adhere to namespace boundaries.

You can optimize and enforce isolation involving namespaces using standard Kubernetes mechanisms, including:

- [Role-Based Access Control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)

## Authorizations

You can grant developers access to additional resources related to their namespace in other services, such as observability, logs, metrics, tracing, and dashboards.

## Upgrades

Administrators are generally responsible for performing upgrades cluster infrastructure and apps and services. Knative is designed and tested for continuous operation during upgrades and rollbacks, allowing you to:

- Upgrade or revert the Knative components while it is serving traffic, rather than needing a maintenance window.
- Downgrade one Knative version. Downgrades work provided that no applications have used new features since the last upgrade.
