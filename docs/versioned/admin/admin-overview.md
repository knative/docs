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

The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components. You can [Install by using the Knative Operator CLI plugin](/install/operator/knative-with-operator-cli.md), or you can install it using manifest resources.

You can install Knative components in three ways:

- Use a [YAML-based installation](/install/yaml-install/README.md)
- Use the [Knative Operator CLI plugin](/install/operator/knative-with-operator-cli.md)
- Use the [Knative Operator](/install/operator/knative-with-operators.md) with YAML resource files:

    - [Knative Serving installation files](/install/yaml-install/serving/serving-installation-files.md)
    - [Knative Eventing installation files](/install/yaml-install/eventing/eventing-installation-files.md)

You can [Configuring Knative using the Operator](/install/operator/configuring-with-operator.md) and define custom resource definitions:

- [Knative Serving CRDs](/install/operator/configuring-serving-cr.md)
- [Knative Eventing CRDs](/install/operator/configuring-eventing-cr.md)

You can also install service and event mesh plugins:

- [Istio for Knative](/install/installing-istio.md)
- [Knative Backstage plugin](/install/installing-backstage-plugins.md)

For un-installations, see [Uninstalling Knative](/install/uninstall.md).

## Configurations

Knative provides optimization capabilities for the Serving and Eventing components and settings for administering your clusters.

For the Serving component, you can configure autoscaling, high availability, load balancing, authentication, domains, gateways, and other settings.

For the Eventing component, you can configure Brokers that facilitate the routing and management of events. You can configure and process event data with Apache Kafka. You can also install and configure Istio for your traffic management and telemetry needs.

## Monitoring and Observability

Both the Serving and Eventing components are integrated with OpenTelemetry and provide logging, tracing, and metric collections.

## Security

Knative integrates with existing security and access control measures with the certificate manager, networking TLS certificates, domain and cluster encryption, and application security.

## Updates and Maintenance

In addition to updates, Knative provides integration with existing components for resource limits and volumes.

