# Event registry

Knative Eventing defines an `EventType` object to make it easier for consumers to discover the types of events they can consume from Brokers.

The event registry maintains a catalog of event types that each Broker can consume. The event types stored in the registry contain all required information for a consumer to create a Trigger without resorting to some other out-of-band mechanism.

This topic provides information about how you can populate the event registry, how to discover events using the registry, and how to leverage that information to subscribe to events of interest.

!!! note
    Before using the event registry, it is recommended that you have a basic understanding of Brokers, Triggers, Event Sources, and the [CloudEvents spec](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md) (particularly the [Context Attributes](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#context-attributes) section).

## About EventType objects

EventType objects represent a type of event that can be consumed from a Broker,
such as Apache Kafka messages or GitHub pull requests.
EventType objects are used to populate the event registry and persist event type
information in the cluster datastore.

The following is an example EventType YAML that omits irrelevant fields:

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: EventType
metadata:
  name: dev.knative.source.github.push-34cnb
  namespace: default
  labels:
    eventing.knative.dev/sourceName: github-sample
spec:
  type: dev.knative.source.github.push
  source: https://github.com/knative/eventing
  schema:
  description:
  broker: default
status:
  conditions:
    - status: "True"
      type: BrokerExists
    - status: "True"
      type: BrokerReady
    - status: "True"
      type: Ready
```

For the full specification for an EventType object, see the
[EventType API reference](../eventing/reference/eventing-api.md#eventing.knative.dev/v1beta1.EventType).

The `metadata.name` field is advisory, that is, non-authoritative.
It is typically generated using `generateName` to avoid naming collisions.
`metadata.name` is not needed when you create Triggers.

For consumers, the fields that matter the most are `spec` and `status`.
This is because these fields provide the information you need to create Triggers,
which is the source and type of event and whether the Broker is ready to receive
events.

The following table has more information about the `spec` and `status` fields of
EventType objects:
<!-- info in table needs review for tech accuracy -->

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `spec.type` | Refers to the [CloudEvent type](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type) as it enters into the event mesh. Event consumers can create Triggers filtering on this attribute. This field is authoritative. | Required |
| `spec.source` | Refers to the [CloudEvent source](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#source-1) as it enters into the event mesh. Event consumers can create Triggers filtering on this attribute. | Required |
| `spec.schema` | A valid URI with the EventType schema such as a JSON schema or a protobuf schema. | Optional |
| `spec.description` | A string describing what the EventType is about. | Optional |
| `spec.broker` | Refers to the Broker that can provide the EventType. | Required |
| `status` | Tells consumers, or cluster operators, whether the EventType is ready to be consumed or not. The _readiness_ is based on the Broker being ready. | Optional |

## Populate the registry with events

You can populate the registry with EventType objects manually or automatically.
Automatic registration can be the easier method, but it only supports a subset of
event sources.

### Manual registration

For manual registration, the cluster configurator applies EventTypes YAML files
the same as with any other Kubernetes resource.
<!-- does Knative support manual registration for all event sources? -->

To apply EventTypes YAML files manually:

1. Create an EventType YAML file. For information about the required fields, see
[About EventType objects](#about-eventtype-objects).

1.  Apply the YAML by running the command:

    ```bash
    kubectl apply -f <event-type.yaml>
    ```

### Automatic registration

Because manual registration might be tedious and error-prone, Knative also supports
registering EventTypes automatically.
EventTypes are created automatically when an event source is instantiated.

#### Support for automatic registration

Knative supports automatic registration of EventTypes for the following event sources:

- CronJobSource
- ApiServerSource
- GithubSource
- GcpPubSubSource
- KafkaSource
- AwsSqsSource

Knative only supports automatic creation of EventTypes for sources that have a
Broker as their sink.

#### Procedure for automatic registration

- To register EventTypes automatically, apply your event source YAML file by running the command:

    ```bash
    kubectl apply -f <event-source.yaml>
    ```

After your event source is instantiated, EventTypes are added to the registry.

#### Example: Automatic registration using KafkaSource

Given the following KafkaSource sample to populate the registry:

```yaml
apiVersion: sources.knative.dev/v1beta1
kind: KafkaSource
metadata:
  name: kafka-sample
  namespace: default
spec:
  bootstrapServers:
   - my-cluster-kafka-bootstrap.kafka:9092
  topics:
   - knative-demo
   - news
  sink:
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    name: default
```

The `topics` field in the above example is used to generate the EventType `source` field.

After running `kubectl apply` using the above YAML, the KafkaSource `kafka-source-sample`
is instantiated, and two EventTypes are added to the registry because there are
two topics.

## Discover events using the registry

Using the registry, you can discover the different types of events that Broker
event meshes can consume.

### View all event types you can subscribe to

- To see a list of event types in the registry that are available to subscribe to,
run the command:

    ```bash
    kubectl get eventtypes -n <namespace>
    ```

    Example output using the `default` namespace in a testing cluster:

    ```bash
    NAME                                         TYPE                                    SOURCE                                                               SCHEMA        BROKER     DESCRIPTION     READY     REASON
    dev.knative.source.github.push-34cnb         dev.knative.source.github.push          https://github.com/knative/eventing                                                default                    True
    dev.knative.source.github.push-44svn         dev.knative.source.github.push          https://github.com/knative/serving                                                 default                    True
    dev.knative.source.github.pullrequest-86jhv  dev.knative.source.github.pull_request  https://github.com/knative/eventing                                                default                    True
    dev.knative.source.github.pullrequest-97shf  dev.knative.source.github.pull_request  https://github.com/knative/serving                                                 default                    True
    dev.knative.kafka.event-cjvcr                dev.knative.kafka.event                 /apis/v1/namespaces/default/kafkasources/kafka-sample#news                         default                    True
    dev.knative.kafka.event-tdt48                dev.knative.kafka.event                 /apis/v1/namespaces/default/kafkasources/kafka-sample#knative-demo                 default                    True
    google.pubsub.topic.publish-hrxhh            google.pubsub.topic.publish             //pubsub.googleapis.com/knative/topics/testing                                     dev                        False     BrokerIsNotReady
    ```

    This example output shows seven different EventType objects in the registry
    of the `default` namespace.
    It assumes that the event sources emitting the events reference a Broker as their sink.


### View the YAML for an EventType object

- To see the YAML for an EventType object, run the command:

    ```bash
    kubectl get eventtype <name> -o yaml
    ```
    Where `<name>` is the name of an EventType object and can be found in the `NAME`
    column of the registry output. For example, `dev.knative.source.github.push-34cnb`.

For an example EventType YAML, see
[About EventType objects](#about-eventtype-objects) earlier on this page.

## About subscribing to events

After you know what events can be consumed from the Brokers' event meshes,
you can create Triggers to subscribe to particular events.

Here are a some example Triggers that subscribe to events using exact matching on
`type` or `source`, based on the registry output mentioned earlier:

* Subscribes to GitHub _pushes_ from any source:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
     name: push-trigger
     namespace: default
    spec:
     broker: default
     filter:
       attributes:
         type: dev.knative.source.github.push
     subscriber:
       ref:
         apiVersion: serving.knative.dev/v1
         kind: Service
         name: push-service
    ```
    !!! note
        As the example registry output mentioned, only two sources, the `knative/eventing`
        and `knative/serving` GitHub repositories, exist for that particular type of event.
        If later on new sources are registered for GitHub pushes, this Trigger
        is able to consume them.

* Subscribes to GitHub _pull requests_ from the `knative/eventing` GitHub repository:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
     name: gh-knative-eventing-pull-trigger
     namespace: default
    spec:
     broker: default
     filter:
       attributes:
         type: dev.knative.source.github.pull_request
         source: https://github.com/knative/eventing
     subscriber:
       ref:
         apiVersion: serving.knative.dev/v1
         kind: Service
         name: gh-knative-eventing-pull-service
    ```

* Subscribes to Kafka messages sent to the _knative-demo_ topic:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
     name: kafka-knative-demo-trigger
     namespace: default
    spec:
     broker: default
     filter:
       attributes:
         type: dev.knative.kafka.event
         source: /apis/v1/namespaces/default/kafkasources/kafka-sample#knative-demo
     subscriber:
       ref:
         apiVersion: serving.knative.dev/v1
         kind: Service
         name: kafka-knative-demo-service
    ```

* Subscribes to PubSub messages from GCP's _knative_ project sent to the _testing_ topic:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
     name: gcp-pubsub-knative-testing-trigger
     namespace: default
    spec:
     broker: dev
     filter:
       attributes:
         source: //pubsub.googleapis.com/knative/topics/testing
     subscriber:
       ref:
         apiVersion: serving.knative.dev/v1
         kind: Service
         name: gcp-pubsub-knative-testing-service
    ```

    !!! note
        The example registry output mentioned earlier lists this Broker's readiness as `false`.
        This Trigger's subscriber cannot consume events until the Broker becomes ready.

## Next steps

[Knative code samples](../samples/eventing.md) is a useful resource to better understand
some of the event sources. Remember, you must point the sources to a Broker if you want
automatic registration of EventTypes in the registry.
