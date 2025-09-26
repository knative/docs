---
audience: developer
components:
  - eventing
function: reference
---

# Developer configuration options

## Broker configuration 

- You can specify any valid `name` for your broker. Using `default` will create a broker named `default`.
- The `namespace` must be an existing namespace in your cluster. Using `default` will create the broker in the `default` namespace.

###  Event Delivery Options
- You can use `dead-letter sink`  for error handling and auditing of undelivered messages. Specify Kubernetes object reference where undelivered messages will be sent using `ref` and an optional URI to route undelivered messages using `uri`.
- You can set the `Backoff policies` to define the delay strategy between retry attempts. It can be `exponential` or `linear`.
- You can set the `Backoff delay` to specify the initial delay before retrying, using the ISO 8601 duration format.
- You can specify the number of retry attempts before sending the event to the dead-letter sink using the `retry` configuration.
- `spec.delivery` is used to configure event delivery options. Event delivery options specify what happens to an event that fails to be delivered to an event sink. For more information, see the documentation on [Event delivery](../event-delivery.md).

###  Advanced broker class options
When a Broker is created without a specified `eventing.knative.dev/broker.class` annotation, by default the `MTChannelBasedBroker` Broker class is used, as specified in the `config-br-defaults` ConfigMap.

In case you have multiple Broker classes installed in your cluster and want to use a non-default Broker class for a Broker, you can modify the `eventing.knative.dev/broker.class` annotation and `spec.config` for the Broker object.

1. Set the `eventing.knative.dev/broker.class` annotation. Replace `MTChannelBasedBroker` in the following example with the class type you want to use. Be aware that the Broker class annoation is immutable and thus can't be updated after the Broker got created:

2. Configure the `spec.config` with the details of the ConfigMap that defines the required configuration for the Broker class (e.g. with some Channel configurations in case of the `MTChannelBasedBroker`):

For further information about configuring a default Broker class cluster wide or on a per namespace basis, check the [Administrator configuration options](../configuration/broker-configuration.md#configuring-the-broker-class).

## Broker configuration example

The following is a full example of a Channel based Broker object which shows the possible configuration options that you can modify:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: default
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
  delivery:
    deadLetterSink:
      ref:
        kind: Service
        namespace: example-namespace
        name: example-service
        apiVersion: v1
      uri: example-uri
    retry: 5
    backoffPolicy: exponential
    backoffDelay: "PT1S"
```
