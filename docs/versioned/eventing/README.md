---
audience: developer
components:
  - eventing
function: explanation
---

# Eventing

--8<-- "about-eventing.md"

Examples of supported Knative Eventing use cases:

- Publish an event without creating a consumer. You can send events to a broker as an HTTP POST, and use binding to decouple the destination configuration from your application that produces events.

- Consume an event without creating a publisher. You can use a trigger to consume events from a broker based on event attributes. The application receives events as an HTTP POST.

!!! tip
    Multiple event producers and sinks can be used together to create more advanced [Knative Eventing flows](flows/README.md){target=_blank} to solve complex use cases.

## Eventing examples

:material-file-document: [Creating and responding to Kubernetes API events](../eventing/sources/apiserversource/README.md){target=blank}

--8<-- "YouTube_icon.svg"
[Creating an image processing pipeline](https://www.youtube.com/watch?v=DrmOpjAunlQ){target=blank}

--8<-- "YouTube_icon.svg"
[Facilitating AI workloads at the edge in large-scale, drone-powered sustainable agriculture projects](https://www.youtube.com/watch?v=lVfJ5WEQ5_s){target=blank}

## Next steps

- Start with [Your first event](../getting-started/getting-started-eventing.md)
  to send an event through a Broker and deliver it using a Trigger.
- Once you know the basics, try the
  [Bookstore tutorial](../bookstore/page-0/welcome-knative-bookstore-tutorial.md)
  to combine the components in a larger application.
- You can install Knative Eventing by using the methods listed on the [installation page](../install/README.md).
