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
   delivered over HTTP to an address defined in their `status.address.hostname`
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
[**Channel**](https://github.com/knative/eventing/blob/master/pkg/apis/eventing/v1alpha1/channel_types.go#L36).
Messaging implementations may provide implementations of Channels via the
[ClusterChannelProvisioner](https://github.com/knative/eventing/blob/master/pkg/apis/eventing/v1alpha1/cluster_channel_provisioner_types.go#L35)
object. Events are delivered to Services or forwarded to other channels
(possibly of a different type) using
[Subscriptions](https://github.com/knative/eventing/blob/master/pkg/apis/eventing/v1alpha1/subscription_types.go#L35).
This allows message delivery in a cluster to vary based on requirements, so that
some events might be handled by an in-memory implementation while others would
be persisted using Apache Kafka or NATS Streaming.

### Future design goals

The focus for the next Eventing release will be to enable easy implementation of
event sources. Sources manage registration and delivery of events from external
systems using Kubernetes
[Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).
Learn more about Eventing development in the
[Eventing work group](../../contributing/WORKING-GROUPS.md#events).

## Installation

Knative Eventing currently requires Knative Serving and Istio version 1.0 or
later installed.
[Follow the instructions to install on the platform of your choice](../install/README.md).

Many of the sources require making outbound connections to create the event
subscription, and if you have any functions that make use of any external (to
cluster) services, you must enable it also for them to work.
[Follow the instructions to configure outbound network access](../serving/outbound-network-access.md).

## Architecture

The eventing infrastructure supports two forms of event delivery at the moment:

1. Direct delivery from a source to a single Service (an Addressable endpoint,
   including a Knative Service or a core Kubernetes Service). In this case, the
   Source is responsible for retrying or queueing events if the destination
   Service is not available.
1. Fan-out delivery from a source or Service response to multiple endpoints
   using
   [Channels](https://github.com/knative/eventing/blob/master/pkg/apis/eventing/v1alpha1/channel_types.go#L36)
   and
   [Subscriptions](https://github.com/knative/eventing/blob/master/pkg/apis/eventing/v1alpha1/subscription_types.go#L35).
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
Knative Eventing defines the following Sources in the
`sources.eventing.knative.dev` API group. Types below are declared in golang
format, but may be expressed as simple lists, etc in YAML. All Sources should be
part of the `sources` category, so you can list all existing Sources with
`kubectl get sources`. The currently-implemented Sources are described below.

In addition to the core sources (explained below), there are
[other sources](./sources/README.md) that you can install.

If you need a Source not covered by the
[available Source implementations](./sources/README.md), there is a
[tutorial on writing your own Source](./samples/writing-a-source/README.md).

If your code needs to send events as part of its business logic and doesn't fit
the model of a Source, consider
[feeding events directly to a Broker](https://knative.dev/docs/eventing/broker-trigger/#manual).

### KubernetesEventSource

The KubernetesEventSource fires a new event each time a
[Kubernetes Event](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#event-v1-core)
is created or updated.

**Spec fields**:

- `namespace`: `string` The namespace to watch for events.
- `serviceAccountname`: `string` The name of the ServiceAccount used to connect
  to the Kubernetes apiserver.
- `sink`:
  [ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#objectreference-v1-core)
  A reference to the object that should receive events.

See the [Kubernetes Event Source](samples/kubernetes-event-source) example.

### GitHubSource

The GitHubSource fires a new event for selected
[GitHub event types](https://developer.github.com/v3/activity/events/types/).

**Spec fields**:

- `ownerAndRepository`: `string` The GitHub owner/org and repository to receive
  events from. The repository may be left off to receive events from an entire
  organization.
- `eventTypes`: `[]string` A list of
  [event types](https://developer.github.com/v3/activity/events/types/) in
  "Webhook event name" format (lower_case).
- `accessToken.secretKeyRef`:
  [SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#secretkeyselector-v1-core)
  containing a GitHub access token for configuring a GitHub webhook. One of this
  or `secretToken` must be set.
- `secretToken.secretKeyRef`:
  [SecretKeySelector](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#secretkeyselector-v1-core)
  containing a GitHub secret token for configuring a GitHub webhook. One of this
  or `accessToken` must be set.
- `serviceAccountName`: `string` The name of the ServiceAccount to run the
  container as.
- `sink`:
  [ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#objectreference-v1-core)
  A reference to the object that should receive events.
- `githubAPIURL`: `string` Optional field to specify the base URL for API
  requests. Defaults to the public GitHub API if not specified, but can be set
  to a domain endpoint to use with GitHub Enterprise, for example,
  `https://github.mycompany.com/api/v3/`. This base URL should always be
  specified with a trailing slash.

See the [GitHub Source](samples/github-source) example.

### GcpPubSubSource

The GcpPubSubSource fires a new event each time a message is published on a
[Google Cloud Platform PubSub topic](https://cloud.google.com/pubsub/).

**Spec fields**:

- `googleCloudProject`: `string` The GCP project ID that owns the topic.
- `topic`: `string` The name of the PubSub topic.
- `serviceAccountName`: `string` The name of the ServiceAccount used to access
  the `gcpCredsSecret`.
- `gcpCredsSecret`:
  [ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#objectreference-v1-core)
  A reference to a Secret which contains a GCP refresh token for talking to
  PubSub.
- `sink`:
  [ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#objectreference-v1-core)
  A reference to the object that should receive events.

See the [GCP PubSub Source](samples/gcp-pubsub-source) example.

### AwsSqsSource

The AwsSqsSource fires a new event each time an event is published on an
[AWS SQS topic](https://aws.amazon.com/sqs/).

**Spec fields**:

- `queueURL`: URL of the SQS queue to pull events from.
- `awsCredsSecret`: credential to use to poll the AWS SQS queue.
- `sink`:
  [ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#objectreference-v1-core)
  A reference to the object that should receive events.
- `serviceAccountName`: `string` The name of the ServiceAccount used to access
  the `awsCredsSecret`.

### ContainerSource

The ContainerSource will instantiate a container image which can generate events
until the ContainerSource is deleted. This may be used (for example) to poll an
FTP server for new files or generate events at a set time interval.

**Spec fields**:

- `image` (**required**): `string` A docker image of the container to be run.
- `args`: `[]string` Command-line arguments. If no `--sink` flag is provided,
  one will be added and filled in with the DNS address of the `sink` object.
- `env`: `map[string]string` Environment variables to be set in the container.
- `serviceAccountName`: `string` The name of the ServiceAccount to run the
  container as.
- `sink`:
  [ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#objectreference-v1-core)
  A reference to the object that should receive events.

### CronJobSource

The CronJobSource fires events based on given
[Cron](https://en.wikipedia.org/wiki/Cron) schedule.

**Spec fields**:

- `schedule` (**required**): `string` A
  [Cron](https://en.wikipedia.org/wiki/Cron) format string, such as `0 * * * *`
  or `@hourly`.
- `data`: `string` Optional data sent to downstream receiver.
- `serviceAccountName`: `string` The name of the ServiceAccount to run the
  container as.
- `sink`:
  [ObjectReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#objectreference-v1-core)
  A reference to the object that should receive events.

See the [Cronjob Source](samples/cronjob-source) example.

### KafkaSource

The KafkaSource reads events from an Apache Kafka Cluster, and passes these to a
Knative Serving application so that they can be consumed.

**Spec fields**:

- `consumerGroup`: `string` Name of a Kafka consumer group.
- `bootstrapServers`: `string` Comma separated list of `hostname:port` pairs for
  the Kafka Broker.
- `topics`: `string` Name of the Kafka topic to consume messages from.
- `net`: Optional network configuration.
  - `sasl`: Optional SASL authentication configuration.
    - `enable`: `boolean` If true, use SASL for authentication.
    - `user.secretKeyRef`:
      [`SecretKeySelector`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#secretkeyselector-v1-core)
      containing the SASL username to use.
    - `password.secretKeyRef`:
      [`SecretKeySelector`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#secretkeyselector-v1-core)
      containing the SASL password to use.
  - `tls`: Optional TLS configuration.
    - `enable`: `boolean` If true, use TLS when connecting.
    - `cert.secretKeyRef`:
      [`SecretKeySelector`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#secretkeyselector-v1-core)
      containing the client certificate to use.
    - `key.secretKeyRef`:
      [`SecretKeySelector`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#secretkeyselector-v1-core)
      containing the client key to use.
    - `caCert.secretKeyRef`:
      [`SecretKeySelector`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#secretkeyselector-v1-core)
      containing a server CA certificate to use when verifying the server
      certificate.

See the
[Kafka Source](https://github.com/knative/eventing-contrib/tree/master/kafka/source/samples)
example.

### CamelSource

A CamelSource is an event source that can represent any existing
[Apache Camel component](https://github.com/apache/camel/tree/master/components)
that provides a consumer side, and enables publishing events to an addressable
endpoint. Each Camel endpoint has the form of a URI where the scheme is the ID
of the component to use.

CamelSource requires [Camel-K](https://github.com/apache/camel-k#installation)
to be installed into the current namespace.

**Spec fields**:

- source: information on the kind of Camel source that should be created.
  - component: the default kind of source, enables creating an EventSource by
    configuring a single Camel component.
    - uri: `string` contains the Camel URI that should be used to push events
      into the target sink.
    - properties: `key/value map` contains Camel global options or component
      specific configuration. Options are available in the documentation of each
      existing Apache Camel component.
- serviceAccountName: `string` an optional service account that can be used to
  run the source pod.
- image: `string` an optional base image to use for the source pod, mainly for
  development purposes.

See the
[CamelSource](https://github.com/knative/eventing-contrib/blob/master/contrib/camel/samples/README.md)
example.

## Getting Started

- [Setup Knative Serving](../install/README.md)
- [Install the Eventing component](#installation)
- [Run samples](./samples/)

## Configuration

- [Default Channels](./channels/default-channels.md) provide a way to choose the
  persistence strategy for Channels across the cluster.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
