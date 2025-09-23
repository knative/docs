# AWS S3 Sink

The `IntegrationSink` supports the Amazon Web Services (AWS) S3 service, through its `aws.s3` property.

## Amazon credentials

For connecting to AWS the `IntegrationSink` uses Kubernetes `Secret`, present in the namespace of the resource. The `Secret` can be created like:

  ```bash
  kubectl -n <namespace> create secret generic my-secret --from-literal=aws.accessKey=<accessKey> --from-literal=aws.secretKey=<secretKey>
  ```

## AWS S3 Sink Example

Below is an `IntegrationSink` to send data to an Amazon S3 Bucket:

  ```yaml
  apiVersion: sinks.knative.dev/v1alpha1
  kind: IntegrationSink
  metadata:
    name: integration-sink-aws-s3
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
  ```

Inside of the `aws.s3` object we define the name of the bucket (or _arn_) and its region. The credentials for the AWS service are referenced from the `my-secret` Kubernetes `Secret`

More details about the Apache Camel Kamelet [aws-s3-sink](https://camel.apache.org/camel-kamelets/latest/aws-s3-sink.html).
