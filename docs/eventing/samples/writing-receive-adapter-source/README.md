This tutorial will walk you though writing a new event source for Knative
Eventing using a sample repository and explaining the key concepts used
throughout each component.

After completing the tutorial, you'll have a basic event source controller as
well as receive adapter, which events can be viewed through a basic
event_display Knative Service.

Just want to see the code? The reference project is
[https://github.com/knative/sample-source](https://github.com/knative/sample-source).

## Target Audience

The target audience is already familiar with Kubernetes and Go development and
wants to develope a new event source, importing their custom events via Knative
Eventing into the Knative system.

## Before You Begin

You'll need these tools installed:

- git
- golang
- [ko](https://github.com/google/ko/) (optional)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (optional)
- [minikube](https://github.com/kubernetes/minikube) (optional)

## Steps

1. [Separation of Concerns](./01-theory.md)
2. [API Definition](./02-lifecycle-and-types.md)
3. [Controller](./03-controller.md)
4. [Reconciler](./04-reconciler.md)
5. [Receive Adapter](./05-receive-adapter.md)
6. [Example YAML](./06-yaml.md)
