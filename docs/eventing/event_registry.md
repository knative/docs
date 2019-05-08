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

`$kubectl get eventtypes -n <namespace>`

Below, we show an example output of executing the above command using the `default` namespace in a testing cluster. 
We will address the question of how this Registry was populated in a later section.  

```
NAME                                         TYPE                                    SOURCE                                                 SCHEMA        BROKER     DESCRIPTION     READY     REASON
dev.knative.source.github.push-34cnb         dev.knative.source.github.push          https://github.com/nachocano/eventing                                default                    True
dev.knative.source.github.push-44svn         dev.knative.source.github.push          https://github.com/nachocano/serving                                 default                    True 
dev.knative.source.github.pullrequest-86jhv  dev.knative.source.github.pull_request  https://github.com/nachocano/eventing                                default                    True
dev.knative.source.github.pullrequest-97shf  dev.knative.source.github.pull_request  https://github.com/nachocano/serving                                 default                    True  
dev.knative.kafka.event-cjvcr                dev.knative.kafka.event                 news                                                                 default                    True    
dev.knative.kafka.event-tdt48                dev.knative.kafka.event                 knative-demo                                                         default                    True
google.pubsub.topic.publish-hrxhh            google.pubsub.topic.publish             //pubsub.googleapis.com/knative-2222/topics/testing                  dev                        False     BrokerIsNotReady
```

We can see that there are seven different EventTypes in the Event Registry of the `default` namespace. 
Let's pick the first one and see how the EventType yaml looks like:

`$kubectl get eventtype dev.knative.source.github.push-34cnb -o yaml`

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
  source: https://github.com/nachocano/eventing
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
(e.g., two EventTypes listening to pull requests on two different github repositories). 
As `name` nor `generateName` are needed for consumers to create Triggers, we defer their discussion for later on.

Regarding `status`, its main purpose it to tell Event Consumers (or Cluster Configurators) whether the EventType is ready 
for consumption or not. That *readiness* is based on the `broker` being ready. We can see from the example output that 
the PubSub EventType is not ready, as its `dev` Broker is not.
 
Let's talk in more details about the `spec` fields:
 
- `type`: is authoritative. This refers to the CloudEvent type as it enters into the eventing mesh. It is mandatory. 
Event Consumers can (and in most cases should) create Triggers filtering on this attribute.

- `source`: Refers to the CloudEvent source as it enters into the eventing mesh. It is mandatory.
Event Consumers can (and in most cases should) create Triggers filtering on this attribute.

- `schema`: is a valid URI with the EventType schema. It may be a JSON schema, a protobuf schema, etc. It is optional.

- `description`: is a string describing what the EventType is about. It is optional.

- `broker` refers to the Broker that can provide the EventType. It is mandatory.


## Subscribing to Events of Interest

Given that the consumers now know what events can be consumed from the Brokers' event meshes, they can easily create 
Triggers to materialize their desire to subscribe to particular ones. 
Here are few Trigger examples that does so, using basic exact matching on `type` and/or `source`, based on the above Registry output.

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
    for that particular type of event (nachocano's eventing and serving repositories). 
    If later on new sources are registered for GitHub pushes, this trigger will be able to consume them.
        
1. Subscribes to GitHub pull requests from *nachocano's eventing* repository.

    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Trigger
    metadata:
      name: gh-nachocano-eventing-pull-trigger
      namespace: default
    spec:
      broker: default
      filter:
        sourceAndType:
          type: dev.knative.source.github.pull_request
          source: https://github.com/nachocano/eventing
      subscriber:
        ref:
         apiVersion: serving.knative.dev/v1alpha1
         kind: Service
         name: gh-nachocano-eventing-pull-service
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

1. Subscribes to PubSub messages from GCP's *knative-2222* project sent to the *testing* topic

    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Trigger
    metadata:
      name: gcp-pubsub-knative-2222-testing-trigger
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
         name: gcp-pubsub-knative-2222-testing-service
    ```
    
    Note that events won't be received until the Broker's becomes ready.


## Populating the Registry

Now that we know how to discover events using the Registry and how we can leverage that information to subscribe to 
events of interest, let's move on to the next topic: How do we actually populate the Registry in the first place? 

You might be wondering why didn't we explain this first? The simple answer is we could have, but as population of the 
Registry is more of a Cluster Configurator concern rather than an Event Consumer one, we decided to leave it for the end. 
The previous two are mainly focused for Event Consumers.    

 
TODO update this.
