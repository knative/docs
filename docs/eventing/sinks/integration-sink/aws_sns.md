---
audience: developer
components:
  - eventing
function: how-to
---

# AWS Simple Notification Service Sink

The `IntegrationSink` supports the Amazon Web Services (AWS) Simple Notification Service (SNS) service, through its `aws.sns` property.

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

If you are using IRSA or Pod Identity, you can create a Kubernetes `ServiceAccount` and associate it with an AWS IAM role. Then in the `IntegrationSink` `.spec.aws.auth` section specify the name of the `ServiceAccount`. This will assign the `ServiceAccount` to the `Deployment` resource created for the `IntegrationSink`.
```yaml
      auth:
        serviceAccountName: "my-service-account"
```

## AWS SNS Sink Example

Below is an `IntegrationSink` to send data to AWS SNS:

  ```yaml
  apiVersion: sinks.knative.dev/v1alpha1
  kind: IntegrationSink
  metadata:
    name: integration-sink-aws-sns
    namespace: knative-samples
  spec:
    aws:
      sns:
        arn: "my-topic"
        region: "eu-north-1"
      auth:
        secret:
          ref:
          name: "my-secret"
  ```
Inside of the `aws.sns` object we define the name of the topic (or _arn_) and its region. The credentials for the AWS service are referenced from the `my-secret` Kubernetes `Secret`

More details about the Apache Camel Kamelet [aws-sns-sink](https://camel.apache.org/camel-kamelets/latest/aws-sns-sink.html).
