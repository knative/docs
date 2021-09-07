# Eventing Flows

Knative Eventing provides a collection of [custom resource definitions (CRDs)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that you can use to define event flows:

* [Sequence](sequence/README.md) is for defining an in-order list of functions.
* [Parallel](parallel.md) is for defining a list of branches, each receiving the same CloudEvent.
