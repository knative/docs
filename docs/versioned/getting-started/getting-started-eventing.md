---
audience: developer
components:
  - eventing
function: tutorial
---

# Knative Eventing

Knative Eventing provides you with helpful tools that can be used to create event-driven applications, by easily attaching event sources, triggers, and other options to your Knative Services.

Event-driven applications are designed to detect events as they occur, and process these events by using user-defined, event-handling procedures.

!!! tip
    To find out more about event-driven architecture and Knative Eventing, check out this CNCF Session about [event-driven architecture with Knative events](https://www.cncf.io/online-programs/event-driven-architecture-with-knative-events/){target=blank}

## Follow the event path

Use the same `default` namespace and local cluster created in [Quickstart installation](quickstart-install.md). If you followed the Serving route, leave `hello` in place; it is not used by these Eventing lessons.

1. [Verify the example Broker](first-broker.md).
2. [Deploy the CloudEvents Player and send an event](first-source.md).
3. [Create a Trigger and observe the event return to the Player](first-trigger.md).

The Player serves as both the source and sink. You will see a sent event first, then a sent-and-received event after connecting the Trigger.

**Previous:** [Split Service traffic](first-traffic-split.md) · **Next:** [Inspect the Broker](first-broker.md)
