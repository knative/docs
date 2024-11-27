# Event sources

An event source is a Kubernetes custom resource (CR), created by a developer or cluster administrator, that acts as a link between an event producer and an event _sink_.
A sink can be a k8s service, including Knative Services, a Channel, or a Broker that receives events from an event source.

Event sources are created by instantiating a CR from a Source object.
The Source object defines the arguments and parameters needed to instantiate a CR.

All Sources are part of the `sources` category.

=== "kn"
    You can list existing event sources on your cluster by entering the kn command:

    ```bash
    kn source list
    ```

=== "kubectl"
    You can list existing event sources on your cluster by entering the command:

    ```bash
    kubectl get sources
    ```

!!! note
    Event Sources that import events from other messaging technologies such as Kafka or RabbitMQ are not responsible for setting [Optional Attributes](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#optional-attributes) such as the `datacontenttype`. This is a responsibility of the original event producer; the Source just appends attributes if they exist.

## Knative Sources

| Name | Status | Maintainer | Description |
| -- | -- | -- | -- |
| [Amazon DynamoDB](integration-source/aws_ddbstreams.md) | Alpha | Knative  | Receive event notifications from an Amazon DynamoDB Streams. |
| [Amazon S3](integration-source/aws_s3.md) | Alpha | Knative  | Receive event notifications from an Amazon S3 Bucket. |
| [Amazon SQS](integration-source/aws_sqs.md) | Alpha | Knative  | Receive event notifications from an Amazon SQS queue. |
| [APIServerSource](apiserversource/README.md) | Stable | Knative  | Brings Kubernetes API server events into Knative. The APIServerSource fires a new event each time a Kubernetes resource is created, updated or deleted. |
| [Apache CouchDB](https://github.com/knative-extensions/eventing-couchdb/blob/main/source)                                                   | Alpha | Knative    | Brings [Apache CouchDB](https://couchdb.apache.org/) messages into Knative.  |
| [Apache Kafka](kafka-source/README.md)       | Stable  | Knative    | Brings [Apache Kafka](https://kafka.apache.org/) messages into Knative. The KafkaSource reads events from an Apache Kafka Cluster, and passes these events to a sink so that they can be consumed. See the [Kafka Source](https://github.com/knative-extensions/eventing-kafka/blob/main/pkg/source) example for more details.  |
| [CephSource](https://github.com/knative-extensions/eventing-ceph) | Beta | Knative    | The Ceph source converts bucket notifications from [Ceph format](https://docs.ceph.com/docs/master/radosgw/notifications/#events) into CloudEvents format, and inject them into Knative. Conversion logic follow the one described for [AWS S3](https://github.com/cloudevents/spec/blob/master/adapters/aws-s3.md) bucket notifications. |
| [ContainerSource](../custom-event-source/containersource/README.md)                    | Stable | Knative    | The ContainerSource instantiates container image(s) that can generate events until the ContainerSource is deleted. This may be used, for example, to poll an FTP server for new files or generate events at a set time interval. Given a `spec.template` with at least a container image specified, the ContainerSource keeps a Pod running with the specified image(s). `K_SINK` (destination address) and `KE_CE_OVERRIDES` (JSON CloudEvents attributes) environment variables are injected into the running image(s). It is used by multiple other Sources as underlying infrastructure. Refer to the [Container Source](../custom-event-source/containersource/README.md) example for more details.  |
| [Generic Timer](integration-source/timer.md) | Alpha | Knative  | Produces periodic messages with a custom payload. |
| [GitHub](https://github.com/knative/docs/tree/main/code-samples/eventing/github-source)            | Beta | Knative    | Registers for events of the specified types on the specified GitHub organization or repository, and brings those events into Knative. The GitHubSource fires a new event for selected [GitHub event types](https://developer.github.com/v3/activity/events/types/). See the [GitHub Source](https://github.com/knative/docs/tree/main/code-samples/eventing/github-source) example for more details.  |
| [GitLab](https://github.com/knative/docs/tree/main/code-samples/eventing/gitlab-source) | Beta | Knative    | Registers for events of the specified types on the specified GitLab repository, and brings those events into Knative. The GitLabSource creates a webhooks for specified [event types](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#events), listens for incoming events, and passes them to a consumer. See the [GitLab Source](https://github.com/knative/docs/tree/main/code-samples/eventing/gitlab-source) example for more details.  |
| [KogitoSource](https://github.com/knative-extensions/eventing-kogito) |  Alpha | Knative    | An implementation of the [Kogito Runtime](https://docs.jboss.org/kogito/release/latest/html_single/#proc-kogito-deploying-on-kubernetes_kogito-deploying-on-openshift) custom resource managed by the [Kogito Operator](https://github.com/kiegroup/kogito-operator). |
| [PingSource](ping-source/README.md) | Stable | Knative    | Produces events with a fixed payload on a specified [Cron](https://en.wikipedia.org/wiki/Cron) schedule. See the [Ping Source](ping-source/README.md) example for more details. |
| [RabbitMQ](https://github.com/knative-extensions/eventing-rabbitmq) | Stable | Knative | Brings [RabbitMQ](https://www.rabbitmq.com/) messages into Knative. |
| [RedisSource](https://github.com/knative-extensions/eventing-redis) | Beta | Knative | Brings Redis Stream into Knative. |
| [SinkBinding](../custom-event-source/sinkbinding/README.md) | Stable | Knative    | The SinkBinding can be used to author new event sources using any of the familiar compute abstractions that Kubernetes makes available (e.g. Deployment, Job, DaemonSet, StatefulSet), or Knative abstractions (e.g. Service, Configuration). SinkBinding provides a framework for injecting `K_SINK` (destination address) and `K_CE_OVERRIDES` (JSON cloudevents attributes) environment variables into any Kubernetes resource which has a `spec.template` that looks like a Pod (aka PodSpecable). See the [SinkBinding](../custom-event-source/sinkbinding/README.md) example for more details. |

## Third-Party Sources

| Name | Status | Maintainer | Description
|--|--|--|--|
[Apache Camel](https://camel.apache.org/camel-kamelets/latest) | Stable | Apache Software Foundation    | Enables use of [Apache Camel](https://github.com/apache/camel) components for pushing events into Knative. Camel sources are now provided via [Kamelets](https://camel.apache.org/camel-kamelets/latest/) as part of the [Apache Camel K](https://camel.apache.org/camel-k/latest/installation/installation.html) project. |
[Debezium](https://debezium.io) | Alpha | Debezium | Consume database changes as CloudEvents in Knative. ([knative configuration](https://github.com/cab105/debezium-knative-integration-sample))
[Direktiv](https://github.com/direktiv/direktiv-knative-source/tree/main/cmd/direktiv-source) | Alpha | Direktiv | Receive events from [Direktiv](https://github.com/direktiv/direktiv).
[DockerHubSource](https://github.com/tom24d/eventing-dockerhub) | Alpha | None | Retrieves events from [Docker Hub Webhooks](https://docs.docker.com/docker-hub/webhooks/) and transforms them into CloudEvents for consumption in Knative.
[VMware](https://github.com/vmware-tanzu/sources-for-knative/blob/main/README.md) | Alpha | VMware | Brings [vSphere](https://www.vmware.com/products/vsphere.html) events into Knative.

## Additional resources

- If your code needs to send events as part of its business logic and doesn't fit the model of a Source, consider [feeding events directly to a Broker](https://knative.dev/docs/eventing/broker/).
- For more information about using `kn` Source related commands, see the [`kn source` reference documentation](https://github.com/knative/client/blob/main/docs/cmd/kn_source.md).
