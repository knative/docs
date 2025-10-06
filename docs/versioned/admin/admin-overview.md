---
audience: administrator
components:
  - serving
  - eventing
function: reference
---
# Overview

This page provides guidance for administrators on how to install and manage Knative on an existing Kubernetes cluster, and assumes you have familiarity the following:

- Kubernetes and Kubernetes administration.
- The `kubectl`CLI tool. You can use existing Kubernetes management tools (policy, quota, etc) to manage Knative workloads.
- The Cloud Native Computing Foundation (CNCF) for which Knative is one of its projects, along with Kubernetes, Prometheus, and Istio.

Additionally, you should have cluster-admin permissions or equivalent to to install software and manage resources in all clusters in the namespace.

To simplify Knative installation and administration, you can use the Knative operator and the Knative CLI tool, but they are not required.

Essentially, Knative aims to extend Kubernetes, and build on existing capabilities where feasible. It has two main underlying components that support plugging in multiple underlying transports within the same cluster:

- Serving: Pods and pluggable network ingress routes.
- Eventing: Pods and pluggable message transports (e.g. Kafka, RabbitMQ)

Knative has default lightweight implementations if you don't already have a solution.

## Installing Knative

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

## Defining and modifying custom resources

Either before or after the installing Knative Eventing and Serving components, you can create and modify custom resources and reinstall components as needed. You do so by creating or modifying a ConfigMap using a custom resource definition (CRD).

You customize resources using `kubectl` using the Knative Operator using `kn`. See [Knative Serving CRDs](/install/operator/configuring-serving-cr.md) and [Knative Eventing CRDs](/install/operator/configuring-eventing-cr.md).

The following table lists the names of CRDs (metadata name) for the Serving and Eventing components. They are defined by `eventing-crds.yaml` and `serving-crds.yaml` in the [Knative Eventing installation files](/install/yaml-install/eventing/eventing-installation-files.md) and [Knative Serving installation Files](/install/yaml-install/serving/serving-installation-files.md), respectively.

| Eventing CRDs | Serving CRDs |
| --- | --- |
| brokers.eventing.knative.dev<br>channels.messaging.knative.dev<br>eventpolicies.eventing.knative.dev<br>eventtransforms.eventing.knative.dev<br>eventtypes.eventing.knative.dev<br>integrationsinks.sinks.knative.dev<br>jobsinks.sinks.knative.dev<br>parallels.flows.knative.dev<br>requestreplies.eventing.knative.dev<br>sequences.flows.knative.dev<br>subscriptions.messaging.knative.dev<br>triggers.eventing.knative.dev | certificates.networking.internal.knative.dev<br>configurations.serving.knative.dev<br>clusterdomainclaims.networking.internal.knative.dev<br>domainmappings.serving.knative.dev<br>ingresses.networking.internal.knative.dev<br>metrics.autoscaling.internal.knative.dev<br>podautoscalers.autoscaling.internal.knative.dev<br>revisions.serving.knative.dev<br>routes.serving.knative.dev<br>serverlessservices.networking.internal.knative.dev<br>services.serving.knative.dev<br>images.caching.internal.knative.dev |

### Recommended plugins

You can also install these plugins service to extend Knative capabilities for service meshes:

- [Istio for Knative](/install/installing-istio.md) - Extends Kubernetes with a programmable, application-aware network.
- [Knative Backstage plugin](/install/installing-backstage-plugins.md) - An Event Mesh that allows you to view and manage Knative Eventing resources.
- [cert-manager](/install/installing-cert-manager.md) - Provision and manage TLS certificates in Kubernetes.

## Administration tasks

The following table lists configurations, extensibility, conversions, and other actions for Knative Administrators organized by technical area. Tasks are linked to procedures and other guidance.

Several of the tasks use the ConfigMaps object to store new data or update existing resources. ConfigMaps are namespace-scoped, meaning they are available to all Pods within the same namespace. To create a ConfigMap, use the `kubectl create configmap` command. To modify a ConfigMap use the `kubectl apply` command with the supplied YAML manifest.

Do not remove or modify the `_example` data entries in ConfigMaps. Doing so will cause a system warning.

