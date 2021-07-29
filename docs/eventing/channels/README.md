---
title: "Channels"
weight: 40
type: "docs"
showlandingtoc: "false"
aliases:
  - /docs/eventing/channels/default-channels
---

# Channels

Channels are Kubernetes [custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that define a single event forwarding and persistence layer.

A channel provides an event delivery mechanism that can fan-out received events, through subscriptions, to multiple destinations, or sinks. Examples of sinks include brokers and Knative services.

<img src="images/channel-workflow.png" width="80%">

## Next steps

- Learn about [default available channel types](channel-types-defaults)
- Create a [channel](create-default-channel)
- Create a [subscription](subscriptions)
