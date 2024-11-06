# AWS DynamoDB Streams

The `IntegrationSource` supports the Amazon Web Services (AWS) DynamoDB Streams service, through its `aws.ddbStreams` property.

## Amazon credentials

For connecting to AWS the `IntegrationSource` uses Kubernetes `Secret`, present in the namespace of the resource. The `Secret` can be created like:

    ```bash
    kubectl -n <namespace> create secret generic my-secret --from-literal=aws.accessKey=<accessKey> --from-literal=aws.secretKey=<secretKey>
    ```

## AWS DynamoDB Streams Example

Below is an `IntegrationSource` to receive events from Amazon DynamoDB Streams.

  ```yaml
  apiVersion: sources.knative.dev/v1alpha1
  kind: IntegrationSource
  metadata:
    name: integration-source-aws-ddb
    namespace: knative-samples
  spec:
    aws:
      ddbStreams:
        table: "my-table"
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

Inside of the `aws.ddbStreams` object we define the name of the table and its region. The credentials for the AWS service are referenced from the `my-secret` Kubernetes `Secret`

More details about the Apache Camel Kamelet [aws-ddb-streams-source](https://camel.apache.org/camel-kamelets/latest/aws-ddb-streams-source.html).
