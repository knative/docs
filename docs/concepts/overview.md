---
title:  "Overview"
weight: 5
type: "docs"
---

This document contains a quick overview of Knative.

Knative (pronounced kay-native) is a set of open source components for [Kubernetes](https://kubernetes.io) that implements
functionality to:

* run stateless workloads, such as microservices
* support event subscription, delivery, and handling 

on Kubernetes clusters.

Knative is implemented as a set of [controllers](https://kubernetes.io/docs/concepts/architecture/controller/) you install
on your Kubernetes cluster. Knative registers its own API types to the Kubernetes API, so working with it is not 
too different from working with Kubernetes itself.

Knative consists of two independent components that have their own GitHub projects:

* [Knative Serving](https://knative.dev/docs/serving/): Run stateless services more easily on Kubernetes, 
   by making autoscaling, networking and rollouts easier. 

* [Knative Eventing](https://knative.dev/docs/eventing/): Create subscriptions to event sources declaratively, 
   and route events to Kubernetes endpoints. 

You can use either one or both components in your cluster.

**Note**: Earlier versions of Knative included a Build component.  That component has been broken out into its own
project, [Tekton Pipelines](https://tekton.dev/).
