
Knative Eventing is a system that is designed to address a common need for cloud
native development and provides composable primitives to enable late-binding
event sources and event consumers.

## Design overview

Knative Eventing is designed around the following goals:

1. Knative Eventing services are loosely coupled. These services can be
   developed and deployed independently on, and across a variety of platforms
   (for example Kubernetes, VMs, SaaS or FaaS).
1. Event producers and event consumers are independent. Any producer (or
   source), can generate events before there are active event consumers that are
   listening. Any event consumer can express interest in an event or class of
   events, before there are producers that are creating those events.
1. Other services can be connected to the Eventing system. These services can
   perform the following functions:
   - Create new applications without modifying the event producer or event
     consumer.
   - Select and target specific subsets of the events from their producers.
1. Ensure cross-service interoperability. Knative Eventing is consistent with
   the
   [CloudEvents](https://github.com/cloudevents/spec/blob/master/spec.md#design-goals)
   specification that is developed by the
   [CNCF Serverless WG](https://lists.cncf.io/g/cncf-wg-serverless).

### Event consumers

To enable delivery to multiple types of Services, Knative Eventing defines two
generic interfaces that can be implemented by multiple Kubernetes resources:

1. **Addressable** objects are able to receive and acknowledge an event
   delivered over HTTP to an address defined in their `status.address.url`
   field. As a special case, the core
   [Kubernetes Service object](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#service-v1-core)
   also fulfils the Addressable interface.
1. **Callable** objects are able to receive an event delivered over HTTP and
   transform the event, returning 0 or 1 new events in the HTTP response. These
   returned events may be further processed in the same way that events from an
   external event source are processed.

### Event brokers and triggers

As of v0.5, Knative Eventing defines Broker and Trigger objects to make it
easier to filter events.

A Broker provides a bucket of events which can be selected by attribute. It
receives events and forwards them to subscribers defined by one or more matching
Triggers.

A Trigger describes a filter on event attributes which should be delivered to an
Addressable. You can create as many Triggers as necessary.

![Broker Trigger Diagram](./images/broker-trigger-overview.svg)

### Event registry

As of v0.6, Knative Eventing defines an EventType object to make it easier for
consumers to discover the types of events they can consume from the different
Brokers.

The registry consists of a collection of event types. The event types stored in
the registry contain (all) the required information for a consumer to create a
Trigger without resorting to some other out-of-band mechanism.

To learn how to use the registry, see the
[Event Registry documentation](./event-registry.md).

### Event channels and subscriptions

Knative Eventing also defines an event forwarding and persistence layer, called
a
[**Channel**](https://github.com/knative/eventing/blob/master/pkg/apis/messaging/v1alpha1/channel_types.go#L57).
Each channel is a separate Kubernetes [Custom Resource](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).
Events are delivered to Services or forwarded to other channels
(possibly of a different type) using
[Subscriptions](https://github.com/knative/eventing/blob/master/pkg/apis/messaging/v1alpha1/subscription_types.go).
This allows message delivery in a cluster to vary based on requirements, so that
some events might be handled by an in-memory implementation while others would
be persisted using Apache Kafka or NATS Streaming.

See the [List of Channel implementations](../eventing/channels/channels.yaml).

### Higher Level eventing constructs

There are cases where you may want to utilize a set of co-operating functions
together and for those use cases, Knative Eventing provides two additional
resources:

1. **[Sequence](./flows/sequence.md)** provides a way to define an in-order list of functions.
1. **[Parallel](./flows/parallel.md)** provides a way to define a list of branches for events.

### Future design goals

The focus for the next Eventing release will be to enable easy implementation of
event sources. Sources manage registration and delivery of events from external
systems using Kubernetes
[Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).
Learn more about Eventing development in the
[Eventing work group](https://github.com/knative/community/blob/master/working-groups/WORKING-GROUPS.md#eventing).

## Installation

Knative Eventing currently requires Knative Serving installed with either Istio version >=1.0,
Contour version >=1.1, or Gloo version >=0.18.16.
[Follow the instructions to install on the platform of your choice](../install/README.md).

## Architecture

The eventing infrastructure supports two forms of event delivery at the moment:

1. Direct delivery from a source to a single Service (an Addressable endpoint,
   including a Knative Service or a core Kubernetes Service). In this case, the
   Source is responsible for retrying or queueing events if the destination
   Service is not available.
1. Fan-out delivery from a source or Service response to multiple endpoints
   using
   [Channels](https://github.com/knative/eventing/blob/master/pkg/apis/messaging/v1alpha1/channel_types.go#L57)
   and
   [Subscriptions](https://github.com/knative/eventing/blob/master/pkg/apis/messaging/v1alpha1/subscription_types.go).
   In this case, the Channel implementation ensures that messages are delivered
   to the requested destinations and should buffer the events if the destination
   Service is unavailable.

![Control plane object model](./images/control-plane.png)

The actual message forwarding is implemented by multiple data plane components
which provide observability, persistence, and translation between different
messaging protocols.

![Data plane implementation](./images/data-plane.png)

<!-- TODO(evankanderson): add documentation for Kafka bus once it is available. -->

## Sources

Each source is a separate Kubernetes custom resource. This allows each type of
Source to define the arguments and parameters needed to instantiate a source.
All Sources should be part of the `sources` category, so you can list all existing Sources with
`kubectl get sources`.

In addition to the sources explained below, there are
[other sources](./sources/README.md) that you can install.
If you need a Source not covered by the ones mentioned below nor by the other
[available implementations](./sources/README.md), there is a
[tutorial on writing a Source with a Receive Adapter](./samples/writing-receive-adapter-source).

If your code needs to send events as part of its business logic and doesn't fit
the model of a Source, consider
[feeding events directly to a Broker](https://knative.dev/docs/eventing/broker-trigger/#manual).

### Core Sources

These are the core sources that come out-of-the-box when installing Knative Eventing.

#### APIServerSource

The APIServerSource fires a new event each time a Kubernetes resource is created, updated or deleted.

See the [Kubernetes API Server Source](samples/kubernetes-event-source) example for more details.

#### PingSource

The PingSource fires events based on given
[Cron](https://en.wikipedia.org/wiki/Cron) schedule.

See the [Ping Source](samples/ping-source) example for more details.

#### ContainerSource

The ContainerSource will instantiate container image(s) that can generate events
until the ContainerSource is deleted. This may be used (for example) to poll an
FTP server for new files or generate events at a set time interval.

Refer to the [Container Source](samples/container-source) example for more details.

#### SinkBinding

The SinkBinding can be used to author new event sources using any of the
familiar compute abstractions that Kubernetes makes available (e.g. Deployment,
Job, DaemonSet, StatefulSet), or Knative abstractions (e.g. Service,
Configuration).

See the [SinkBinding](samples/container-source) example for more details.

### Eventing Contrib Sources

This is a non-exhaustive list of Sources supported by our community and maintained
in the [Knative Eventing-Contrib](https://github.com/knative/eventing-contrib) Github repo.

#### GitHubSource

The GitHubSource fires a new event for selected
[GitHub event types](https://developer.github.com/v3/activity/events/types/).

See the [GitHub Source](samples/github-source) example for more details.

#### GitLabSource

The GitLabSource creates a webhooks for specified
[event types](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#events),
listens for incoming events and passes them to a consumer.

See the [GitLab Source](samples/gitlab-source) example for more details.

#### AwsSqsSource

The AwsSqsSource fires a new event each time an event is published on an
[AWS SQS topic](https://aws.amazon.com/sqs/).

#### KafkaSource

The KafkaSource reads events from an Apache Kafka Cluster, and passes these to a
Knative Serving application so that they can be consumed.

See the
[Kafka Source](https://github.com/knative/eventing-contrib/tree/master/kafka/source)
example for more details.

#### CamelSource

A CamelSource is an event source that can represent any existing
[Apache Camel component](https://github.com/apache/camel/tree/master/components)
that provides a consumer side, and enables publishing events to an addressable
endpoint. Each Camel endpoint has the form of a URI where the scheme is the ID
of the component to use.

CamelSource requires [Camel-K](https://github.com/apache/camel-k#installation)
to be installed into the current namespace. See the
[CamelSource](https://github.com/knative/eventing-contrib/tree/master/camel/source/samples)
example.

### Google Cloud Sources

In order to consume events from different GCP services, [Knative-GCP](https://github.com/google/knative-gcp) supports
different GCP Sources.

#### CloudPubSubSource

The CloudPubSubSource fires a new event each time a message is published on a
[Google Cloud Platform PubSub topic](https://cloud.google.com/pubsub/).

See the [CloudPubSubSource](samples/cloud-pubsub-source) example for more details.

#### CloudStorageSource

Registers for events of specific types on the specified
[Google Cloud Storage](https://cloud.google.com/storage/) bucket and optional object prefix.
Brings those events into Knative.

See the [CloudStorageSource](samples/cloud-storage-source) example.

#### CloudSchedulerSource

Creates, updates, and deletes [Google Cloud Scheduler](https://cloud.google.com/scheduler/) Jobs.
When those jobs are triggered, receive the event inside Knative.

See the [CloudSchedulerSource](samples/cloud-scheduler-source) example for further details.

#### CloudAuditLogsSource

Registers for events of specific types on the specified [Google Cloud Audit Logs](https://cloud.google.com/logging/docs/audit/).
Brings those events into Knative.

Refer to the [CloudAuditLogsSource](samples/cloud-audit-logs-source) example for more details.


## Getting Started

- [Install the Eventing component](#installation)
- [Setup Knative Serving](../install/README.md)
- [Run samples](./samples/)
- [Default Channels](./channels/default-channels.md) provide a way to choose the
  persistence strategy for Channels across the cluster.
