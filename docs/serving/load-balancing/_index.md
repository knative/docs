---
title: "Load balancing"
weight: 30
type: "docs"
---

You can configure load balancing on Knative to place the Activator service in the request path to act as a load balancer.

## Prerequisites

- Ensure that individual pod addressability is enabled.

## Activator pod selection

Activator services are scaled horizontally, so there may be multiple Activators in a deployment. In general, the system will perform best if the number of existing pods is larger than the number of Activators, and those numbers divide equally.
<!--TODO(#2472): Add better documentation about what the activator is; explain the components of load balancing; maybe add a diagram-->
Knative assigns a subset of Activators for each revision, depending on the revision size. More revision pods will mean a greater number of activators for that revision.

The Activator load balancing algorithm works as follows:
- If concurrency is unlimited, the request is sent to the better of two random choices.
- If concurrency is set to a value less or equal than 3, the activator will send the request to the first pod that has capacity. Otherwise, requests will be balanced in a round robin fashion.

For more information, see the documentation on [concurrency](../../serving/autoscaling/concurrency.md).

## Configuring target burst capacity

Target burst capacity is mainly responsible for determining whether the activator is in the request path outside of scale-from-zero scenarios.

Target burst capacity can be configured using a combination of the following parameters:

- Setting the targeted concurrency limits for the revision. See [concurrency](../../serving/autoscaling/concurrency.md).
- Setting the target utilization parameters. See [target utilization](../../serving/autoscaling/concurrency.md#target-utilization).
- Setting the target burst capacity. You can configure target burst capacity using the `autoscaling.knative.dev/targetBurstCapacity` annotation key in the `config-autoscaler` ConfigMap. See [Setting the target burst capacity](./target-burst-capacity#setting-the-target-burst-capacity).
