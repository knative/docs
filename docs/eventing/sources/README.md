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
| [APIServerSource](apiserversource/README.md) | v1 | Knative  | Brings Kubernetes API server events into Knative. The APIServerSource fires a new event each time a Kubernetes resource is created, updated or deleted. |
| [AWS SQS](https://github.com/knative-sandbox/eventing-awssqs/tree/main/samples)  | v1alpha1 | Knative | Brings [AWS Simple Queue Service](https://aws.amazon.com/sqs/) messages into Knative. The AwsSqsSource fires a new event each time an event is published on an [AWS SQS topic](https://aws.amazon.com/sqs/).  |
| [Apache Camel](apache-camel-source/README.md) | N/A   | Apache Software Foundation    | Enables use of [Apache Camel](https://github.com/apache/camel) components for pushing events into Knative. Camel sources are now provided via [Kamelets](https://camel.apache.org/camel-kamelets/latest/) as part of the [Apache Camel K](https://camel.apache.org/camel-k/latest/installation/installation.html) project. |
| [Apache CouchDB](https://github.com/knative-sandbox/eventing-couchdb/blob/main/source)                                                   | v1alpha1 | Knative    | Brings [Apache CouchDB](https://couchdb.apache.org/) messages into Knative.  |
| [Apache Kafka](kafka-source/README.md)       | v1beta1  | Knative    | Brings [Apache Kafka](https://kafka.apache.org/) messages into Knative. The KafkaSource reads events from an Apache Kafka Cluster, and passes these events to a sink so that they can be consumed. See the [Kafka Source](https://github.com/knative-sandbox/eventing-kafka/blob/main/pkg/source) example for more details.  |
| [ContainerSource](../custom-event-source/containersource/README.md)                    | v1 | Knative    | The ContainerSource instantiates container image(s) that can generate events until the ContainerSource is deleted. This may be used, for example, to poll an FTP server for new files or generate events at a set time interval. Given a `spec.template` with at least a container image specified, the ContainerSource keeps a Pod running with the specified image(s). `K_SINK` (destination address) and `KE_CE_OVERRIDES` (JSON CloudEvents attributes) environment variables are injected into the running image(s). It is used by multiple other Sources as underlying infrastructure. Refer to the [Container Source](../custom-event-source/containersource/README.md) example for more details.  |
| [GitHub](../samples/github-source/README.md)            | v1alpha1 | Knative    | Registers for events of the specified types on the specified GitHub organization or repository, and brings those events into Knative. The GitHubSource fires a new event for selected [GitHub event types](https://developer.github.com/v3/activity/events/types/). See the [GitHub Source](../samples/github-source/README.md) example for more details.  |
| [GitLab](../samples/gitlab-source/README.md) | v1alpha1 | Knative    | Registers for events of the specified types on the specified GitLab repository, and brings those events into Knative. The GitLabSource creates a webhooks for specified [event types](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#events), listens for incoming events, and passes them to a consumer. See the [GitLab Source](../samples/gitlab-source/README.md) example for more details.  |
| [Heartbeats](https://github.com/knative/eventing/tree/main/cmd/heartbeats) |  N/A | Knative    | Uses an in-memory timer to produce events at the specified interval. |
| [KogitoSource](https://github.com/knative-sandbox/eventing-kogito) |  v1alpha1 | Knative    | An implementation of the [Kogito Runtime](https://docs.jboss.org/kogito/release/latest/html_single/#proc-kogito-deploying-on-kubernetes_kogito-deploying-on-openshift) custom resource managed by the [Kogito Operator](https://github.com/kiegroup/kogito-operator). |
| [PingSource](ping-source/README.md) |  	v1beta2  | Knative    | Produces events with a fixed payload on a specified [Cron](https://en.wikipedia.org/wiki/Cron) schedule. See the [Ping Source](ping-source/README.md) example for more details. |
| [RabbitMQ](https://github.com/knative-sandbox/eventing-rabbitmq) | Active development | None | Brings [RabbitMQ](https://www.rabbitmq.com/) messages into Knative.
| [SinkBinding](../custom-event-source/sinkbinding/README.md) | v1   | Knative    | The SinkBinding can be used to author new event sources using any of the familiar compute abstractions that Kubernetes makes available (e.g. Deployment, Job, DaemonSet, StatefulSet), or Knative abstractions (e.g. Service, Configuration). SinkBinding provides a framework for injecting `K_SINK` (destination address) and `K_CE_OVERRIDES` (JSON cloudevents attributes) environment variables into any Kubernetes resource which has a `spec.template` that looks like a Pod (aka PodSpecable). See the [SinkBinding](../custom-event-source/sinkbinding/README.md) example for more details. |
| [WebSocket](https://github.com/knative/eventing/tree/main/cmd/websocketsource)                                            | N/A | Knative    | Opens a WebSocket to the specified source and packages each received message as a Knative event.  |

## Third-Party Sources

| Name | API Version | Maintainer | Description
|--|--|--|--|
[AWS CodeCommit](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Registers for events emitted by an [AWS CodeCommit](https://aws.amazon.com/codecommit/) source code repository.
[Amazon CloudWatch Logs](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Subscribes to log events from an [Amazon CloudWatch Logs](https://aws.amazon.com/cloudwatch/) stream.
[Amazon CloudWatch](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Collects metrics from [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/).
[Amazon Cognito Identity](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Registers for events from [Amazon Cognito](https://aws.amazon.com/cognito/) identity pools.
[Amazon Cognito User](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Registers for events from [Amazon Cognito](https://aws.amazon.com/cognito/) user pools.
[Amazon DynamoDB](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Reads records from an [Amazon DynamoDB](https://aws.amazon.com/dynamodb/) stream.
[Amazon Kinesis](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Reads records from an [Amazon Kinesis](https://aws.amazon.com/kinesis/) stream.
[Amazon RDS Performance Insights](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Subscribes to metrics from [Amazon RDS Performance Insights](https://aws.amazon.com/rds/performance-insights/).
[Amazon SNS](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Subscribes to messages from an [Amazon SNS](https://aws.amazon.com/sns/) topic.
[Amazon SQS](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes messages from an [Amazon SQS](https://aws.amazon.com/sqs/) queue.
[Auto Container Source](https://github.com/Harwayne/auto-container-source) | Proof of Concept | None | AutoContainerSource is a controller that allows the Source CRDs _without_ needing a controller. It notices CRDs with a specific label and starts controlling resources of that type. It utilizes Container Source as underlying infrastructure.
[Azure Activity Logs](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes events from the [Azure Activity Logs](https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log).
[Azure Blob Storage](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes events from [Azure Blob Storage](https://azure.microsoft.com/en-us/services/storage/blobs/).
[Azure Event Grid](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Retrieve events from [Azure Event Grid](https://azure.microsoft.com/en-us/services/event-grid/).
[Azure Event Hubs](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes events from [Azure Event Hubs](https://azure.microsoft.com/en-us/services/event-hubs/).
[Azure IoT Hub](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes event from [Azure IoT Hub](https://azure.microsoft.com/en-us/services/iot-hub/).
[Azure Queue Storage](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Retrieve messages from [Azure Queue Storage](https://azure.microsoft.com/en-us/services/storage/queues/).
[Azure Service Bus](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes messages from an [Azure Service Bus](https://azure.microsoft.com/en-us/services/service-bus/) queue.
[BitBucket](https://github.com/nachocano/bitbucket-source) | Proof of Concept | None | Registers for events of the specified types on the specified BitBucket organization/repository. Brings those events into Knative.
[CloudAuditLogsSource](https://github.com/google/knative-gcp/blob/main/docs/examples/cloudauditlogssource/README.md) | v1 | Google | Registers for events of the specified types on the specified [Google Cloud Audit Logs](https://cloud.google.com/logging/docs/audit/). Brings those events into Knative. Refer to the [CloudAuditLogsSource](../samples/cloud-audit-logs-source/README.md) example for more details.
[CloudPubSubSource](https://github.com/google/knative-gcp/blob/main/docs/examples/cloudpubsubsource/README.md) | v1 | Google | Brings [Cloud Pub/Sub](https://cloud.google.com/pubsub/) messages into Knative. The CloudPubSubSource fires a new event each time a message is published on a [Google Cloud Platform PubSub topic](https://cloud.google.com/pubsub/). See the [CloudPubSubSource](../samples/cloud-pubsub-source/README.md) example for more details.
[CloudSchedulerSource](https://github.com/google/knative-gcp/blob/main/docs/examples/cloudschedulersource/README.md) | v1 | Google | Create, update, and delete [Google Cloud Scheduler](https://cloud.google.com/scheduler/) Jobs. When those jobs are triggered, receive the event inside Knative. See the [CloudSchedulerSource](../samples/cloud-scheduler-source/README.md) example for further details.
[CloudStorageSource](https://github.com/google/knative-gcp/blob/main/docs/examples/cloudstoragesource/README.md) | v1 | Google | Registers for events of the specified types on the specified [Google Cloud Storage](https://cloud.google.com/storage/) bucket and optional object prefix. Brings those events into Knative. See the [CloudStorageSource](../samples/cloud-storage-source/README.md) example.
[Direktiv](https://github.com/direktiv/direktiv-knative-source/tree/main/cmd/direktiv-source) | Proof of concept | Direktiv | Receive events from [Direktiv](https://github.com/direktiv/direktiv).
[DockerHubSource](https://github.com/tom24d/eventing-dockerhub) | v1alpha1 | None | Retrieves events from [Docker Hub Webhooks](https://docs.docker.com/docker-hub/webhooks/) and transforms them into CloudEvents for consumption in Knative.
[FTP / SFTP](https://github.com/vaikas-google/ftp) | Proof of concept | None | Watches for files being uploaded into a FTP/SFTP and generates events for those.
[GitHub Issue Comments](https://github.com/BrianMMcClain/github-issue-comment-source)| Proof of Concept | None | Polls a specific GitHub issue for new comments.
[Google Cloud Audit Logs](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Registers for events from [Google Cloud Audit Logs](https://cloud.google.com/logging/docs/audit/).
[Google Cloud Billing](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Retrieves events from [Google Cloud Billing](https://cloud.google.com/billing/).
[Google Cloud Pub/Sub](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Retrieves [Google Cloud Pub/Sub](https://cloud.google.com/pubsub/) messages.
[Google Cloud Source Repositories](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes events from [Google Cloud Source Repositories](https://cloud.google.com/source-repositories).
[Google Cloud Storage](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes events from [Google Cloud Storage](https://cloud.google.com/storage).
[HTTP Poller](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Periodically pulls events from an HTTP/S URL.
[Heartbeat](https://github.com/Harwayne/auto-container-source/tree/master/heartbeat-source) | Proof of Concept | None | Uses an in-memory timer to produce events as the specified interval. Uses AutoContainerSource for underlying infrastructure.
[K8s](https://github.com/Harwayne/auto-container-source/tree/master/k8s-event-source) | Proof of Concept | None | Brings Kubernetes cluster events into Knative. Uses AutoContainerSource for underlying infrastructure.
[Konnek](https://konnek.github.io/docs/#/) | Active Development | None | Retrieves events from cloud platforms (like AWS and GCP) and transforms them into CloudEvents for consumption in Knative.
[Oracle Cloud Infrastructure](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Retrieves metrics from [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/).
[RedisSource](https://github.com/knative-sandbox/eventing-redis/tree/main/source) | v1alpha1 | None | Brings Redis Stream into Knative.
[Salesforce](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Consumes events from a [Salesforce](https://www.salesforce.com) channel.
[Slack](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Subscribes to events from [Slack](https://slack.com).
[SNMP](https://github.com/direktiv/direktiv-knative-source/tree/main/cmd/snmp-source) | Proof of concept | Direktiv | Receive events via SNMP.
[Twilio](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Receive events from [Twilio](https://twilio.com).
[VMware](https://github.com/vmware-tanzu/sources-for-knative/blob/main/README.md) | Active Development | VMware | Brings [vSphere](https://www.vmware.com/products/vsphere.html) events into Knative.
[Webhook](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Ingest events from a webhook using HTTP.
[Zendesk](https://github.com/triggermesh/triggermesh/) | Supported | TriggerMesh | Subscribes to events from Zendesk.

## Additional resources

- If your code needs to send events as part of its business logic and doesn't fit the model of a Source, consider [feeding events directly to a Broker](https://knative.dev/docs/eventing/broker/).
- For more information about using `kn` Source related commands, see the [`kn source` reference documentation](https://github.com/knative/client/blob/main/docs/cmd/kn_source.md).
