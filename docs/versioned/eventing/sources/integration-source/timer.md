# Timer Source

The `IntegrationSource` supports the _Timer Kamelet_ for producing periodic messages with a custom payload, through its `timer` property.

## Timer Source Example

Produces periodic messages with a custom payload.

  ```yaml
  apiVersion: sources.knative.dev/v1alpha1
  kind: IntegrationSource
  metadata:
    name: integration-source-timer
    namespace: knative-samples
  spec:
    timer:
      period: 2000
      message: "Hello, Eventing Core"
    sink:
      ref:
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        name: default
  ```

Inside of the `timer` object we define the `period` and the message that is send to the referenced `sink`.

More details about the Apache Camel Kamelet [timer-source](https://camel.apache.org/camel-kamelets/latest/timer-source.html).
