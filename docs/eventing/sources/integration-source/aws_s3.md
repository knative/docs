# AWS S3 Source

The `IntegrationSource` supports the Amazon Web Services (AWS) S3 service, through its `aws.s3` property.

## Amazon credentials

For connecting to AWS the `IntegrationSource` uses Kubernetes `Secret`, present in the namespace of the resource. The `Secret` can be created like:

  ```bash
  kubectl -n <namespace> create secret generic my-secret --from-literal=aws.accessKey=<accessKey> --from-literal=aws.secretKey=<secretKey>
  ```

## AWS S3 Source Example

Below is an `IntegrationSource` to receive data from an Amazon S3 Bucket.

  ```yaml
  apiVersion: sources.knative.dev/v1alpha1
  kind: IntegrationSource
  metadata:
    name: integration-source-aws-s3
    namespace: knative-samples
  spec:
    aws:
      s3:
        arn: "arn:aws:s3:::my-bucket"
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

Inside of the `aws.s3` object we define the name of the bucket (or _arn_) and its region. The credentials for the AWS service are referenced from the `my-secret` Kubernetes `Secret`

More details about the Apache Camel Kamelet [aws-s3-source](https://camel.apache.org/camel-kamelets/latest/aws-s3-source.html).
