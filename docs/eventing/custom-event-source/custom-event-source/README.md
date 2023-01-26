# Create a custom event source

If you want to create a custom event source for a specific event producer type, you must create the components that enable forwarding events from that producer type to a Knative sink.

This type of integration requires more effort than using some simpler integration types, such as [SinkBinding](../sinkbinding/README.md) or [ContainerSource](../containersource/README.md); however, this provides the most polished result and is the easiest integration type for users to consume. By providing a custom resource definition (CRD) for your source rather than a general container definition, it is easier to expose meaningful configuration options and documentation to users and hide implementation details.

!!! note
    If you have created a new event source type that is not a part of the core Knative project, you can open a pull request to add it to the list of [Third-Party Sources](../../sources/#third-party-sources), and announce the new source in the [#knative-eventing Slack channel](https://cloud-native.slack.com/archives/C04LMU33V1S).

    You can also add your event source to the [`knative-sandbox`](https://github.com/knative-sandbox) organization, by following the instructions to [create a sandbox repository](https://github.com/knative/community/blob/main/mechanics/CREATING-A-SANDBOX-REPO.md).

## Required components

To create a custom event source, you must create the following components:

|Component |Description |
|------|---------------------|
|Receive adapter|Contains logic that specifies how to get events from a producer, what the sink URI is, and how to translate events into the CloudEvent format.|
|Kubernetes controller|Manages the event source and reconciles underlying receive adapter deployments.|
|Custom resource definition (CRD)|Provides the configuration that the controller uses to manage the receive adapter.|

<!--TODO: Add a diagram for this-->

## Using the sample source

The Knative project provides a sample repository that contains a template for a basic event source controller and a receive adapter.

For more information on using the sample source, see the [documentation](./sample-repo.md).

## Additional resources

* Implement CloudEvent binding interfaces, [cloudevent's go sdk](https://github.com/cloudevents/sdk-go) provides libraries for standard access to configure interfaces as needed.

* Controller runtime (this is what we share via injection) incorporates protocol specific config into "generic controller" CRD.
