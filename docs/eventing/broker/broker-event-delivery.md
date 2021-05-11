---
title: "Event delivery"
weight: 03
type: "docs"
showlandingtoc: "false"
---

# Event delivery

You can configure how events are delivered for each broker by adding a `delivery` spec, as shown in the following example:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: with-dead-letter-sink
spec:
  delivery:
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: example-sink
    backoffDelay: <duration>
    backoffPolicy: <policy-type>
    retry: <integer>
```

Where

- The `deadLetterSink` spec contains configuration settings to enable using a dead letter sink. This tells the subscription what happens to events that cannot be delivered to the subscriber. When this is configured, events that fail to be delivered are sent to the dead letter sink destination. The destination can be any Addressable object that conforms to the Knative Eventing sink contract, such as a Knative service, a Kubernetes service, or a URI. In the example, the destination is a `Service` object, or Knative service, named `example-sink`.
- The `backoffDelay` delivery parameter specifies the time delay before an event delivery retry is attempted after a failure. The duration of the `backoffDelay` parameter is specified using the ISO 8601 format. For example, `PT1S` specifies a 1 second delay.
- The `backoffPolicy` delivery parameter can be used to specify the retry back off policy. The policy can be specified as either `linear` or `exponential`. When using the `linear` back off policy, the back off delay is the time interval specified between retries. This is a linearly increasing delay, which means that the back off delay increases by the given interval for each retry. When using the `exponential` back off policy, the back off delay increases by a multiplier of the given interval for each retry.
- `retry` specifies the number of times that event delivery is retried before the event is sent to the dead letter sink. The initial delivery attempt is not included in the retry count, so the total number of delivery attempts is equal to the `retry` value +1.

## Broker Support

The following table summarizes which delivery parameters are supported for each broker implementation type:

| Broker Class | Supported Delivery Parameters |
| - | - |
| googlecloud | `deadLetterSink` [^1], `retry`, `backoffPolicy`, `backoffDelay` [^2] |
| Kafka | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| MTChannelBasedBroker | depends on the underlying channel |
| RabbitMQBroker | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |

[^1]: deadLetterSink must be a GCP Pub/Sub topic URI:
    ```yaml
    deadLetterSink:
      uri: pubsub://dead-letter-topic
    ```

    See the [`config-br-delivery`](https://github.com/google/knative-gcp/blob/master/config/core/configmaps/br-delivery.yaml)
    ConfigMap for a complete example.

[^2]: The `googlecloud` broker only supports the `exponential` back off policy.
