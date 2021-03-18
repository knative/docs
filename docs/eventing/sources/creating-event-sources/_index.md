---
title: "Creating an event source"
weight: 100
type: "docs"
---

You can create your own event source for use with Knative Eventing components by using the following methods:

- By using a [ContainerSource](../containersource) which, which is a simple way to turn any dispatcher container into a Knative event source.
- By using [SinkBinding](../sinkbinding), which provides a framework for injecting environment variables into any Kubernetes resource that has a `spec.template` and is [PodSpecable](https://pkg.go.dev/knative.dev/pkg/apis/duck/v1#PodSpecable).
- By creating your own event source controller, receiver adapter, and custom resource definition (CRD).
