---
audience: administrator
components:
  - serving
  - eventing
function: reference
---
# Overview

This page explains to administrators how to install and manage Knative on an existing Kubernetes cluster, and assumes you have familiarity the following:

- Kubernetes and Kubernetes administration.
- The `kubectl`CLI tool. You will also be using the Knative CLI tools, `kn` and `func`. You can use existing Kubernetes management tools (policy, quota, etc) to manage Knative workloads.
- The Cloud Native Computing Foundation (CNCF) for which Knative is one of its projects, along with Kubernetes, Prometheus, and Istio.

Additionally, you should have cluster-admin permissions or equivalent to to install software and manage resources in all clusters in the namespace.  

The objective of this overview is to provide an understanding of the different Knative components, their roles, the Knative philosophy, and how to enable your cluster's users to develop using Knative.

Essentially, Knative aims to extend Kubernetes, and build on existing capabilities where feasible. It has two main underlying components that support plugging in multiple underlying transports within the same cluster:

- Serving: Pods and pluggable network ingress routes.
- Eventing: Pods and pluggable message transports (e.g. Kafka, RabbitMQ)

Knative has default lightweight implementations if you don't already have a solution.

This article outlines major Knative functionality and provides links to detailed procedures as applicable for administrators. It covers the following processes:

- Installing
- Configuring
- Monitoring
- Enforcing security
- Updating and maintaining

## Installing

You install Knative using YAML files and other resources either aided or not by the Knative Operator. The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components. It allows you to automate applying the content, along with patching the contents to customize them. You install the Knative Operator either by using the Knative CLI Operator Plugin or by using KS8 Manifests or by Yelm.

Here are the considerations for installing using either YAML-based or with the Knative Operator:

| YAML-based install | Knative Operator install|
| --- | --- |
| You can see exactly what you get. | You specify choices at a higher level. |
| You can adjust any parameters by editing them directly. | Not every setting is exposed. |
| If you make changes, you have to keep track of what you changed when you want to upgrade. | It's easy to separate your customizations from the base installation. |
| Version and audit control. YAML files are typically stored in a GitHub repository.|  |

You can install Knative in the following ways:

- Use a [YAML-based installation](/install/yaml-install/README.md) with `kubectl`.

  This option is the most useful if you're using delivery solutions such as Flux or ArgoCD to apply manifests checked into a Git repository. This is the lowest common denominator approach, giving you granular control of the process and resource definitions.

- Install the [Knative Operator](/install/operator/knative-with-operators.md) using Manifests of Yelm, and then use `kubectl` to install Knative components.

  This option alleviates the complexity with the Knative Operator, while still enabling purpose-built manageability using popular tools. It also gives you a separation of the core Knative application definition and the ConfigMap and other changes you make.

- Install the [Knative Operator CLI plugin](/install/operator/knative-with-operator-cli.md) and install the Operator, and the use `kn` to install  Knative components.

  This is the easiest install option and suitable for using Knative if customization is not a concern.

The following table summarizes the options.

| Install option | Resources | kubectl CLI | kn CLI |
| --- | --- | --- | --- |
| YAML-based | All YAML prepared | Install components | not used |
| Knative Operator | Install Knative Operator using Manifests or Yelm |Install components | not used |
| Knative Operator | Install Knative Operator CLI plugin | not used | Install components |

Knative supports subsequent installs after the initial installation, you so your initial choices don't lock you in. For example, you can migrate from one message transport or network ingress to another without losing messages.

### Recommended plugins

You can also install these plugins service to extend Knative capabilities for service meshes:

- [Istio for Knative](/install/installing-istio.md)
- [Knative Backstage plugin](/install/installing-backstage-plugins.md)
- [cert-manager](/install/installing-cert-manager.md)

For un-installations, see [Uninstalling Knative](/install/uninstall.md).

## Configuring

Knative enables you to  optimize Serving and Eventing components and configure administration settings for your clusters.

### ConfigMaps

The Knative Operator propagates values from custom resources to the ConfigMaps object, a storage object of non-confidential values in key-value pairs. You can [Configuring Knative using the Operator](/install/operator/configuring-with-operator.md) and define custom resource definitions:

- [Knative Serving CRDs](/install/operator/configuring-serving-cr.md)
- [Knative Eventing CRDs](/install/operator/configuring-eventing-cr.md)

