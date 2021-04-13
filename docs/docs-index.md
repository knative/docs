---
title: "Welcome to Knative"
linkTitle: "Documentation"
weight: 10
type: "docs"
showlandingtoc: "false"
aliases:
   - /docs/concepts/overview.md
---

# Welcome to Knative

The Knative project provides a set of [Kubernetes](https://kubernetes.io) components that introduce event-driven and serverless capabilities for Kubernetes clusters.

Knative APIs build on existing Kubernetes APIs, so that Knative resources are compatible with other Kubernetes-native resources, and can be managed by cluster administrators using existing Kubernetes tools.

Common languages and frameworks that include Kubernetes-friendly tooling work smoothly with Knative to reduce the time spent solving common deployment issues, such as:

- [Deploying a container](./serving/getting-started-knative-app/)
- [Routing and managing traffic with blue/green deployment](./serving/samples/blue-green-deployment/)
- [Scaling automatically and sizing workloads based on demand](./serving/autoscaling/)
- [Binding running services to eventing ecosystems](./eventing/getting-started/)

There are two core Knative components that can be installed and used together or independently to provide different functions:

* [Knative Serving](./serving/): Easily manage stateless services on Kubernetes by reducing the developer effort required for autoscaling, networking, and rollouts.

* [Knative Eventing](./eventing/): Easily route events between on-cluster and off-cluster components by exposing event routing as configuration rather than embedded in code.

These components are delivered as Kubernetes custom resource definitions (CRDs), which can be configured by a cluster administrator to provide default settings for developer-created applications and event workflow components.

**Note**: Earlier versions of Knative included a build component.  That component has since evolved into the separate [Tekton Pipelines](https://tekton.dev/) project.

### Getting started

- [Installing Knative](./install/)
- [Getting started with app deployment](./serving/getting-started-knative-app/)
- [Getting started with serving](./serving/)
- [Getting started with eventing](./eventing/)

### Configuration and networking

- [Using a custom domain](./serving/using-a-custom-domain/)
- [Assigning a static IP address for Knative on Google Kubernetes Engine](./serving/gke-assigning-static-ip-address/)
- [Configuring HTTPS with a custom certificate](./serving/using-a-tls-cert/)
- [Configuring high availability](./serving/config-ha/)

### Samples and demos

- [Autoscaling](./serving/autoscaling/autoscale-go/)
- [Binding running services to eventing ecosystems](./eventing/samples/kubernetes-event-source/)
- [REST API sample](./serving/samples/rest-api-go/)
- [All samples for serving](./serving/samples/)
- [All samples for eventing](./eventing/samples/)

### Debugging

- [Debugging application issues](./serving/debugging-application-issues/)
