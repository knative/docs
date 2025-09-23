# Load balancing

You can turn on Knative load balancing, by placing the _Activator service_ in the request path to act as a load balancer. To do this, you must first ensure that individual pod addressability is enabled.

## Activator pod selection

Activator pods are scaled horizontally, so there may be multiple Activators in a deployment. In general, the system will perform best if the number of revision pods is larger than the number of Activator pods, and those numbers divide equally.
<!--TODO(#2472): Add better documentation about what the activator is; explain the components of load balancing; maybe add a diagram-->

Knative assigns a subset of Activators for each revision, depending on the revision size. More revision pods will mean a greater number of Activators for that revision.

The Activator load balancing algorithm works as follows:

- If concurrency is unlimited, the request is sent to the better of two random choices.
- If concurrency is set to a value less or equal than 3, the Activator will send the request to the first pod that has capacity. Otherwise, requests will be balanced in a round robin fashion, with respect to container concurrency.

For more information, see the documentation on [concurrency](../autoscaling/concurrency.md).

## Configuring target burst capacity

Target burst capacity is mainly responsible for determining whether the Activator is in the request path outside of scale-from-zero scenarios.

Target burst capacity can be configured using a combination of the following parameters:

- Setting the targeted concurrency limits for the revision. See [concurrency](../autoscaling/concurrency.md).
- Setting the target utilization parameters. See [target utilization](../autoscaling/concurrency.md#target-utilization).
- Setting the target burst capacity. You can configure target burst capacity using the `target-burst-capacity` key in the `config-autoscaler` ConfigMap. See [Setting the target burst capacity](target-burst-capacity.md#setting-the-target-burst-capacity).
- Setting the Activator capacity by using the `config-autoscaler` ConfigMap. See [Setting the Activator capacity](activator-capacity.md#setting-the-activator-capacity).