See [Configure the Defaults ConfigMap](/serving/configuration/config-defaults.md).

TODO: Editing ConfigMaps guidance

### Autoscaling, high-availability and load balancing

For the Serving component, you can set global or per-revision configurations for [Supported autoscaler types](/serving/autoscaling/autoscaler-types.md). You can [Configure metrics](/serving/autoscaling/autoscaling-metrics.md) for a per revision configuration, constantly monitored by the Autoscaler. The Autoscaler maintains targeted values according to the configured metrics. See [Configuring targets](/serving/autoscaling/autoscaling-targets.md).

Autoscaling includes [Configuring scale to zero](/serving/autoscaling/scale-to-zero.md), concurrency, [Configuring concurrency](/serving/autoscaling/concurrency.md), [Configuring the requests per second (RPS) target](/serving/autoscaling/rps-target.md), [Configuring scale bounds](/serving/autoscaling/scale-bounds.md), and [Additional autoscaling configuration for Knative Pod Autoscaler](/serving/autoscaling/kpa-specific.md)

See [Configuring high-availability components](/serving/config-ha.md).

For load balancing, you can [Configure Activator capacity](/serving/load-balancing/activator-capacity.md) and [Target-Burst capacity](/serving/load-balancing/target-burst-capacity.md).

### Networking

Networking administrative tasks include [Exclude namespaces from the Knative webhook](/serving/webhook-customizations.md), [Configuring the ingress gateway](/serving/setting-up-custom-ingress-gateway.md), [Configuring domain names](/serving/using-a-custom-domain.md), and [Feature and extension flags](/serving/configuration/feature-flags.md).

### Encryption

You can apply encryption as needed to your domain and clusters:

- [Configure external domain encryption](/serving/encryption/external-domain-tls.md)
- [Configure cluster-local domain encryption](/serving/encryption/cluster-local-domain-tls.md)
- [Configure Knative system-internal encryption](/serving/encryption/system-internal-tls.md)

### Eventing

The configuration options for eventing comprise the following areas:

- Event sources, see [Configure event source defaults](/eventing/configuration/sources-configuration.md) and also refer to [Knative reference mapping](/eventing/features/kreference-mapping.md).
- Brokers. See [Developer configuration options](/eventing/brokers/broker-developer-config-options.md) and [Configure Broker defaults](/eventing/configuration/broker-configuration.md) for an overview of broker configurations and an example.
- Kafka, a distributed event store and stream-processing platform. See [Configure Kafka features](/eventing/brokers/broker-types/kafka-broker/configuring-kafka-features.md) and [Configure Apache Kafka Channel defaults](/eventing/configuration/kafka-channel-configuration.md). See also [Configure KEDA Autoscaling of Knative Kafka Resources](/eventing/configuration/keda-configuration.md)
- Istio, a programmable, application-aware network. See [Eventing with Istio](/eventing/features/istio-integration.md).
- Channels. See [Configure Channel defaults](/eventing/configuration/channel-configuration.md).

## Monitoring

Knative is instrumented with OpenTelemetry. For metrics, see the [Metrics Reference](/serving/observability/metrics/serving-metrics.md) and [Collecting metrics](/serving/observability/metrics/collecting-metrics.md). You can access [CloudEvents traces](/serving/observability/accessing-traces.md).

For logging Serving activity, see [Collecting logs](/serving/observability/logging/collecting-logs.md), [Configuring logging](/serving/observability/logging/config-logging.md), and [Configuring Request logging](/serving/observability/logging/request-logging.md).

For logging Eventing activity, see [Collecting logs](/eventing/observability/logging/collecting-logs.md) and [Configuring logging](/eventing/observability/logging/config-logging.md).

## Enforcing security

For access control, see [Transport Encryption](/eventing/features/transport-encryption.md), [Sender Identity](/eventing/features/sender-identity.md), and [cert-manager](/install/installing-cert-manager.md).

## Updates and Maintenance

For Knative updates, see [About upgrading Knative](/install/upgrade/README.md) and [Checking your Knative version](/install/upgrade/check-install-version.md). The current Knative version is the shown in the version drop-down in the upper-left corner of this page. Refer to  [Upgrading with the Knative Operator](/install/upgrade/upgrade-installation-with-operator.md) or [Upgrading with kubectl](/install/upgrade/upgrade-installation.md).
