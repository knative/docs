---
audience: developer
components:
  - eventing
function: how-to
---

# AWS S3 Sink

The `IntegrationSink` supports the Amazon Web Services (AWS) S3 service, through its `aws.s3` property.

## Amazon credentials

There are two options for authenticating to AWS.

### Access key and secret

To use an IAM User access key and secret, create a Kubernetes `Secret` in the namespace of the resource. The `Secret` can be created like:

  ```bash
  kubectl -n <namespace> create secret generic my-secret --from-literal=aws.accessKey=<accessKey> --from-literal=aws.secretKey=<secretKey>
  ```
Then in the `IntegrationSink` `.spec.aws.auth` section reference the `Secret` like this:
```yaml
      auth:
        secret:
          ref:
            name: "my-secret"
```

### Pod Default Credentials

If you are using [IAM Role for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) or [Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html), you can create a Kubernetes `ServiceAccount` and associate it with an AWS IAM role. Then in the `IntegrationSink` `.spec.aws.auth` section specify the name of the `ServiceAccount`. This will assign the `ServiceAccount` to the `Deployment` resource created for the `IntegrationSink`.
```yaml
      auth:
        serviceAccountName: "my-service-account"
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
