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

- Serving. Pods and pluggable network ingress routes.
- Eventing: Pods and pluggable message transports (e.g. Kafka, RabbitMQ)

Knative has default lightweight implementations if you don't already have a solution.

This article outlines major Knative functionality and provides links to detailed procedures as applicable for administrators. It covers the following processes:

- Installing
- Configuring
- Monitoring
- Enforcing security
- Updating and maintaining

## Installing

Use the [Installation Roadmap](../install/README.md#installation-roadmap) for guidance on installing Knative using the resources and tool choices that best fit your needs. You can install using YAML manifests or a Kubernetes operator; the operator supports management via the `kn` CLI.

The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components.

You can install Knative components in three ways:

- Use a [YAML-based installation](/install/yaml-install/README.md)
- Use the [Knative Operator CLI plugin](/install/operator/knative-with-operator-cli.md)
- Use the [Knative Operator](/install/operator/knative-with-operators.md) with YAML resource files and the `kubectl` CLI.

Knative supports subsequent installs after the initial installation, you so your initial choices don't lock you in. For example, you can migrate from one message transport or network ingress to another without losing messages.

### YAML and CLI installations compared

The YAML-based installation provides opportunities to achieve customizable outcomes and define the desired state of the system, along with the following capabilities:

- Version and audit control. YAML files are typically stored in a GitHub repository.
- Infrastructure as Code (IaC).
- Collaboration and roll back to previous configurations.
- Complex configurations.

THe CLI-based installation provides a great quick start for basic operations and tasks and understanding and testing the capabilities of Knative. However, it can be harder to track the current state and to maintain version control for components.

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
