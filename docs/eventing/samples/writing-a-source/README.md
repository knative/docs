
This tutorial walks you through creating an event source for Knative Eventing
"the hard way", without using helper objects like ContainerSource.

After completing through this tutorial, you'll have a basic working event source
controller and dispatcher (TODO) based on the Kubebuilder framework.

Just want to see the code? The reference project is
https://github.com/grantr/sample-source.

## Target Audience

The target audience is already familiar with Kubernetes and Go development and
wants to develop a new event source for use with Knative Eventing.

## Before you begin

You'll need these tools installed:

- git
- golang
- make
- [dep](https://github.com/golang/dep)
- [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)
- [kustomize](https://github.com/kubernetes-sigs/kustomize)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (optional)
- [minikube](https://github.com/kubernetes/minikube) (optional)

## Steps

1. [Bootstrap Project](01-bootstrap.md)
1. [Define The Source Resource](02-define-source.md)
1. [Reconcile Sources](03-reconcile-sources.md)
1. [Publish to Cluster](04-publish-to-cluster.md)
1. Dispatching Events

## Alternatives

Kubebuilder not your thing? Prefer the easy way? Check out these alternatives.

- [ContainerSource](../../../eventing/sources/README.md#meta-sources)
  is an easy way to turn any dispatcher container into an Event Source.
- [Auto ContainerSource](../../../eventing/sources/README.md#meta-sources)
  is an even easier way to turn any dispatcher container into an Event Source
  without writing any controller code. It requires Metacontroller.
- [Metacontroller](https://metacontroller.app) can be used to write controllers
  as webhooks in any language.
- The [Cloud Scheduler source](https://github.com/vaikas-google/csr) uses the
  standard Kubernetes Golang client library instead of Kubebuilder.
