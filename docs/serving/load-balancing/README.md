You can configure load balancing on Knative to place the activator in the request path to act as a load balancer.

This guide explains how you can configure load balancing for your Knative system using the activator.

## Prerequisites
- Ensure that individual pod addressability is enabled.

## Activator pod selection
In general, the system will perform best if the number of existing pods is larger than the number of activators, and those numbers divide equally.
<!--TODO: Add better documentation about what the activator is; explain the components of load balancing; maybe add a diagram-->
Knative assigns a subset of activators for each revision, depending on the revision size. More revision pods will mean a greater number of activators for that revision. Activators are scaled horizontally, so there may be multiple activators in a deployment.

The activator load balancing algorithm works as follows:
- If concurrency is unlimited, the request is sent to the better of two random choices.
- If concurrency is set to a very low, limited value, the activator will send the request to the first pod that has capacity. Otherwise, if container concurrency is larger, requests will be balanced in a round robin fashion
<!--TODO: Still think we need to better explain what's low vs a large value here-->
For more information, see the documentation on [concurrency](../../serving/autoscaling/concurrency.md).

## Configuring target burst capacity

Target burst capacity is mainly responsible for determining whether the activator is in the request path outside of scale from zero scenarios.

Target burst capacity can be set [per revision](./target-burst-capacity.md), or globally configured using a combination of the following parameters:

* Setting the targeted concurrency limits for the revision. For more information, see the documentation on [concurrency](../../serving/autoscaling/concurrency.md).
* Setting the target utilization parameters. For more information, see the documentation on [target utilization](../../serving/autoscaling/concurrency.md#target-utilization).

<!-- TODO: Move global vs revision level config information out of autoscaling and up to a higher level doc about configmaps, etc.
Add section that walks through configuring load balancing globally-->