| Area | Task | Description |
| --- | --- | --- |
| Access control | [cert-manager integration](/serving/encryption/configure-certmanager-integration.md) | Enable cert-manager for automated certificate provisioning. |
|  | [Request authorization for Knative services](/serving/istio-authorization.md) | Grant access to deployed services to system pods, such as the activator and autoscaler components. |
|  | [Sender identity for delivering events](/eventing/features/sender-identity.md) | Enable sender's identity to be obtained on event deliveries. |
| Autoscaling and High Availability | [Autoscaler supported types](/serving/autoscaling/autoscaler-types.md) | Lists the features and limitations of each of the autoscalers. |
|  | [Autoscaling of Knative Kafka Resources](/eventing/configuration/keda-configuration.md) | Enable autoscaling of Kafka components. |
|  | [Concurrency](/serving/autoscaling/concurrency.md) | Sets the number of simultaneous requests that can be processed by each replica of an application. |
|  | [High-availability](/serving/config-ha.md) | Configure and scale high availability so that components stay operational if a disruption occurs. |
|  | [Metrics configuration](/serving/autoscaling/autoscaling-metrics.md) | Define which metric type are watched by the Autoscaler. |
| | [Requests per second](/serving/autoscaling/rps-target.md) | Sets a target for requests-per-second per replica of an application. |
|  | [Scale bounds configuration](/serving/autoscaling/scale-bounds.md) | Configure upper and lower bounds to control autoscaling behavior. |
|  | [Scale to zero](/serving/autoscaling/scale-to-zero.md ) | Enable replicas to scale down to zero. |
|  | [Targets configuration](/serving/autoscaling/autoscaling-targets.md) | Configure values for the autoscaler to maintain for a revision. |
| Events | [Broker defaults](/eventing/configuration/broker-configuration.md) | Modify ConfigMaps to change options for Brokers on the cluster. |
|  | [Channel defaults](/eventing/configuration/channel-configuration.md) | Configure default ConfigMap values for creating channel instances. |
|  | [Channel defaults Apache Kafka ](/eventing/configuration/kafka-channel-configuration.md) | Configure default ConfigMap values for creating Apache Kafka channel instances. |
|  | [Event source defaults](/eventing/configuration/sources-configuration.md) | Configure defaults for Knative event sources for generating events. |
|  | [Istio integration](/eventing/features/istio-integration.md) | Enable Istio to encrypt, authenticate and authorize requests. |
|  | [Knative reference mapping](/eventing/features/kreference-mapping.md) | Allows you to provide mappings from a Knative reference to a templated URI. |
|  | [Sugar Controller](/eventing/configuration/sugar-configuration.md) | Configure the Sugar Controller, which reacts to configured labels to create and control eventing resources in a cluster or namespace. |
| Knative upgrades and maintenance | [Check Knative version](/install/upgrade/check-install-version.md) | Determine the current installed version of Knative. |
|  | [Uninstall Knative](/install/uninstall) | Uninstall YAML-based installations or Knative Operator installations. |
| | [Upgrade using Knative Operator](/install/upgrade/upgrade-installation-with-operator.md) | Upgrade Knative using YAML manifests. |
|  | [Upgrade using kubectl](/install/upgrade/upgrade-installation.md) | Upgrade Knative using the kubectl CLI. |
| Networking | [Domain names](/serving/using-a-custom-domain.md) | Set the domain names of an individual Knative Service, or set a global default domain for all services created on a cluster.  |
|  | [Ingress gateway](/serving/setting-up-custom-ingress-gateway.md) | Shows how to replace the default gateway for incoming traffic. |
|  | [Webhook bypass on system namespaces](/serving/webhook-customizations.md) | Disable the Knative webhook on system namespaces to avoid issues during upgrades. |
| Observability | [Metrics](/eventing/observability/metrics/eventing-metrics.md) | Monitor metrics exposed by each Eventing component. |
| Observability | [Metrics](/serving/observability/metrics/serving-metrics.md) | Monitor metrics exposed by each Serving component. |
| Security | [Cluster-local domain encryption](/serving/encryption/cluster-local-domain-tls.md) | Enable or disable HTTPS connections to your Knative Services for the cluster-local domain. (Experimental) |
|  | [External domain encryption](/serving/encryption/external-domain-tls.md) | Enable or disable HTTPS connections to your Knative Services for the external domain. |
|  | [System-internal encryption](/serving/encryption/system-internal-tls.md) | Enable or disable HTTPS connections to your Knative Services for the internal system. (Experimental) |
|  | [Transport encryption](/eventing/features/transport-encryption.md) | Enable a service mesh or encrypted CNI to encrypt the traffic. |
| Services | [Deployment resources](/serving/configuration/deployment.md) | Configure the ConfigMap for how Kubernetes deploys resources. |
|  | [Feature and extension flags](/serving/configuration/feature-flags.md) | A reference for extending the Knative API for deployments. |
|  | [Kubernetes to Knative conversions](/serving/convert-deployment-to-knative-service.md) | Convert a Kubernetes deployment to a Knative service. |
|  | [Queue Proxy image with QPOptions](/serving/queue-extensions.md) | Allows additional runtime packages to extend Queue Proxy capabilities. |
|   | [Defaults ConfigMap](/serving/configuration/config-defaults.md) | Configure the Defaults ConfigMap, for default values for resources. |
