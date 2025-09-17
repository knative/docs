---
audience: developer
components:
  - eventing
function: how-to
---

# AWS S3 Source

The `IntegrationSource` supports the Amazon Web Services (AWS) S3 service, through its `aws.s3` property.

## Amazon credentials

There are two options for authenticating to AWS.

### Access key and secret

To use an IAM User access key and secret, create a Kubernetes `Secret` in the namespace of the resource. The `Secret` can be created like:

  ```bash
  kubectl -n <namespace> create secret generic my-secret --from-literal=aws.accessKey=<accessKey> --from-literal=aws.secretKey=<secretKey>
  ```
Then in the `IntegrationSource` `.spec.aws.auth` section reference the `Secret` like this:
```yaml
      auth:
        secret:
          ref:
            name: "my-secret"
```

### Pod Default Credentials

If you are using IRSA or Pod Identity, you can create a Kubernetes `ServiceAccount` and associate it with an AWS IAM role. Then in the `IntegrationSource` `.spec.aws.auth` section specify the name of the `ServiceAccount`. This will assign the `ServiceAccount` to the `Deployment` resource created for the `IntegrationSource`.
```yaml
      auth:
        serviceAccountName: "my-service-account"
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
