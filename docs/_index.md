---
title: "Welcome to Knative"
linkTitle: "Documentation"
weight: 10
type: "docs"
---

Knative extends Kubernetes to provide developers with a set of tools that simplify the process of deploying and managing event-driven applications that can run anywhere.

Developers using Knative can use familiar languages and frameworks to solve common use cases, such as:

- [Deploying a container](./serving/getting-started-knative-app.md)
- [Routing and managing traffic with blue/green deployment](./serving/samples/blue-green-deployment.md)
- [Scaling automatically and sizing workloads based on demand](./serving/autoscaling)
- [Binding running services to eventing ecosystems](./eventing/getting-started.md)

## How it works

Knative consists of the [Knative Serving](./serving) and [Knative Eventing](./eventing) components.

These components are delivered as Kubernetes custom resource definitions (CRDs), which can be configured by a cluster administrator to provide default settings for developer-created applications and event workflow components.

Follow the links below to learn more about Knative.

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
