---
audience: developer
components:
  - eventing
function: how-to
---

# AWS Simple Queue Service Sink

The `IntegrationSink` supports the Amazon Web Services (AWS) Simple Queue Service (SQS) service, through its `aws.sqs` property.

## Amazon credentials

For connecting to AWS the `IntegrationSink` uses Kubernetes `Secret`, present in the namespace of the resource. The `Secret` can be created like:

  ```bash
  kubectl -n <namespace> create secret generic my-secret --from-literal=aws.accessKey=<accessKey> --from-literal=aws.secretKey=<secretKey>
  ```

## AWS SQS Sink Example

Below is an `IntegrationSink` to send data to AWS SQS:

  ```yaml
  apiVersion: sinks.knative.dev/v1alpha1
  kind: IntegrationSink
  metadata:
    name: integration-sink-aws-sqs
    namespace: knative-samples
  spec:
    aws:
      sqs:
        arn: "my-queue"
        region: "eu-north-1"
      auth:
        secret:
          ref:
            name: "my-secret"
  ```
Inside of the `aws.sqs` object we define the name of the queue (or _arn_) and its region. The credentials for the AWS service are referenced from the `my-secret` Kubernetes `Secret` 

More details about the Apache Camel Kamelet [aws-sqs-sink](https://camel.apache.org/camel-kamelets/latest/aws-sqs-sink.html).
