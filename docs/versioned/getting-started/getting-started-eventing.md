---
audience: developer
components:
  - eventing
function: tutorial
hide_prev: true
---

<span id="knative-eventing"></span>

# Your first event

Send an event through a Broker, then use a Trigger to deliver it to a consumer.
The CloudEvents Player application acts as both the sender and the consumer,
so you can see the result without writing application code.

## Before you begin

These lessons use a local Quickstart cluster with Serving, Eventing, and the
`example-broker` Broker in the `default` namespace. Have `kn` and `kubectl`
configured to use that cluster and namespace.

If you do not have that environment, [set up a learning cluster](quickstart-install.md)
and return here. If you still have the cluster from Get Started, you can reuse
it. You do not need to complete the service or Functions lessons first.

## Follow the tutorial

1. [Explore the Broker](first-broker.md) created by Quickstart.
2. [Send events](first-source.md) from the CloudEvents Player to the Broker.
3. [Receive events](first-trigger.md) by creating a Trigger that routes them
   back to the player.

When you finish, [clean up your disposable cluster](clean-up.md) if you no longer
need it. For background on the components, see the [Eventing overview](../eventing/README.md).
