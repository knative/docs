# Eventing Background and CloudEvents

## Background
**With Knative Serving, we have a powerful tool which can take our containerized code and deploy it with relative ease.** With Knative Eventing, you gain a few new super powers :rocket:.

Namely, the ability to easily communicate between Knative Services, plug external data sources into your Kubernetes cluster and even create your own "Functions as a Service" on top of Kubernetes. **In short, Knative Eventing provides a scalable, fault-tolerant infrastructure for communication between workloads.**


For the purposes of this tutorial, we will focus on four components for building this communication infrastructure **(`Source`, `Trigger`, `Broker`, and `Sink`)**, but there are many other tools in the Knative Eventing toolbox.

??? question "What other components exist in Knative Eventing?"
    If you want to find out more about the different components of Knative Eventing, like Channels, Sequences, Parallels, etc. check out ["Eventing Components."](../eventing/README.md)


## Introducing CloudEvents
Knative Eventing uses <a href="https://github.com/cloudevents/spec/blob/master/primer.md" target="blank_">CloudEvents</a> to communicate between workloads.

For our purposes, the only thing you need to know about CloudEvents are:

1. CloudEvents follow the <a href = "https://github.com/cloudevents/spec" target="_blank">CloudEvents 1.0 Specification</a>, with required and optional attributes.
1. CloudEvents can be "emitted" by almost anything and can be transported to anywhere in your deployment.  
1. CloudEvents can carry some attributes (things like `id`, `source`, `type`, etc) as well as data payloads (JSON, plaintext, reference to data that lives elsewhere, etc).

??? question "Want to find out more about CloudEvents?"
    Check out the [CloudEvents website](https://cloudevents.io/)!
