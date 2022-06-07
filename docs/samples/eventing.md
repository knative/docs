# Knative Eventing code samples

Use the following code samples to help you understand the various use cases for
Knative Eventing and Event Sources.
[Learn more about Knative Eventing and Eventing Sources](../eventing/README.md).

See [all Knative code samples](https://github.com/knative/docs/tree/main/code-samples) in GitHub.

| Name                 | Description                                         | Languages                                   |
| -------------------- | --------------------------------------------------- | --------------------------------------------|
| Hello World          | A quick introduction that highlights how to deploy an app using Knative. | [Go](https://github.com/knative/docs/tree/main/code-samples/eventing/helloworld/helloworld-go) and [Python](https://github.com/knative/docs/tree/main/code-samples/eventing/helloworld/helloworld-python) |
| CloudAuditLogsSource | Configure a CloudAuditLogsSource resource to read data from Cloud Audit Logs and directly publish to the underlying transport (Pub/Sub), in CloudEvents format. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/cloud-audit-logs-source) |
| CloudPubSubSource    | Configure a CloudPubSubSource that fires a new event each time a message is published on a Cloud Pub/Sub topic. This source sends events using a Push-compatible format. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/cloud-pubsub-source) |
| CloudSchedulerSource | Configure a CloudSchedulerSource resource for receiving scheduled events from Google Cloud Scheduler. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/cloud-scheduler-source) |
| CloudStorageSource   | Configure a CloudStorageSource resource to deliver Object Notifications for when a new object is added to Google Cloud Storage (GCS). | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/cloud-storage-source) |
| GitHub source        | Shows how to wire GitHub events for consumption by a Knative Service. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/github-source) |
| GitLab source        | Shows how to wire GitLab events for consumption by a Knative Service. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/gitlab-source) |
| Apache Kafka Binding | KafkaBinding is responsible for injecting Kafka bootstrap connection information into a Kubernetes resource that embed a PodSpec (as `spec.template.spec`). This enables easy bootstrapping of a Kafka client. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/kafka/binding) |
| Apache Kafka Channel | Install and configure the Apache Kafka Channel as the default Channel configuration for Knative Eventing. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/kafka/channel) |
| Writing an event source using JavaScript | This tutorial provides instructions to build an event source in JavaScript and implement it with a ContainerSource or SinkBinding. | [JavaScript](https://github.com/knative/docs/tree/main/code-samples/eventing/writing-event-source-easy-way) |
| Parallel with multiple cases           | Create a Parallel with two branches. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/parallel/multiple-branches) |
| Parallel with mutually exclusive cases | Create a Parallel with mutually exclusive branches. | [YAML](https://github.com/knative/docs/tree/main/code-samples/eventing/parallel/mutual-exclusivity) |
