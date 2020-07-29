An event source is a Kubernetes custom resource (CR), created by a developer or cluster administrator, that acts as a link between an event producer and an event _sink_.
A sink can be a Knative Service, Channel, or Broker that receives events from an event source.

Event sources are created by instantiating a CR from a Source object.
The Source object defines the arguments and parameters needed to instantiate a CR.

All Sources are part of the `sources` category.
You can list existing event sources on your cluster by entering the following command:
```
kubectl get sources
```
<!-- TODO(abrennan89): Add tab with kn commands-->

## Knative Sources

| Name | API Version | Maintainer | Description |
| -- | -- | -- | -- |
| [APIServerSource](https://github.com/knative/eventing/blob/master/pkg/apis/sources/v1alpha1/apiserver_types.go) | v1beta1 | Knative  | Brings Kubernetes API server events into Knative. The APIServerSource fires a new event each time a Kubernetes resource is created, updated or deleted. |
| [AWS SQS](https://github.com/knative/eventing-contrib/blob/master/awssqs/pkg/apis/sources/v1alpha1/aws_sqs_types.go)  | v1alpha1 | Knative | Brings [AWS Simple Queue Service](https://aws.amazon.com/sqs/) messages into Knative. The AwsSqsSource fires a new event each time an event is published on an [AWS SQS topic](https://aws.amazon.com/sqs/).  |
| [Apache Camel](https://github.com/knative/eventing-contrib/blob/master/camel/source/pkg/apis/sources/v1alpha1/camelsource_types.go) | v1alpha1   | Knative    | Enables use of [Apache Camel](https://github.com/apache/camel) components for pushing events into Knative. A CamelSource is an event source that can represent any existing [Apache Camel component](https://github.com/apache/camel/tree/master/components), that provides a consumer side, and enables publishing events to an addressable endpoint. Each Camel endpoint has the form of a URI where the scheme is the ID of the component to use. CamelSource requires [Camel-K](https://github.com/apache/camel-k#installation) to be installed into the current namespace. See the [CamelSource](https://github.com/knative/eventing-contrib/tree/master/camel/source/samples) example. |
| [Apache CouchDB](https://github.com/knative/eventing-contrib/blob/master/couchdb)                                                   | v1alpha1 | Knative    | Brings [Apache CouchDB](https://couchdb.apache.org/) messages into Knative.  |
| [Apache Kafka](https://github.com/knative/eventing-contrib/blob/master/kafka/source/pkg/apis/sources/v1alpha1/kafka_types.go)       | v1beta1  | Knative    | Brings [Apache Kafka](https://kafka.apache.org/) messages into Knative. The KafkaSource reads events from an Apache Kafka Cluster, and passes these to a Knative Serving application so that they can be consumed. See the [Kafka Source](https://github.com/knative/eventing-contrib/tree/master/kafka/source) example for more details.  |
| [Container Source](https://github.com/knative/eventing/blob/master/pkg/apis/sources/v1beta1/container_types.go)                     | v1beta1 | Knative    | The ContainerSource will instantiate container image(s) that can generate events until the ContainerSource is deleted. This may be used, for example, to poll an FTP server for new files or generate events at a set time interval. Given a `spec.template` with at least a container image specified, ContainerSource will keep a `Pod` running with the specified image(s). `K_SINK` (destination address) and `KE_CE_OVERRIDES` (JSON CloudEvents attributes) environment variables are injected into the running image(s). It is used by multiple other Sources as underlying infrastructure. Refer to the [Container Source](../samples/container-source) example for more details.  |
| [GitHub](https://github.com/knative/eventing-contrib/blob/master/github/pkg/apis/sources/v1alpha1/githubsource_types.go)            | v1alpha1 | Knative    | Registers for events of the specified types on the specified GitHub organization or repository, and brings those events into Knative. The GitHubSource fires a new event for selected [GitHub event types](https://developer.github.com/v3/activity/events/types/). See the [GitHub Source](../samples/github-source) example for more details.  |
| [GitLab](https://github.com/knative/eventing-contrib/blob/master/gitlab/pkg/apis/sources/v1alpha1/gitlabsource_types.go) | v1alpha1 | Knative    | Registers for events of the specified types on the specified GitLab repository, and brings those events into Knative. The GitLabSource creates a webhooks for specified [event types](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#events), listens for incoming events, and passes them to a consumer. See the [GitLab Source](../samples/gitlab-source) example for more details.  |
| [Heartbeats](https://github.com/knative/eventing-contrib/tree/master/cmd/heartbeats) |  N/A | Knative    | Uses an in-memory timer to produce events at the specified interval. |
| [PingSource](./pingsource.md) | v1alpha2  | Knative    | Produces events with a fixed payload on a specified [Cron](https://en.wikipedia.org/wiki/Cron) schedule. See the [Ping Source](../samples/ping-source) example for more details. |
| [SinkBinding](https://knative.dev/docs/eventing/samples/sinkbinding/)                                                               | v1alpha2           | Knative    | The SinkBinding can be used to author new event sources using any of the familiar compute abstractions that Kubernetes makes available (e.g. Deployment, Job, DaemonSet, StatefulSet), or Knative abstractions (e.g. Service, Configuration). SinkBinding provides a framework for injecting `K_SINK` (destination address) and `K_CE_OVERRIDES` (JSON cloudevents attributes) environment variables into any Kubernetes resource which has a `spec.template` that looks like a Pod (aka PodSpecable). See the [SinkBinding](../samples/container-source) example for more details. |
| [WebSocket](https://github.com/knative/eventing-contrib/tree/master/cmd/websocketsource)                                            | N/A | Knative    | Opens a WebSocket to the specified source and packages each received message as a Knative event.  |

## Third-Party Sources

| Name | API Version | Maintainer | Description
|--|--|--|--|
[Auto Container Source](https://github.com/Harwayne/auto-container-source) | Proof of Concept | None | AutoContainerSource is a controller that allows the Source CRDs _without_ needing a controller. It notices CRDs with a specific label and starts controlling resources of that type. It utilizes Container Source as underlying infrastructure.
[AWS CodeCommit](https://github.com/triggermesh/aws-event-sources/blob/master/cmd/awscodecommitsource/README.md) | Supported | TriggerMesh | Registers for events of the specified types on the specified AWS CodeCommit repository. Brings those events into Knative.
[AWS Cognito](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awscognitoidentitysource/README.md) | Supported | TriggerMesh | Registers for AWS Cognito events. Brings those events into Knative.
[AWS DynamoDB](https://github.com/triggermesh/aws-event-sources/blob/master/cmd/awsdynamodbsource/README.md) | Supported | TriggerMesh | Registers for events of on the specified AWS DynamoDB table. Brings those events into Knative.
[AWS Kinesis](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awskinesissource/README.md) | Supported | TriggerMesh | Registers for events on the specified AWS Kinesis stream. Brings those events into Knative.
[AWS SNS](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awssnssource) | Supported | TriggerMesh | Registers for events of the specified AWS SNS endpoint. Brings those events into Knative.
[AWS SQS](https://github.com/triggermesh/aws-event-sources/tree/master/cmd/awssqssource/README.md) | Supported | TriggerMesh | Registers for events of the specified AWS SQS queue. Brings those events into Knative.
[BitBucket](https://github.com/nachocano/bitbucket-source) | Proof of Concept | None | Registers for events of the specified types on the specified BitBucket organization/repository. Brings those events into Knative.
[CloudAuditLogsSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudauditlogssource/README.md) | Active Development | None | Registers for events of the specified types on the specified [Google Cloud Audit Logs](https://cloud.google.com/logging/docs/audit/). Brings those events into Knative. Refer to the [CloudAuditLogsSource](../samples/cloud-audit-logs-source) example for more details.
[CloudPubSubSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudpubsubsource/README.md) | Active Development | None | Brings [Cloud Pub/Sub](https://cloud.google.com/pubsub/) messages into Knative. The CloudPubSubSource fires a new event each time a message is published on a [Google Cloud Platform PubSub topic](https://cloud.google.com/pubsub/). See the [CloudPubSubSource](../samples/cloud-pubsub-source) example for more details.
[CloudSchedulerSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudschedulersource/README.md) | Active Development | None | Create, update, and delete [Google Cloud Scheduler](https://cloud.google.com/scheduler/) Jobs. When those jobs are triggered, receive the event inside Knative. See the [CloudSchedulerSource](../samples/cloud-scheduler-source) example for further details.
[CloudStorageSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudstoragesource/README.md) | Active Development | None | Registers for events of the specified types on the specified [Google Cloud Storage](https://cloud.google.com/storage/) bucket and optional object prefix. Brings those events into Knative. See the [CloudStorageSource](../samples/cloud-storage-source) example.
[FTP / SFTP](https://github.com/vaikas-google/ftp) | Proof of concept | None | Watches for files being uploaded into a FTP/SFTP and generates events for those.
[Heartbeat](https://github.com/Harwayne/auto-container-source/tree/master/heartbeat-source) | Proof of Concept | None | Uses an in-memory timer to produce events as the specified interval. Uses AutoContainerSource for underlying infrastructure.
[Konnek](https://konnek.github.io/docs/#/) | Active Development | None | Retrieves events from cloud platforms (like AWS and GCP) and transforms them into CloudEvents for consumption in Knative.
[K8s](https://github.com/Harwayne/auto-container-source/tree/master/k8s-event-source) | Proof of Concept | None | Brings Kubernetes cluster events into Knative. Uses AutoContainerSource for underlying infrastructure.
[VMware](https://github.com/vmware-tanzu/sources-for-knative/blob/master/pkg/apis/sources/v1alpha1/vspheresource_types.go) | Active Development | None | Brings [vSphere](https://www.vmware.com/products/vsphere.html) events into Knative.
[Knative-GCP](https://github.com/google/knative-gcp) | ? | ? | In order to consume events from different GCP services,  supports different GCP Sources.

## Eventing Contrib Sources

This is a non-exhaustive list of Sources supported by our community and maintained
in the [Knative Eventing-Contrib](https://github.com/knative/eventing-contrib) Github repo.

## Additional resources

- For information about creating your own Source type, see the [tutorial on writing a Source with a Receive Adapter](../samples/writing-event-source).
- If your code needs to send events as part of its business logic and doesn't fit the model of a Source, consider [feeding events directly to a Broker](https://knative.dev/docs/eventing/broker/).
