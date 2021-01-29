---
title: "Welcome to Knative"
linkTitle: "Documentation"
weight: 10
type: "docs"
aliases:
   - /docs/concepts/overview.md
---

The Knative project provides a set of [Kubernetes controllers](https://kubernetes.io/docs/concepts/architecture/controller/) that help to simplify developer and administrator experiences on [Kubernetes](https://kubernetes.io) clusters, by introducing an event-driven, serverless architecture.

There are two core Knative components, that can be installed and used together or independently to provide different functions:

* [Knative Serving](https://knative.dev/docs/serving/): Run stateless services more easily on Kubernetes,
   by making autoscaling, networking and rollouts easier.

* [Knative Eventing](https://knative.dev/docs/eventing/): Create subscriptions to event sources declaratively,
   and route events to Kubernetes endpoints.

These components are delivered as Kubernetes custom resource definitions (CRDs), which can be configured by a cluster administrator to provide default settings for developer-created applications and event workflow components.

**Note**: Earlier versions of Knative included a Build component.  That component has been broken out into its own
project, [Tekton Pipelines](https://tekton.dev/).

Knative registers its own API types to the Kubernetes API, enabling developers and cluster administrators to use familiar languages and frameworks to solve common use cases, such as:

- [Deploying a container](./serving/getting-started-knative-app.md)
- [Routing and managing traffic with blue/green deployment](./serving/samples/blue-green-deployment.md)
- [Scaling automatically and sizing workloads based on demand](./serving/autoscaling)
- [Binding running services to eventing ecosystems](./eventing/getting-started.md)

### Getting started

- [Installing Knative](./install/README.md)
- [Getting started with app deployment](./serving/getting-started-knative-app.md)
- [Getting started with serving](./serving)
- [Getting started with eventing](./eventing)

### Configuration and networking

- [Using a custom domain](./serving/using-a-custom-domain.md)
- [Assigning a static IP address for Knative on Google Kubernetes Engine](./serving/gke-assigning-static-ip-address.md)
- [Configuring HTTPS with a custom certificate](./serving/using-a-tls-cert.md)
- [Configuring high availability](./serving/config-ha.md)

### Samples and demos

- [Autoscaling](./serving/autoscaling/autoscale-go/)
- [Binding running services to eventing ecosystems](./eventing/samples/kubernetes-event-source/)
- [REST API sample](./serving/samples/rest-api-go/README.md)
- [All samples for serving](./serving/samples/)
- [All samples for eventing](./eventing/samples/)

### Debugging

- [Debugging application issues](./serving/debugging-application-issues.md)
