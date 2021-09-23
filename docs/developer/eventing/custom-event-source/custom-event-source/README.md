# Create a custom event source

If you want to create a custom event source for a specific event producer type, you must create the components that enable forwarding events from that producer type to a Knative sink:

|Component |Description |
|------|---------------------|
|Receive adapter|Contains logic that specifies how to get events from a producer, what the sink URI is, and how to translate events into the CloudEvent format.|
|Kubernetes controller|Manages the event source and reconciles underlying receive adapter deployments.|
|Custom resource definition (CRD)|Provides the configuration that is used by the controller to manage the receive adapter.|

<!--TODO: Add links to components pages-->

## Using the sample source

The Knative project provides a sample repository that contains a template for a basic event source controller and a receive adapter.

For more information on using the sample source, see the [documentation](./sample-repo.md).

## Moving the event source to the Knative Sandbox

If you would like to add your event source to the [`knative-sandbox`](https://github.com/knative-sandbox) organization, follow the instructions to [create a sandbox repository](https://knative.dev/community/contributing/mechanics/creating-a-sandbox-repo/).

## Additional resources

* Implement CloudEvent binding interfaces, [cloudevent's go sdk](https://github.com/cloudevents/sdk-go) provides libraries for standard access to configure interfaces as needed.

* Controller runtime (this is what we share via injection) incorporates protocol specific config into "generic controller" CRD.
