# Welcome to Knative

The Knative project provides a set of [Kubernetes](https://kubernetes.io) components that introduce event-driven and serverless capabilities for Kubernetes clusters.

Knative APIs build on existing Kubernetes APIs, so that Knative resources are compatible with other Kubernetes-native resources, and can be managed by cluster administrators using existing Kubernetes tools.

Common languages and frameworks that include Kubernetes-friendly tooling work smoothly with Knative to reduce the time spent solving common deployment issues, such as:

- [Routing and managing traffic with blue/green deployment](developer/serving/traffic-management.md#routing-and-managing-traffic-with-blue-green-deployment)
- [Scaling automatically and sizing workloads based on demand](serving/autoscaling/README.md)
- [Binding running services to eventing ecosystems](eventing/getting-started.md)

There are two core Knative components that can be installed and used together or independently to provide different functions:

* [Knative Serving](serving/README.md): Easily manage stateless services on Kubernetes by reducing the developer effort required for autoscaling, networking, and rollouts.

* [Knative Eventing](eventing/README.md): Easily route events between on-cluster and off-cluster components by exposing event routing as configuration rather than embedded in code.

These components are delivered as Kubernetes custom resource definitions (CRDs), which can be configured by a cluster administrator to provide default settings for developer-created applications and event workflow components.

**Note**: Earlier versions of Knative included a build component.  That component has since evolved into the separate [Tekton Pipelines](https://tekton.dev/) project.

### Getting started

- [Installing Knative](admin/install/README.md)
- [Getting started with serving](serving/README.md)
- [Getting started with eventing](eventing/README.md)

### Configuration and networking

- [Using a custom domain](serving/using-a-custom-domain.md)
- [Configuring HTTPS with a custom certificate](serving/using-a-tls-cert.md)
- [Configuring high availability](serving/config-ha.md)

### Samples and demos

- [Autoscaling](serving/autoscaling/autoscale-go/README.md)
- [REST API sample](serving/samples/rest-api-go/README.md)
- [All samples for serving](serving/samples/README.md)
- [All samples for eventing](eventing/samples/README.md)

### Observability

- [Serving Metrics](admin/collecting-metrics/serving-metrics/metrics.md)
- [Eventing Metrics](admin/collecting-metrics/eventing-metrics/metrics.md)
- [Collecting metrics](admin/collecting-metrics/README.md)

### Debugging

- [Debugging application issues](developer/serving/troubleshooting/debugging-application-issues.md)
