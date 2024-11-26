# AWS Simple Queue Service Source

The `IntegrationSource` supports the Amazon Web Services (AWS) Simple Queue Service (SQS) service, through its `aws.sqs` property.

## Amazon credentials

For connecting to AWS the `IntegrationSource` uses Kubernetes `Secret`, present in the namespace of the resource. The `Secret` can be created like:

    ```bash
    kubectl -n <namespace> create secret generic my-secret --from-literal=aws.accessKey=<accessKey> --from-literal=aws.secretKey=<secretKey>
    ```

## AWS SQS Source Example

Below is an `IntegrationSource` to receive data from AWS SQS.

  ```yaml
  apiVersion: sources.knative.dev/v1alpha1
  kind: IntegrationSource
  metadata:
    name: integration-source-aws-sqs
    namespace: knative-samples
  spec:
    aws:
      sqs:
        arn: "arn:aws:s3:::my-queue"
        region: "eu-north-1"
      auth:
        secret:
          ref:
          name: "my-secret"
    sink:
      ref:
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        name: default
  ```
Inside of the `aws.sqs` object we define the name of the queue (or _arn_) and its region. The credentials for the AWS service are referenced from the `my-secret` Kubernetes `Secret` 

More details about the Apache Camel Kamelet [aws-sqs-source](https://camel.apache.org/camel-kamelets/latest/aws-sqs-source.html).
