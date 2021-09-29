# SinkBinding

![API version v1](https://img.shields.io/badge/API_Version-v1-green?style=flat-square)

The SinkBinding object supports decoupling event production from
delivery addressing.

You can use sink binding to direct a subject to a sink.
A _subject_ is a Kubernetes resource that embeds a PodSpec template and produces events.
A _sink_ is an addressable Kubernetes object that can receive events.

The SinkBinding object injects environment variables into the PodTemplateSpec of the
sink. Because of this, the application code does not need to interact
directly with the Kubernetes API to locate the event destination.
These environment variables are as follows:

- `K_SINK` - The URL of the resolved sink.
- `K_CE_OVERRIDES` - A JSON object that specifies overrides to the outbound
  event.
