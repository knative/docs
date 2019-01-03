# Knative Event Sources

This is a non-exhaustive list of Event sources for Knative. Inclusion in this list **does not**
imply an endorsement, nor does it imply any level of support.

This is a generated file and should not be changed manually. All changes should follow the procedure
outlined in the [read me](README.md#updating-sourcesmd).

## Sources

These are sources that are installed as `CRD`s.

Name | Status | Support | Description
--- | --- | --- | ---
[AWS SQS](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/aws_sqs_types.go) | Proof of Concept | None | Brings [AWS Simple Quele Service](https://aws.amazon.com/sqs/) messages into Knative.
[Cron Job](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/cron_job_types.go) | Proof of Concept | None | Uses an in-memory timer to produce events on the specified Cron schedule.
[GCP PubSub](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/gcp_pubsub_types.go) | Proof of Concept | None | Brings [GCP PubSub](https://cloud.google.com/pubsub/) messages into Knative.
[GitHub](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/githubsource_types.go) | Proof of Concept | None | Registers for events of the specified types on the specified GitHub organization/repository. Brings those events into Knative.
[GitLab](https://gitlab.com/triggermesh/gitlabsource) | Proof of Concept | None | Registers for events of the specified types on the specified GitLab repository. Brings those events into Knative.
[Kubernetes](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/kuberneteseventsource_types.go) | Active Development | Knative | Brings Kubernetes cluster events into Knative. Uses ContainerSource for underlying infrastructure.
[Google Cloud Scheduler](https://github.com/vaikas-google/csr) | Active Development | None | Create, update, and delete [Google Cloud Scheduler](https://cloud.google.com/scheduler/) Jobs. When those jobs are triggered, receive the event inside Knative.



## Meta Sources

These are not directly usable, but make writing a Source much easier.

Name | Status | Support | Description
--- | --- | --- | ---
[Container Source](https://github.com/knative/eventing-sources/blob/master/pkg/apis/sources/v1alpha1/containersource_types.go) | Active Development | Knative | Container Source is a generic controller. Given an Image URL, it will keep a single `Pod` running with the specified image, environment, and arguments. It is used by multiple other Sources as underlying infrastructure.
[Auto Container Source](https://github.com/Harwayne/auto-container-source) | Proof of Concept | None | AutoContainerSource is a controller that allows the Source CRDs _without_ needing a controller. It notices CRDs with a specific label and starts controlling resources of that type. It utilizes Container Source as underlying infrastructure.



### ContainerSource Containers

These are containers intended to be used with `ContainerSource`.

Name | Status | Support | Description
--- | --- | --- | ---
[Heartbeat](https://github.com/knative/eventing-sources/tree/master/cmd/heartbeats) | Proof of Concept | None | Uses an in-memory timer to produce events at the specified interval.
[WebSocket](https://github.com/knative/eventing-sources/tree/master/cmd/websocketsource) | Active Development | None | Opens a WebSocket to the specified source and packages each received message as a Knative event.

