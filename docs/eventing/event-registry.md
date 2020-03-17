---
title: "Event registry"
weight: 25
type: "docs"
---

## Overview

The Event Registry maintains a catalog of the event types that can be consumed
from the different Brokers. It introduces a new
[EventType](../reference/eventing/) CRD in order to persist the event
type's information in the cluster's data store.

## Before you begin

1. Read about the [Broker and Trigger objects](./broker-trigger.md).
1. Be familiar with the
   [CloudEvents spec](https://github.com/cloudevents/spec/blob/master/spec.md),
   particularly the
   [Context Attributes](https://github.com/cloudevents/spec/blob/master/spec.md#context-attributes)
   section.
1. Be familiar with the [Eventing sources](./sources/README.md).

## Discovering events with the registry

Using the registry, you can discover the different types of events you can
consume from the Brokers' event meshes. The registry is designed for use with
the Broker/Trigger model and aims to help you create Triggers.

To see the event types available to _subscribe_ to, enter the following command:

`kubectl get eventtypes -n <namespace>`

Below, we show an example output of executing the above command using the
`default` namespace in a testing cluster. We will address the question of how
this registry was populated in a later section.

```
NAME                                         TYPE                                    SOURCE                                                               SCHEMA        BROKER     DESCRIPTION     READY     REASON
dev.knative.source.github.push-34cnb         dev.knative.source.github.push          https://github.com/knative/eventing                                                default                    True
dev.knative.source.github.push-44svn         dev.knative.source.github.push          https://github.com/knative/serving                                                 default                    True
dev.knative.source.github.pullrequest-86jhv  dev.knative.source.github.pull_request  https://github.com/knative/eventing                                                default                    True
dev.knative.source.github.pullrequest-97shf  dev.knative.source.github.pull_request  https://github.com/knative/serving                                                 default                    True
dev.knative.kafka.event-cjvcr                dev.knative.kafka.event                 /apis/v1/namespaces/default/kafkasources/kafka-sample#news                         default                    True
dev.knative.kafka.event-tdt48                dev.knative.kafka.event                 /apis/v1/namespaces/default/kafkasources/kafka-sample#knative-demo                 default                    True
google.pubsub.topic.publish-hrxhh            google.pubsub.topic.publish             //pubsub.googleapis.com/knative/topics/testing                                     dev                        False     BrokerIsNotReady
```

We can see that there are seven different EventTypes in the registry of the
`default` namespace. Let's pick the first one and see what the EventType yaml
looks like:

`kubectl get eventtype dev.knative.source.github.push-34cnb -o yaml`

Omitting irrelevant fields:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventType
metadata:
  name: dev.knative.source.github.push-34cnb
  namespace: default
  generateName: dev.knative.source.github.push-
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

From a consumer standpoint, the fields that matter the most are the `spec`
fields as well as the `status`.

The `name` is advisory (i.e., non-authoritative), and we typically generate it
(`generateName`) to avoid naming collisions (e.g., two EventTypes listening to
pull requests on two different Github repositories). As `name` nor
`generateName` are needed for consumers to create Triggers, we defer their
discussion for later on.

Regarding `status`, its main purpose it to tell consumers (or cluster operators)
whether the EventType is ready for consumption or not. That _readiness_ is based
on the Broker being ready. We can see from the example output that the PubSub
EventType is not ready, as its `dev` Broker isn't.

Let's talk in more details about the `spec` fields:

- `type`: is authoritative. This refers to the CloudEvent type as it enters into
  the event mesh. It is mandatory. Event consumers can (and in most cases would)
  create Triggers filtering on this attribute.

- `source`: refers to the CloudEvent source as it enters into the event mesh. It
  is mandatory. Event consumers can (and in most cases would) create Triggers
  filtering on this attribute.

- `schema`: is a valid URI with the EventType schema. It may be a JSON schema, a
  protobuf schema, etc. It is optional.

- `description`: is a string describing what the EventType is about. It is
  optional.

- `broker` refers to the Broker that can provide the EventType. It is mandatory.

## Subscribing to events

Now that you know what events can be consumed from the Brokers' event meshes,
you can create Triggers to subscribe to particular events.

Here are a few example Triggers that subscribe to events using exact matching on
`type` and/or `source`, based on the above registry output:

1. Subscribes to GitHub _pushes_ from any source.

   ```yaml
   apiVersion: eventing.knative.dev/v1alpha1
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

   As per the registry output above, only two sources exist for that particular
   type of event (_knative's eventing and serving_ repositories). If later on
   new sources are registered for GitHub pushes, this trigger will be able to
   consume them.

1. Subscribes to GitHub _pull requests_ from _knative's eventing_ repository.

   ```yaml
   apiVersion: eventing.knative.dev/v1alpha1
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

1. Subscribes to Kafka messages sent to the _knative-demo_ topic

   ```yaml
   apiVersion: eventing.knative.dev/v1alpha1
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

1. Subscribes to PubSub messages from GCP's _knative_ project sent to the
   _testing_ topic

   ```yaml
   apiVersion: eventing.knative.dev/v1alpha1
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

   Note that events won't be able to be consumed by this Trigger's subscriber
   until the Broker becomes ready.

## Populating the registry

Now that we know how to discover events using the registry and how we can
leverage that information to subscribe to events of interest, let's move on to
the next topic: How do we actually populate the registry in the first place?

- Manual Registration

  In order to populate the registry, a cluster configurator can manually
  register the EventTypes. This means that the configurator can simply apply
  EventTypes yaml files, just as with any other Kubernetes resource:

  `kubectl apply -f <event_type.yaml>`

- Automatic Registration

  As Manual Registration might be tedious and error-prone, we also support
  automatic registration of EventTypes. The creation of the EventTypes is done
  upon instantiation of an Event Source. We currently support automatic
  registration of EventTypes for the following Event Sources:

  - CronJobSource
  - ApiServerSource
  - GithubSource
  - GcpPubSubSource
  - KafkaSource
  - AwsSqsSource

  Let's look at an example, in particular, the KafkaSource sample we used to
  populate the registry in our testing cluster. Below is what the yaml looks
  like.

  ```yaml
  apiVersion: sources.eventing.knative.dev/v1alpha1
  kind: KafkaSource
  metadata:
    name: kafka-sample
    namespace: default
  spec:
    consumerGroup: knative-group
    bootstrapServers: my-cluster-kafka-bootstrap.kafka:9092
    topics: knative-demo,news
    sink:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: Broker
      name: default
  ```

  If you are interested in more information regarding configuration options of a
  KafkaSource, please refer to the
  [KafKaSource sample](./samples/kafka/).

  For this discussion, the relevant information from the yaml above are the
  `sink` and the `topics`. We observe that the `sink` is of kind `Broker`. We
  currently only support automatic creation of EventTypes for Sources instances
  that point to Brokers. Regarding `topics`, this is what we use to generate the
  EventTypes `source` field, which is equal to the CloudEvent source attribute.

  When you `kubectl apply` this yaml, the KafkaSource `kafka-source-sample` will
  be instantiated, and two EventTypes will be added to the registry (as there
  are two topics). You can see that in the registry example output from the
  previous sections.

## What's next

To get started, install Knative Eventing if you haven't yet, and try
experimenting with different Event Sources in your Knative cluster.

1. [Installing Knative](../install/README.md) in case you haven't already done
   so.
1. [Getting started with eventing](./README.md) in case you haven't read it.
1. [Knative code samples](./samples/) is a useful resource to better understand
   some of the Event Sources (remember to point them to a Broker if you want
   automatic registration of EventTypes in the registry).
