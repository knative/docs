# Introducing the Knative Eventing

## Background
With Knative Serving, we have a powerful tool which can take our containerized code and deploy it with relative ease. **With Knative Eventing, you gain a few new super powers :rocket: that allow you to build Event-Driven Applications.**

??? question "What are Event Driven Applications?"
    Event-driven applications are designed to react to events as they occur, and then deal with them using some event-handling procedure. Producing "events" to detect and consuming events with an "event-handling procedure" is precisely what Knative Eventing enables.

==**Knative Eventing acts as the "glue" between the disparate parts of your architecture**== and allows you to easily communicate between those parts in a fault-tolerant way. Some examples include:

1. [Creating and responding to Kubernetes API events](../../eventing/sources/apiserversource/)
1. [Creating an image processing pipeline](https://www.youtube.com/watch?v=DrmOpjAunlQ)
1. [Facilitating AI workloads at the edge in large-scale, drone-powered sustainable agriculture projects](https://www.youtube.com/watch?v=lVfJ5WEQ5_s).

As you can see by the examples above, **Knative Eventing implementations can range from the dead simple to extremely complex**, the concepts you'll learn will be a great starting point to accomplish either.

### CloudEvents
Knative Eventing uses <a href="https://github.com/cloudevents/spec/blob/master/primer.md" target="blank_">CloudEvents</a> send information back and forth between your Services and these components.

??? question "What are CloudEvents?"
    For our purposes, the only thing you need to know about CloudEvents are:

    1. CloudEvents follow the <a href = "https://github.com/cloudevents/spec" target="_blank">CloudEvents 1.0 Specification</a>, with required and optional attributes.
    1. CloudEvents can be "emitted" by almost anything and can be transported to anywhere in your deployment.  
    1. CloudEvents can carry some attributes (things like `id`, `source`, `type`, etc) as well as data payloads (JSON, plaintext, reference to data that lives elsewhere, etc).

    To find out more about CloudEvents, check out the [CloudEvents website](https://cloudevents.io/)!

