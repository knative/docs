# Writing an Event Source the Hard Way

This tutorial walks you through creating an event source for Knative Eventing
"the hard way", without using helper objects like ContainerSource.

After completing through this tutorial, you'll have a basic working event source
controller and dispatcher (TODO) based on the Kubebuilder framework.

Just want to see the code? The reference project is
https://github.com/grantr/sample-source.

## Target Audience

The target audience is already familiar with Kubernetes and wants to develop a
new event source in Golang for use with Knative Eventing.

## Alternatives

Kubebuilder not your thing? Prefer the easy way? Check out these alternatives.

*   [ContainerSource](https://github.com/knative/docs/tree/master/eventing/sources#meta-sources)
    is an easy way to turn any dispatcher container into an Event Source.
*   [Auto ContainerSource](https://github.com/knative/docs/tree/master/eventing/sources#meta-sources)
    is an even easier way to turn any dispatcher container into an Event Source
    without writing any controller code. It requires Metacontroller.
*   [Metacontroller](https://metacontroller.app) can be used to write
    controllers as webhooks in any language.
*   The [GitLab source](https://gitlab.com/triggermesh/gitlabsource) uses the
    Python Kubernetes client library.
*   The [Cloud Scheduler source](https://github.com/vaikas-google/csr) uses the
    standard Kubernetes Golang client library instead of Kubebuilder.

## Labs

*   [Prerequisites](01-prerequisites.md)
*   [Bootstrap Project](02-bootstrap.md)
*   [Define The Source Resource](03-define-source.md)
*   [Reconcile Sources](04-reconcile-sources.md)
*   [Publish to Cluster](05-publish-to-cluster.md)
*   [Dispatching Events](06-dispatching-events.md)
