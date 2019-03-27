<!--
This is a generated file and should not be changed manually. All changes should follow the
procedure:

1. Update the information in [`sources.yaml`](sources.yaml).

2. Run the generator tool:
    ```shell
    go run eventing/sources/generator/main.go
    ```
-->

Event Sources are Kubernetes Custom Resources which provide a mechanism for registering interest in
a class of events from a particular software system. Since different event sources may be described
by different Custom Resources, this page provides an index of the available source resource types as
well as links to installation instructions.

This is a non-exhaustive list of Event sources for Knative.


### Inclusion in this list is not an endorsement, nor does it imply any level of support.


## Sources

These are sources that are installed as `CRD`s.

Name | Status | Support | Description
--- | --- | --- | ---
[AWS SQS](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/aws_sqs_types.go) | Proof of Concept | None | Brings [AWS Simple Quele Service](https://aws.amazon.com/sqs/) messages into Knative.
[Apache Kafka](https://github.com/knative/eventing-sources/blob/master/contrib/kafka/pkg/apis/sources/v1alpha1/kafka_types.go) | Proof of Concept | None | Brings [Apache Kafka](https://kafka.apache.org/) messages into Knative.
[Cron Job](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/cron_job_types.go) | Proof of Concept | None | Uses an in-memory timer to produce events on the specified Cron schedule.
[GCP PubSub](https://github.com/knative/eventing-sources/blob/master/contrib/gcppubsub/pkg/apis/sources/v1alpha1/gcp_pubsub_types.go) | Proof of Concept | None | Brings [GCP PubSub](https://cloud.google.com/pubsub/) messages into Knative.
[GitHub](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/githubsource_types.go) | Proof of Concept | None | Registers for events of the specified types on the specified GitHub organization/repository. Brings those events into Knative.
[GitLab](https://gitlab.com/triggermesh/gitlabsource) | Proof of Concept | None | Registers for events of the specified types on the specified GitLab repository. Brings those events into Knative.
[Google Cloud Scheduler](https://github.com/vaikas-google/csr) | Active Development | None | Create, update, and delete [Google Cloud Scheduler](https://cloud.google.com/scheduler/) Jobs. When those jobs are triggered, receive the event inside Knative.
[Google Cloud Storage](https://github.com/vaikas-google/gcs) | Active Development | None | Registers for events of the specified types on the specified Google Cloud Storage bucket and optional object prefix. Brings those events into Knative.
[Kubernetes](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/kuberneteseventsource_types.go) | Active Development | Knative | Brings Kubernetes cluster events into Knative. Uses ContainerSource for underlying infrastructure.



## Meta Sources

These are not directly usable, but make writing a Source much easier.

Name | Status | Support | Description
--- | --- | --- | ---
[Auto Container Source](https://github.com/Harwayne/auto-container-source) | Proof of Concept | None | AutoContainerSource is a controller that allows the Source CRDs _without_ needing a controller. It notices CRDs with a specific label and starts controlling resources of that type. It utilizes Container Source as underlying infrastructure.
[Container Source](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/containersource_types.go) | Active Development | Knative | Container Source is a generic controller. Given an Image URL, it will keep a single `Pod` running with the specified image, environment, and arguments. It is used by multiple other Sources as underlying infrastructure.
[Sample Source](https://github.com/grantr/sample-source) | Proof of Concept | None | SampleSource is a reference implementation supporting the [Writing an Event Source the Hard Way tutorial](../samples/writing-a-source).



### ContainerSource Containers

These are containers intended to be used with `ContainerSource`.

Name | Status | Support | Description
--- | --- | --- | ---
[AWS CodeCommit](https://github.com/triggermesh/knative-lambda-sources/tree/master/awscodecommit) | Active Development | TriggerMesh | Registers for events of the specified types on the specified AWS CodeCommit repository. Brings those events into Knative.
[AWS Cognito](https://github.com/triggermesh/knative-lambda-sources/tree/master/awscognito) | Active Development | TriggerMesh | Registers for AWS Cognito events. Brings those events into Knative.
[AWS DynamoDB](https://github.com/triggermesh/knative-lambda-sources/tree/master/awsdynamodb) | Active Development | TriggerMesh | Registers for events of on the specified AWS DynamoDB table. Brings those events into Knative.
[AWS Kinesis](https://github.com/triggermesh/knative-lambda-sources/tree/master/awskinesis) | Active Development | TriggerMesh | Registers for events on the specified AWS Kinesis stream. Brings those events into Knative.
[AWS SNS](https://github.com/triggermesh/knative-lambda-sources/tree/master/awssns) | Active Development | TriggerMesh | Registers for events of the specified AWS SNS endpoint. Brings those events into Knative.
[AWS SQS](https://github.com/triggermesh/knative-lambda-sources/tree/master/awssqs) | Active Development | TriggerMesh | Registers for events of the specified AWS SQS queue. Brings those events into Knative.
[Heartbeat](https://github.com/knative/eventing-sources/tree/master/cmd/heartbeats) | Proof of Concept | None | Uses an in-memory timer to produce events at the specified interval.
[Heartbeat](https://github.com/Harwayne/auto-container-source/tree/master/heartbeat-source) | Proof of Concept | None | Uses an in-memory timer to produce events as the specified interval. Uses AutoContainerSource for underlying infrastructure.
[K8s](https://github.com/Harwayne/auto-container-source/tree/master/k8s-event-source) | Proof of Concept | None | Brings Kubernetes cluster events into Knative. Uses AutoContainerSource for underlying infrastructure.
[WebSocket](https://github.com/knative/eventing-sources/tree/master/cmd/websocketsource) | Active Development | None | Opens a WebSocket to the specified source and packages each received message as a Knative event.

