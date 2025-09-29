---
audience: administrator
components:
  - serving
  - eventing
function: reference
---
# Administration overview

Knative has a comprehensive set of tools and capabilities to administer your Kubernetes clusters. This article provides a overview of Knative features, capabilities, and resources of interest to Kubernetes Administrators, and is organized by the following areas:

- Installation
- Configuration
- Monitoring and Observability
- Security and Access Control
- Updates and Maintenance

## Installation

Use the Installation Roadmap for guidance on installing Knative using the resources and tool choices that best fit your needs. You can install using YAML resources, manifests, or CLI tools that include the Knative operator.

The Knative Operator is a custom controller that extends the Kubernetes API to install Knative components as well as configure your Kubernetes infrastructure accommodating tasks such as installing, deployment, scaling, updates, and recovery.

You can install Knative either by using YAML files or the Knative Operator. The Knative Operator is installed with the Knative Operator CLI plugin, or by using manifest resources.

You can configure customized Knative Serving can customized Eventing resources.

| Concepts and Procedures | Reference |
| --- | --- |
| Install Serving with YAML<br>Install Eventing with YAML<br>Install by using the Knative Operator<br>Install by using the Knative Operator CLI plugin<br>Configuring Knative using the Operator<br>Configuring Knative Serving CRDs<br>Configuring Knative Eventing CRDs<br>Install Knative Backstage plugin<br> | Knative Serving installation files<br>Knative Eventing installation files |

## Configurations

Knative provides comprehensive optimization capabilities for the Serving and Eventing components and settings for administering your clusters.

For the Serving component, you can configure autoscaling, high availability, load balancing, authentication, domains, gateways, and other settings.

For the Eventing component, you can configure Brokers that facilitate the routing and management of events. You can configure and process event data with Apache Kafka. You can also install and configure Istio for your traffic management and telemetry needs.

| Concepts and Procedures | Reference |
| --- | --- |
| Install Istio for Knative<br>Supported Autoscaler Types<br>Configuring private Services<br>Configuring ingress class<br>Configuring certificate class<br>Configuring custom domains<br>Configuring HTTP<br>Tag resolution<br>Configuring Activator capacity<br>Exclude namespaces from the Knative webhook<br>Configuring high-availability components<br>Configuring the ingress gateway<br>Configuring domain names<br>Configuring Kafka features<br>Channel types and defaults<br>Configure Broker defaults<br>Configure Channel defaults<br>Configure Apache Kafka Channel defaults<br>Configure event source defaults<br>Configure Sugar Controller<br>Configure KEDA Autoscaling of Knative Kafka Resources<br>Knative reference mapping<br>Transport Encryption<br>Sender Identity<br>Eventing with Istio| Administrator configuration options<br>Configuring metrics<br>Configuring targets<br>Configuring scale to zero<br>Configuring concurrency<br>Configuring the requests per second (RPS) target<br>Configuring scale bounds<br>Additional autoscaling configuration for Knative Pod Autoscaler<br>Configure Deployment resources<br>Feature and extension flags<br>Configure the Defaults ConfigMap |

## Monitoring and Observability

Both the Serving and Eventing components are well maintained with logging, tracing, and metric collections.

| Concepts and Procedures | Reference |
| --- | --- |
| Request traces<br>Collecting logs<br>Configuring logging<br>Configuring Request logging<br>Collecting metrics<br>Accessing CloudEvent traces<br>Collecting logs<br>Configuring logging<br>Collecting metrics | Service metrics<br>Metrics Reference |

## Security

Knative provides robust security and access control measures with the certificate manager, networking TLS certificates, domain and cluster encryption, and application security.

| Concepts and Procedures | Reference |
| --- | --- |
| Install cert-manager <br>Using a custom TLS certificate for DomainMapping<br>Configure cert-manager integration<br>Configure external domain encryptio><br>Configure cluster-local domain encryption<br>Configure Knative system-internal encryption<br>Installing Security-Guard<br>Security-guard quickstart<br>Security-Guard example alerts<br>Transport Encryption<br>Sender Identity<br>Verifying Knative Images | Using extensions enabled by QPOptions<br>About Security-Guard<br> |

## Updates and Maintenance

In addition to updates, Knative provides several configurations for maintaining your clusters in optimal condition including resources, volume, traffic, and load balancing.

| Concepts and Procedures | Reference |
| --- | --- |
| About upgrading Knative<br>Checking your Knative version<br>Upgrading with kubectl<br>Upgrading with the Knative Operator<br>Uninstalling Knative<br>About Revisions<br>Configure resource requests and limits<br>Volume Support<br>Traffic management<br>Configuring gradual rollout of traffic to Revisions<br>Deploying from private registries<br>About load balancing<br>Configuring target burst capacity | Developer configuration options |
