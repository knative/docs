# Creating an event source

There are several methods that can be used to create your own Knative event source. The aim of these methods is to ensure that contributing a new source to the Knative project, or creating a source for your own personal use, requires minimal knowledge of the inner workings of Kubernetes or related controllers.

## Design principles of event sources

When you create an event source for Knative, the following design principles must be taken into account:

* Cluster administrators must be able to easily install new sources, and verify that they are safe to install and use.
* Developers must be able to easily discover what event sources are available on a Knative cluster.
<!--TODO: mention / link to information about discovery API?-->
* Sources must be simple to configure based on similarities in structure to existing sources. This is achieved by using [_duck typing_](../../../../concepts/#duck-typing).

## Methods of creating an event source

You can create your own event source by using one of the following methods:

- [Knative sandbox sample source](../creating-event-sources/using-the-sandbox-sample-source)
<!--TODO: Provide links to docs about what the event source controller and receiver adapter are-->
<!-- Is Go required? Is this for all Knative development or just event source creation?-->
- Build an event source in Javascript, and implement it using a ContainerSource or SinkBinding.
- By creating your own event source controller, receiver adapter, and custom resource definition (CRD).
