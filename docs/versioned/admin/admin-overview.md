---
audience: administrator
components:
  - serving
  - eventing
function: reference
---
# Overview

Knative has a set of tools and capabilities to administer your Kubernetes clusters. This article provides a overview of Knative features, capabilities, and resources of interest to Kubernetes Administrators, and is organized by the following areas:

- Installation
- Configuration
- Monitoring and Observability
- Security and Access Control
- Updates and Maintenance

## Installation

Use the Installation Roadmap for guidance on installing Knative using the resources and tool choices that best fit your needs. You can install using YAML resources, manifests, or CLI tools that include the Knative Operator.

The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components.

You can install Knative components in three ways:

- Use a [YAML-based installation](/install/yaml-install/README.md)
- Use the [Knative Operator CLI plugin](/install/operator/knative-with-operator-cli.md)
- Use the [Knative Operator](/install/operator/knative-with-operators.md) with YAML resource files and the `kubectl` CLI.

    - [Knative Serving installation files](/install/yaml-install/serving/serving-installation-files.md)
    - [Knative Eventing installation files](/install/yaml-install/eventing/eventing-installation-files.md)

You can also install these plugins service to extend Knative capabilities for service meshes and application security:

- [Istio for Knative](/install/installing-istio.md)
- [Knative Backstage plugin](/install/installing-backstage-plugins.md)
- [Installing Security-Guard](/serving/app-security/security-guard-install.md)

For un-installations, see [Uninstalling Knative](/install/uninstall.md).

## Configurations

Knative provides optimization capabilities for the Serving and Eventing components and settings for administering your clusters.

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

You can have apply encryption as needed to your domain and clusters:

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

## Monitoring and Observability

Knative is instrumented with OpenTelemetry. For metrics, see the [Metrics Reference](/serving/observability/metrics/serving-metrics.md) and [Collecting metrics](/serving/observability/metrics/collecting-metrics.md). You can access [CloudEvents traces](/serving/observability/accessing-traces.md).

For logging Serving activity, see [Collecting logs](/serving/observability/logging/collecting-logs.md), [Configuring logging](/serving/observability/logging/config-logging.md), and [Configuring Request logging](/serving/observability/logging/request-logging.md).

For logging Eventing activity, see [Collecting logs](/eventing/observability/logging/collecting-logs.md) and [Configuring logging](/eventing/observability/logging/config-logging.md).

## Security and Access Control

[Security-Guard](/serving/app-security/security-guard-about.md) provides visibility into the security status of applications deployed by Knative Services. See [Verifying Knative Images](/reference/security/verifying-images.md) for verifying binaries for authenticity before deploying.

For access control, see [Transport Encryption](/eventing/features/transport-encryption.md), [Sender Identity](/eventing/features/sender-identity.md), and [cert-manager](/install/installing-cert-manager.md).

## Updates and Maintenance

For Knative updates, see [About upgrading Knative](/install/upgrade/README.md) and [Checking your Knative version](/install/upgrade/check-install-version.md). The current Knative version is the shown in the version drop-down in the upper-left corner of this page. Refer to  [Upgrading with the Knative Operator](/install/upgrade/upgrade-installation-with-operator.md) or [Upgrading with kubectl](/install/upgrade/upgrade-installation.md).
