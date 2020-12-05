Knative Eventing provides a collection of [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
for describing event flows:
* [Sequence](./sequence.md) is for defining an in-order list of functions.
* [Parallel](./parallel.md) is for defining a list of branches, each receiving the same CloudEvent.
