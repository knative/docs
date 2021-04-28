# Introducing the Knative Eventing

## Background
With Knative Serving, we have a powerful tool which can take our containerized code and deploy it with relative ease. **With Knative Eventing, you gain a few new super powers :rocket: that allow you to build Event-Driven Applications.**

??? question "What are Event Driven Applications?"
    Event-driven applications are designed to detect events as they occur, and then deal with them using some event-handling procedure. Producing "events" to detect and consuming events with an "event-handling procedure" is precisely what Knative Eventing enables.

==**Knative Eventing acts as the "glue" between the disparate parts of your architecture**== and allows you to easily communicate between those parts in a fault-tolerant way. Some examples include:

1. [Creating and responding to Kubernetes API events](../../eventing/sources/apiserversource/)
1. [Creating an image processing pipeline](https://www.youtube.com/watch?v=DrmOpjAunlQ)
1. [Facilitating AI workloads at the edge in large-scale, drone-powered sustainable agriculture projects](https://www.youtube.com/watch?v=lVfJ5WEQ5_s).

As you can see by the examples above, **Knative Eventing implementations can range from the dead simple to extremely complex**, the concepts you'll learn will be a great starting point to accomplish either.
