---
title: "Eventing Flows"
linkTitle: "Flows"
weight: 31
type: "docs"
showlandingtoc: "false"
---

# Eventing Flows

Knative Eventing provides a collection of [custom resource definitions (CRDs)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that you can use to define event flows:

* [Sequence](./sequence) is for defining an in-order list of functions.
* [Parallel](./parallel) is for defining a list of branches, each receiving the same CloudEvent.
