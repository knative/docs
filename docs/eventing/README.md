
Knative Eventing is a system that is designed to address a common need for cloud
native development and provides composable primitives to enable late-binding
event sources and event consumers.

## Functionality

Knative Eventing supports multiple modes of usage. The following scenarios are
well-supported by the existing components; since the system is modular, it's
also possible to combine the components in novel ways.

1. **I just want to publish events, I don't care who consumes them.** Send
   events to a [Broker](broker/README.md) as an HTTP POST. The
   [SinkBinding](samples/sinkbinding/README.md) can be useful to decouple the destination
   configuration from your application.

1. **I just want to consume events like X, I don't care how they are
   published.** Use a [Trigger](broker/README.md) to consume events from a Broker based
   on CloudEvents attributes. Your application will receive the events as an
   HTTP POST.

1. **I want to transform events through a series of steps.** Use [Channels and
   Subscriptions](channels/README.md) to define complex message-passing topologies. For
   simple pipelines, the [Sequence](flows/sequence.md) automates construction of
   Channels and Subscriptions between each stage.

Knative also supports some additional patterns such as
[Parallel](flows/parallel.md) fanout of events, and routing response events from
both Channels and Brokers.

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

Broker and Trigger objects make it easy to filter events based on event
attributes.

A Broker provides a bucket of events which can be selected by attribute. It
receives events and forwards them to subscribers defined by one or more matching
Triggers. Since a Broker implements Addressable, event senders can submit events
to the Broker by POSTing the event to the Broker's `status.address.url`.

A Trigger describes a filter on event attributes which should be delivered to an
Addressable. You can create as many Triggers as necessary.

For most use cases, a single bucket (Broker) per namespace is sufficient, but
there are serveral use cases where multiple buckets (Brokers) can simplify
architecture. For example, separate Brokers for events containing Personally
Identifiable Information (PII) and non-PII events can simplify audit and access
control rules.

![Broker Trigger Diagram](./images/broker-trigger-overview.svg)

### Event registry

Knative Eventing defines an EventType object to make it easier for consumers to
discover the types of events they can consume from Brokers.

The registry consists of a collection of event types. The event types stored in
the registry contain (all) the required information for a consumer to create a
Trigger without resorting to some other out-of-band mechanism.

To learn how to use the registry, see the
[Event Registry documentation](./event-registry.md).

### Simplify event delivery

The [SinkBinding](samples/sinkbinding/README.md) custom object supports decoupling event
production from delivery addressing.

When you create a SinkBinding, you reference an Addressable and a Kubernetes
object which provides a PodTemplateSpec. The SinkBinding will inject environment
variables (`$K_SINK` for the destination URL) into the PodTemplateSpec so that
the application code does not need to interact with the Kubernetes API to locate
the event destination.

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

## Sources

<!-- TODO(evankanderson): move this to just sources/ ? -->

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
