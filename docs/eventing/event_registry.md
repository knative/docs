# Event Registry

## Overview

The Event Registry is a component that maintains a catalog of the event types that can flow through the system. 
For doing so, it introduces a new [EventType](../reference/eventing/eventing.md) CRD to be able to persist the event types 
information in Kubernetes data store. 

## Before you begin

1. Read about the [Broker and Trigger objects](./broker-trigger.md).
1. Be familiar with the [CloudEvents spec](https://github.com/cloudevents/spec/blob/master/spec.md),
   particularly the [Context Attributes](https://github.com/cloudevents/spec/blob/master/spec.md#context-attributes)
   section.
1. Be familiar with the [User stories and personas for Knative eventing](https://docs.google.com/document/d/15uhyqQvaomxRX2u8s0i6CNhA86BQTNztkdsLUnPmvv4/edit?usp=sharing).
1. Be familiar with the [Sources](./sources/README.md).

## Discovering Events with the Registry

By leveraging the Registry, Event Consumers can discover what are the different types of events that they can consume 
from the Brokers' event meshes. Our current implementation mainly targets the Broker/Trigger model, and aims to help 
consumers creating Triggers. 

Event Consumers can simply execute the following command to see what are the events they can *subscribe* to:

`kubectl get eventtypes -n <namespace>`

Below, we show an example output of executing the above command using the `default` namespace in a testing cluster. 
We will address the question of how this Registry was populated in a later section.  

```
NAME                                         TYPE                                    SOURCE                                                 SCHEMA        BROKER     DESCRIPTION     READY     REASON
dev.knative.source.github.push-34cnb         dev.knative.source.github.push          https://github.com/knative/eventing                                  default                    True
dev.knative.source.github.push-44svn         dev.knative.source.github.push          https://github.com/knative/serving                                   default                    True 
dev.knative.source.github.pullrequest-86jhv  dev.knative.source.github.pull_request  https://github.com/knative/eventing                                  default                    True
dev.knative.source.github.pullrequest-97shf  dev.knative.source.github.pull_request  https://github.com/knative/serving                                   default                    True  
dev.knative.kafka.event-cjvcr                dev.knative.kafka.event                 news                                                                 default                    True    
dev.knative.kafka.event-tdt48                dev.knative.kafka.event                 knative-demo                                                         default                    True
google.pubsub.topic.publish-hrxhh            google.pubsub.topic.publish             //pubsub.googleapis.com/knative/topics/testing                       dev                        False     BrokerIsNotReady
```

We can see that there are seven different EventTypes in the Event Registry of the `default` namespace. 
Let's pick the first one and see how the EventType yaml looks like:

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

From an Event Consumer standpoint, the fields that matter the most are the `spec` fields as well as the `status`.
The `name` is advisory (i.e., non-authoritative), and we typically generate it (`generateName`) to avoid naming collisions 
(e.g., two EventTypes listening to pull requests on two different Github repositories). 
As `name` nor `generateName` are needed for consumers to create Triggers, we defer their discussion for later on.

Regarding `status`, its main purpose it to tell Event Consumers (or Cluster Configurators) whether the EventType is ready 
for consumption or not. That *readiness* is based on the `broker` being ready. We can see from the example output that 
the PubSub EventType is not ready, as its `dev` Broker isn't.
 
Let's talk in more details about the `spec` fields:
 
- `type`: is authoritative. This refers to the CloudEvent type as it enters into the eventing mesh. It is mandatory. 
Event Consumers can (and in most cases would) create Triggers filtering on this attribute.

- `source`: Refers to the CloudEvent source as it enters into the eventing mesh. It is mandatory.
Event Consumers can (and in most cases would) create Triggers filtering on this attribute.

- `schema`: is a valid URI with the EventType schema. It may be a JSON schema, a protobuf schema, etc. It is optional.

- `description`: is a string describing what the EventType is about. It is optional.

- `broker` refers to the Broker that can provide the EventType. It is mandatory.


## Subscribing to Events of Interest

Given that the consumers now know what events can be consumed from the Brokers' event meshes, they can easily create 
Triggers to materialize their desire to subscribe to particular ones. 
Here are few Trigger examples that do so, using basic exact matching on `type` and/or `source`, 
based on the above Registry output.

1. Subscribes to GitHub push requests from any `source`.

    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Trigger
    metadata:
      name: push-trigger
      namespace: default
    spec:
      broker: default
      filter:
        sourceAndType:
          type: dev.knative.source.github.push
      subscriber:
        ref:
         apiVersion: serving.knative.dev/v1alpha1
         kind: Service
         name: push-service
    ```
    
    As per the Registry output above, only two sources exist 
    for that particular type of event (knative's eventing and serving repositories). 
    If later on new sources are registered for GitHub pushes, this trigger will be able to consume them.
        
1. Subscribes to GitHub pull requests from *knative's eventing* repository.

    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Trigger
    metadata:
      name: gh-knative-eventing-pull-trigger
      namespace: default
    spec:
      broker: default
      filter:
        sourceAndType:
          type: dev.knative.source.github.pull_request
          source: https://github.com/knative/eventing
      subscriber:
        ref:
         apiVersion: serving.knative.dev/v1alpha1
         kind: Service
         name: gh-knative-eventing-pull-service
    ```

1. Subscribes to Kafka messages sent to the *knative-demo* topic

    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Trigger
    metadata:
      name: kafka-knative-demo-trigger
      namespace: default
    spec:
      broker: default
      filter:
        sourceAndType:
          type: dev.knative.kafka.event
          source: knative-demo
      subscriber:
        ref:
         apiVersion: serving.knative.dev/v1alpha1
         kind: Service
         name: kafka-knative-demo-service
    ```

1. Subscribes to PubSub messages from GCP's *knative* project sent to the *testing* topic

    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Trigger
    metadata:
      name: gcp-pubsub-knative-testing-trigger
      namespace: default
    spec:
      broker: dev
      filter:
        sourceAndType:
          source: //pubsub.googleapis.com/knative/topics/testing
      subscriber:
        ref:
         apiVersion: serving.knative.dev/v1alpha1
         kind: Service
         name: gcp-pubsub-knative-testing-service
    ```
    
    Note that events won't be able to be consumed by this Trigger's subscriber until the Broker becomes ready.


## Populating the Registry

Now that we know how to discover events using the Registry and how we can leverage that information to subscribe to 
events of interest, let's move on to the next topic: How do we actually populate the Registry in the first place? 

You might be wondering why didn't we explain this first? The simple answer is we could have, but as population of the 
Registry is more of a Cluster Configurator concern rather than an Event Consumer one, we decided to leave it for the end.  

1. Manual Registration

    In order to populate the Registry, a Cluster Configurator can manually register the EventTypes. 
    This means that the configurator can simply apply EventTypes yaml files, just as with any other Kubernetes resource:

    `kubectl apply -f <event_type.yaml>`

1. Automatic Registration

    As Manual Registration might be tedious and error-prone, we also support automatic registration of EventTypes. 
    Herein, the creation of the EventTypes is done upon instantiation of an Event Source. 
    We currently support automatic Registration of EventTypes for the following Event Sources:

    - CronJobSource
    - ApiServerSource
    - GithubSource
    - GcpPubSubSource
    - KafkaSource
    - AwsSqsSource
    
    Let's look at an example, in particular, the KafkaSource sample we used to populate the Registry in our testing 
    cluster. Below is what the yaml looks like. 

    ```yaml
    apiVersion: sources.eventing.knative.dev/v1alpha1
    kind: KafkaSource
    metadata:
      name: kafka-source-sample
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
    
    If you are interested in more information regarding configuration options of a KafkaSource, please refer to the 
    [KafKaSource example](https://github.com/knative/eventing-sources/tree/master/contrib/kafka/samples).
    
    For this discussion, the relevant information from the yaml above are the `sink` and the `topics`. 
    We observe that the `sink` is of kind `Broker`. We currently only support automatic creation of EventTypes for Sources 
    instances that point to Brokers.
    Regarding `topics`, this is what we use for the EventTypes `source` field, which is equal to the CloudEvent source 
    attribute. 

    When a Cluster Configurator `kubectl apply` this yaml, not only the KafkaSource `kafka-source-sample` will be instantiated,
    but also two EventTypes will be added to the Registry (as there are two topics). You can see that in the Registry 
    example output from the previous sections.  
        
## Next Steps

We suggest the reader to experiment in her own cluster with the different Event Sources listed above. The following 
links might help to get you started. 

1. [Installing Knative](./install/README.md) in case you haven't already done so.
1. [Getting started with eventing](./eventing) in case you haven't read it. 
1. [Knative code samples](./samples/) is a useful resource to better understand some of the Event Sources (remember to 
point them to a Broker if you want automatic registration of EventTypes in the Registry).
