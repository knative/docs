---
audience: developer
components:
  - eventing
function: tutorial
hide_prev: true
---

<span id="knative-eventing"></span><span id="your-first-event"></span>

# Get started with Eventing

Send an event through a **Broker** and use a **Trigger** to deliver it to a consumer.
The CloudEvents Player application will send and display the event, so you can
observe the result without writing application code.

## Before you begin

[Set up a learning cluster](quickstart-install.md) if you have not already done so,
then return here. Use its `kind-knative` context and the `default` namespace.
You can reuse the same environment as the Serving track; completing Serving
or Functions is not a prerequisite.

## Explore the Broker

Quickstart creates a Broker named `example-broker`. Verify that it is ready:

```bash
kn broker list
```

Find `example-broker` and check that its `READY` column is `True`. If it is not
ready or is missing, resolve the cluster setup before continuing.

A Broker receives events. A Trigger selects events from that Broker and identifies
where to deliver them. The destination is called a **sink**, or event consumer.
The Broker created here uses an in-memory implementation for learning, not for
production workloads that require durable delivery.

## Follow the track

1. [Send and receive an event](first-source.md) using the CloudEvents Player.
2. Optionally, [filter events](first-trigger.md) by their type.

For broader background, see the [Eventing overview](../eventing/README.md).
You can keep the learning cluster for another track when you finish.
