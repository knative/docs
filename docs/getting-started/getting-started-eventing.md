# Introducing Knative Eventing

Knative Eventing provides you with helpful tools that can be used to create event-driven applications, by easily attaching event sources, triggers, and other options to your Knative Services.

Event-driven applications are designed to detect events as they occur, and process these events by using user-defined, event-handling procedures.

!!! tip
    To find out more about event-driven architecture and Knative Eventing, check out this CNCF Session about [event-driven architecture with Knative events](https://www.cncf.io/online-programs/event-driven-architecture-with-knative-events/){target=blank}

## Knative Eventing examples

**Knative Eventing acts as the "glue" between the disparate parts of your architecture** and allows you to easily communicate between those parts in a fault-tolerant way. Some examples include:

:material-file-document: [Creating and responding to Kubernetes API events](../eventing/sources/apiserversource/README.md){target=blank}

--8<-- "YouTube_icon.svg"
[Creating an image processing pipeline](https://www.youtube.com/watch?v=DrmOpjAunlQ){target=blank}

--8<-- "YouTube_icon.svg"
[Facilitating AI workloads at the edge in large-scale, drone-powered sustainable agriculture projects](https://www.youtube.com/watch?v=lVfJ5WEQ5_s){target=blank}

As you can see by the mentioned examples, Knative Eventing implementations can range from simplistic to extremely complex. For now, you'll start with simplistic and learn about the most basic components of Knative Eventing: **Sources**, **Brokers**, **Triggers**, and **Sinks**.
