---
title: "Sink binding"
weight: 01
type: "docs"
aliases:
    - /docs/eventing/samples/sinkbinding/index
    - /docs/eventing/samples/sinkbinding/README
    - /docs/eventing/sources/sinkbinding.md
---

![API version v1](https://img.shields.io/badge/API_Version-v1-red?style=flat-square)

The `SinkBinding` custom object supports decoupling event production from delivery addressing.

You can use a SinkBinding to direct an subject to an event sink.
The _Subject_ is a Kubernetes resource that embeds a `PodSpec` template and produces events.
The _Event sink_ is an addressable Kubernetes object that can receive events.

To create new subjects you can use any of the compute objects that Kubernetes makes available such as:
- `Deployment`
- `Job`
- `DaemonSet`
- `StatefulSet`

You can also create new subjects that use Knative abstractions, such as `Service` or `Configuration` objects.

The SinkBinding injects environment variables into the `PodTemplateSpec` of the event sink.
Because of this, the application code does not need to interact directly with the
Kubernetes API to locate the event destination.
