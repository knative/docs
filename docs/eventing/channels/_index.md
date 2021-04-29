---
title: "Channels"
weight: 40
type: "docs"
showlandingtoc: "false"
aliases:
  - /docs/eventing/channels/default-channels
---

An event might be relevant to many consumers. One way to handle this is to directly tie each consumer
to the producer that creates the event, making a fan-out pattern.

This fan-out pattern, however, introduces complex problems for the application architecture, such as
retries, timeouts, and persistence. Instead of burdening the producer with these problems, you can
use channels.

A channel is a Kubernetes [custom resource](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that defines a single event forwarding and persistence layer.

Channels function as event delivery mechanisms that can fan out received events, through
subscriptions, to multiple destinations, referred to as sinks. Examples of sinks include brokers and
Knative services.

<img src="images/channel-workflow.png" width="80%"><br>

There are several kinds of channels, but they all make it possible to deliver events to all relevant
consumers and, importantly, make the events persist.

When you create a channel, you can choose which kind of channel is most appropriate for your use
case. For development use cases, an in-memory channel might suffice, but for production persistence,
you might need retry and replay capabilities.

## Next steps

- Learn about [default available channel types](channel-types-defaults)
- Create a [channel](./create-default-channel)
- Create a [subscription](./subscriptions)
