# Introducing the Knative Eventing

## Background
With Knative Serving, we have a powerful tool which can take our containerized code and deploy it with relative ease. **With Knative Eventing, you gain a few new super powers :rocket:** that allow you to build Event-Driven Applications.

??? question "What are Event Driven Applications?"
    Event-driven applications are designed to detect events as they occur, and then deal with them using some event-handling procedure. Producing and consuming events with an "event-handling procedure" is precisely what Knative Eventing enables.

    Want to find out more about Event-Driven Architecture and Knative Eventing? Check out this CNCF Session aptly named ["Event-driven architecture with Knative events"](https://www.cncf.io/online-programs/event-driven-architecture-with-knative-events/){target=blank}

==**Knative Eventing acts as the "glue" between the disparate parts of your architecture**== and allows you to easily communicate between those parts in a fault-tolerant way. Some examples include:

:material-file-document: [Creating and responding to Kubernetes API events](../../developer/eventing/sources/apiserversource/){target=blank}

--8<-- "YouTube_icon.svg"
[Creating an image processing pipeline](https://www.youtube.com/watch?v=DrmOpjAunlQ){target=blank}

--8<-- "YouTube_icon.svg"
[Facilitating AI workloads at the edge in large-scale, drone-powered sustainable agriculture projects](https://www.youtube.com/watch?v=lVfJ5WEQ5_s){target=blank}

As you can see by the examples above, Knative Eventing implementations can range from simplistic to extremely complex. For now, you'll start with simplistic and learn about the most basic components of Knative Eventing: Sources, Brokers, Triggers and Sinks.
