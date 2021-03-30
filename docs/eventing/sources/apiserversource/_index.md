---
title: "API server source"
weight: 01
type: "docs"
aliases:
  - /docs/eventing/sources/apiserversource
---

![version](https://img.shields.io/badge/API_Version-v1-red?style=flat-square)

The API server source is a Knative Eventing Kubernetes custom resource definition (CRD) that listens for Kubernetes events and forwards received events to a sink.

The API server source is part of the core Knative Eventing component, and is provided by default when Knative Eventing is installed. Multiple instances of an `ApiServerSource` object can be created by users.

## Reference Documentation

See the [APIServerSource specification](../../reference/api/eventing/#sources.knative.dev/v1.APIServerSource).
