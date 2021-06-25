---
title: "Event sources"
weight: 20
type: "docs"
---

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






## Knative Sources

| Name | API Version | Maintainer | Description |
| -- | -- | -- | -- |
| [APIServerSource](./apiserversource) | v1 | Knative  | Brings Kubernetes API server events into Knative. The APIServerSource fires a new event each time a Kubernetes resource is created, updated or deleted. |
| [AWS SQS](https://github.com/knative-sandbox/eventing-awssqs/tree/main/samples)  | v1alpha1 | Knative | Brings [AWS Simple Queue Service](https://aws.amazon.com/sqs/) messages into Knative. The AwsSqsSource fires a new event each time an event is published on an [AWS SQS topic](https://aws.amazon.com/sqs/).  |
| [Apache Camel](./apache-camel-source) | N/A   | Apache Software Foundation    | Enables use of [Apache Camel](https://github.com/apache/camel) components for pushing events into Knative. Camel sources are now provided via [Kamelets](https://camel.apache.org/camel-kamelets/latest/) as part of the [Apache Camel K](https://camel.apache.org/camel-k/latest/installation/installation.html) project. |
| [Apache CouchDB](https://github.com/knative-sandbox/eventing-couchdb/blob/main/source)                                                   | v1alpha1 | Knative    | Brings [Apache CouchDB](https://couchdb.apache.org/) messages into Knative.  |
| [Apache Kafka](../samples/kafka)       | v1beta1  | Knative    | Brings [Apache Kafka](https://kafka.apache.org/) messages into Knative. The KafkaSource reads events from an Apache Kafka Cluster, and passes these events to a sink so that they can be consumed. See the [Kafka Source](https://github.com/knative-sandbox/eventing-kafka/blob/main/pkg/source) example for more details.  |
| [Container Source](./containersource.md)                    | v1 | Knative    | The ContainerSource will instantiate container image(s) that can generate events until the ContainerSource is deleted. This may be used, for example, to poll an FTP server for new files or generate events at a set time interval. Given a `spec.template` with at least a container image specified, ContainerSource will keep a `Pod` running with the specified image(s). `K_SINK` (destination address) and `KE_CE_OVERRIDES` (JSON CloudEvents attributes) environment variables are injected into the running image(s). It is used by multiple other Sources as underlying infrastructure. Refer to the [Container Source](./container-source) example for more details.  |
| [GitHub](./github-source)            | v1alpha1 | Knative    | Registers for events of the specified types on the specified GitHub organization or repository, and brings those events into Knative. The GitHubSource fires a new event for selected [GitHub event types](https://developer.github.com/v3/activity/events/types/). See the [GitHub Source](./github-source) example for more details.  |
| [GitLab](./gitlab-source) | v1alpha1 | Knative    | Registers for events of the specified types on the specified GitLab repository, and brings those events into Knative. The GitLabSource creates a webhooks for specified [event types](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#events), listens for incoming events, and passes them to a consumer. See the [GitLab Source](./gitlab-source) example for more details.  |
| [Heartbeats](https://github.com/knative/eventing/tree/main/cmd/heartbeats) |  N/A | Knative    | Uses an in-memory timer to produce events at the specified interval. |
| [PingSource](./ping-source) |  	v1beta2  | Knative    | Produces events with a fixed payload on a specified [Cron](https://en.wikipedia.org/wiki/Cron) schedule. See the [Ping Source](./ping-source) example for more details. |
| [RabbitMQ](https://github.com/knative-sandbox/eventing-rabbitmq) | Active development | None | Brings [RabbitMQ](https://www.rabbitmq.com/) messages into Knative.
| [SinkBinding](./sinkbinding/)                                                               |  	v1           | Knative    | The SinkBinding can be used to author new event sources using any of the familiar compute abstractions that Kubernetes makes available (e.g. Deployment, Job, DaemonSet, StatefulSet), or Knative abstractions (e.g. Service, Configuration). SinkBinding provides a framework for injecting `K_SINK` (destination address) and `K_CE_OVERRIDES` (JSON cloudevents attributes) environment variables into any Kubernetes resource which has a `spec.template` that looks like a Pod (aka PodSpecable). See the [SinkBinding](./container-source) example for more details. |
| [WebSocket](https://github.com/knative/eventing/tree/main/cmd/websocketsource)                                            | N/A | Knative    | Opens a WebSocket to the specified source and packages each received message as a Knative event.  |

## Third-Party Sources

| Name | API Version | Maintainer | Description
|--|--|--|--|
[Auto Container Source](https://github.com/Harwayne/auto-container-source) | Proof of Concept | None | AutoContainerSource is a controller that allows the Source CRDs _without_ needing a controller. It notices CRDs with a specific label and starts controlling resources of that type. It utilizes Container Source as underlying infrastructure.
[Amazon CloudWatch](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awscloudwatchsource) | Supported | TriggerMesh | Collects metrics from [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/).
[Amazon CloudWatch Logs](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awscloudwatchlogssource) | Supported | TriggerMesh | Subscribes to log events from an [Amazon CloudWatch Logs](https://aws.amazon.com/cloudwatch/) stream.
[Amazon CodeCommit](https://github.com/triggermesh/aws-event-sources/blob/master/cmd/awscodecommitsource/README.md) | Supported | TriggerMesh | Registers for events emitted by an [Amazon CodeCommit](https://aws.amazon.com/codecommit/) source code repository.
[Amazon Cognito Identity](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awscognitoidentitysource/README.md) | Supported | TriggerMesh | Registers for events from [Amazon Cognito](https://aws.amazon.com/cognito/) identity pools.
[Amazon Cognito User](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awscognitouserpoolsource/README.md) | Supported | TriggerMesh | Registers for events from [Amazon Cognito](https://aws.amazon.com/cognito/) user pools.
[Amazon DynamoDB](https://github.com/triggermesh/aws-event-sources/blob/master/cmd/awsdynamodbsource/README.md) | Supported | TriggerMesh | Reads records from an [Amazon DynamoDB](https://aws.amazon.com/dynamodb/) stream.
[Amazon Kinesis](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awskinesissource/README.md) | Supported | TriggerMesh | Reads records from an [Amazon Kinesis](https://aws.amazon.com/kinesis/) stream.
[Amazon SNS](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awssnssource/README.md) | Supported | TriggerMesh | Subscribes to messages from an [Amazon SNS](https://aws.amazon.com/sns/) topic.
[Amazon SQS](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awssqssource/README.md) | Supported | TriggerMesh | Consumes messages from an [Amazon SQS](https://aws.amazon.com/sqs/) queue.
[BitBucket](https://github.com/nachocano/bitbucket-source) | Proof of Concept | None | Registers for events of the specified types on the specified BitBucket organization/repository. Brings those events into Knative.
[CloudAuditLogsSource](https://github.com/google/knative-gcp/blob/main/docs/examples/cloudauditlogssource/README.md) | v1 | Google | Registers for events of the specified types on the specified [Google Cloud Audit Logs](https://cloud.google.com/logging/docs/audit/). Brings those events into Knative. Refer to the [CloudAuditLogsSource](./cloud-audit-logs-source) example for more details.
[CloudPubSubSource](https://github.com/google/knative-gcp/blob/main/docs/examples/cloudpubsubsource/README.md) | v1 | Google | Brings [Cloud Pub/Sub](https://cloud.google.com/pubsub/) messages into Knative. The CloudPubSubSource fires a new event each time a message is published on a [Google Cloud Platform PubSub topic](https://cloud.google.com/pubsub/). See the [CloudPubSubSource](./cloud-pubsub-source) example for more details.
[CloudSchedulerSource](https://github.com/google/knative-gcp/blob/main/docs/examples/cloudschedulersource/README.md) | v1 | Google | Create, update, and delete [Google Cloud Scheduler](https://cloud.google.com/scheduler/) Jobs. When those jobs are triggered, receive the event inside Knative. See the [CloudSchedulerSource](./cloud-scheduler-source) example for further details.
[CloudStorageSource](https://github.com/google/knative-gcp/blob/main/docs/examples/cloudstoragesource/README.md) | v1 | Google | Registers for events of the specified types on the specified [Google Cloud Storage](https://cloud.google.com/storage/) bucket and optional object prefix. Brings those events into Knative. See the [CloudStorageSource](./cloud-storage-source) example.
[DockerHubSource](https://github.com/tom24d/eventing-dockerhub) | v1alpha1 | None | Retrieves events from [Docker Hub Webhooks](https://docs.docker.com/docker-hub/webhooks/) and transforms them into CloudEvents for consumption in Knative.
[FTP / SFTP](https://github.com/vaikas-google/ftp) | Proof of concept | None | Watches for files being uploaded into a FTP/SFTP and generates events for those.
[GitHub Issue Comments](https://github.com/BrianMMcClain/github-issue-comment-source)| Proof of Concept | None | Polls a specific GitHub issue for new comments.
[Heartbeat](https://github.com/Harwayne/auto-container-source/tree/master/heartbeat-source) | Proof of Concept | None | Uses an in-memory timer to produce events as the specified interval. Uses AutoContainerSource for underlying infrastructure.
[Konnek](https://konnek.github.io/docs/#/) | Active Development | None | Retrieves events from cloud platforms (like AWS and GCP) and transforms them into CloudEvents for consumption in Knative.
[K8s](https://github.com/Harwayne/auto-container-source/tree/master/k8s-event-source) | Proof of Concept | None | Brings Kubernetes cluster events into Knative. Uses AutoContainerSource for underlying infrastructure.
[RedisSource](https://github.com/knative-sandbox/eventing-redis/tree/main/source) | v1alpha1 | None | Brings Redis Stream into Knative.
[Slack](https://github.com/triggermesh/knative-sources) | v1alpha1 | TriggerMesh | Subscribes to events from Slack.
[VMware](https://github.com/vmware-tanzu/sources-for-knative/blob/main/README.md) | Active Development | VMware | Brings [vSphere](https://www.vmware.com/products/vsphere.html) events into Knative.
[Zendesk](https://github.com/triggermesh/knative-sources) | v1alpha1 | TriggerMesh | Subscribes to events from Zendesk.

## Additional resources

- For information about creating your own Source type, see the [tutorial on writing a Source with a Receive Adapter](./creating-event-sources/writing-event-source).
- If your code needs to send events as part of its business logic and doesn't fit the model of a Source, consider [feeding events directly to a Broker](https://knative.dev/docs/eventing/broker/).
- For more information about using `kn` Source related commands, see the [`kn source` reference documentation](https://github.com/knative/client/blob/main/docs/cmd/kn_source.md).
