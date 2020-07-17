A Knative Eventing Source consists of a set of configuration parameters
for producing or registering interest in a class of events and
for relaying these events to another endpoint via [CloudEvents](https://cloudevents.io).

This page provides an index of the available source resource types as well as
links to their documentation.

## Knative Sources

| Name | API Version | Maintainer | Description |
| -- | -- | -- | -- |
| [APIServerSource](https://github.com/knative/eventing/blob/master/pkg/apis/sources/v1alpha1/apiserver_types.go) | v1alpha2 | Knative  | Brings Kubernetes API server events into Knative. |
| [AWS SQS](https://github.com/knative/eventing-contrib/blob/master/awssqs/pkg/apis/sources/v1alpha1/aws_sqs_types.go)  | v1alpha1 | Knative | Brings [AWS Simple Queue Service](https://aws.amazon.com/sqs/) messages into Knative.  |
| [Apache Camel](https://github.com/knative/eventing-contrib/blob/master/camel/source/pkg/apis/sources/v1alpha1/camelsource_types.go) | v1alpha1   | Knative    | Allows to use [Apache Camel](https://github.com/apache/camel) components for pushing events into Knative. |
| [Apache CouchDB](https://github.com/knative/eventing-contrib/blob/master/couchdb)                                                   | v1alpha1 | Knative    | Brings [Apache CouchDB](https://couchdb.apache.org/) messages into Knative.  |
| [Apache Kafka](https://github.com/knative/eventing-contrib/blob/master/kafka/source/pkg/apis/sources/v1alpha1/kafka_types.go)       | v1beta1  | Knative    | Brings [Apache Kafka](https://kafka.apache.org/) messages into Knative.  |
| [Container Source](https://github.com/knative/eventing/blob/master/pkg/apis/sources/v1beta1/container_types.go)                     | v1beta1 | Knative    | Given a `spec.template` with at least a container image specified, ContainerSource will keep a `Pod` running with the specified image(s). `K_SINK` (destination address) and `KE_CE_OVERRIDES` (JSON CloudEvents attributes) environment variables are injected into the running image(s). It is used by multiple other Sources as underlying infrastructure. |
| [GitHub](https://github.com/knative/eventing-contrib/blob/master/github/pkg/apis/sources/v1alpha1/githubsource_types.go)            | v1alpha1 | Knative    | Registers for events of the specified types on the specified GitHub organization/repository. Brings those events into Knative.  |
| [GitLab](https://github.com/knative/eventing-contrib/blob/master/gitlab/pkg/apis/sources/v1alpha1/gitlabsource_types.go) | v1alpha1 | Knative    | Registers for events of the specified types on the specified GitLab repository. Brings those events into Knative.  |
| [Heartbeats](https://github.com/knative/eventing-contrib/tree/master/cmd/heartbeats) |  N/A | Knative    | Uses an in-memory timer to produce events at the specified interval. |
| [PingSource](./pingsource.md) | v1alpha2  | Knative    | Produces events with a fixed payload on a specified cron schedule. |
| [SinkBinding](https://knative.dev/docs/eventing/samples/sinkbinding/)                                                               | v1alpha2           | Knative    | SinkBinding provides a framework for injecting `K_SINK` (destination address) and `K_CE_OVERRIDES` (JSON cloudevents attributes) environment variables into any Kubernetes resource which has a `spec.template` that looks like a Pod (aka PodSpecable). |
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
[CloudAuditLogsSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudauditlogssource/README.md) | Active Development | None | Registers for events of the specified types on the specified [Google Cloud Audit Logs](https://cloud.google.com/logging/docs/audit/). Brings those events into Knative.
[CloudPubSubSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudpubsubsource/README.md) | Active Development | None | Brings [Cloud Pub/Sub](https://cloud.google.com/pubsub/) messages into Knative.
[CloudSchedulerSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudschedulersource/README.md) | Active Development | None | Create, update, and delete [Google Cloud Scheduler](https://cloud.google.com/scheduler/) Jobs. When those jobs are triggered, receive the event inside Knative.
[CloudStorageSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudstoragesource/README.md) | Active Development | None | Registers for events of the specified types on the specified [Google Cloud Storage](https://cloud.google.com/storage/) bucket and optional object prefix. Brings those events into Knative.
[FTP / SFTP](https://github.com/vaikas-google/ftp) | Proof of concept | None | Watches for files being uploaded into a FTP/SFTP and generates events for those.
[Heartbeat](https://github.com/Harwayne/auto-container-source/tree/master/heartbeat-source) | Proof of Concept | None | Uses an in-memory timer to produce events as the specified interval. Uses AutoContainerSource for underlying infrastructure.
[Konnek](https://konnek.github.io/docs/#/) | Active Development | None | Retrieves events from cloud platforms (like AWS and GCP) and transforms them into CloudEvents for consumption in Knative.
[K8s](https://github.com/Harwayne/auto-container-source/tree/master/k8s-event-source) | Proof of Concept | None | Brings Kubernetes cluster events into Knative. Uses AutoContainerSource for underlying infrastructure.
[VMware](https://github.com/vmware-tanzu/sources-for-knative/blob/master/pkg/apis/sources/v1alpha1/vspheresource_types.go) | Active Development | None | Brings [vSphere](https://www.vmware.com/products/vsphere.html) events into Knative.
