---
title: "Administration guide"
weight: 10
type: "docs"
showlandingtoc: "true"
---

There are two core Knative components that can be installed and used together or independently to provide different functions:

* [Knative Serving](../serving/): Easily manage stateless services on Kubernetes by reducing the developer effort required for autoscaling, networking, and rollouts.

* [Knative Eventing](../eventing/): Easily route events between on-cluster and off-cluster components by exposing event routing as configuration rather than embedded in code.

These components are delivered as Kubernetes custom resource definitions (CRDs), which can be configured by a cluster administrator to provide default settings for developer-created applications and event workflow components.
