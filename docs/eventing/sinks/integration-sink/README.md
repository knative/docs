# Knative Sink for Apache Camel Kamelet integrations

![stage](https://img.shields.io/badge/Stage-alpah-red?style=flat-square)
![version](https://img.shields.io/badge/API_Version-v1alpha1-red?style=flat-square)

The `IntegrationSink` is a Knative Eventing custom resource supporting selected [_Kamelets_](https://camel.apache.org/camel-k/latest/kamelets/kamelets.html) from the [Apache Camel](https://camel.apache.org/) project. Kamelets allow users to connect to 3rd party system for improved connectivity, they can act as "sources" or as "sinks". Therefore the `IntegrationSink` allows sending data to external systems out of Knative Eventing in the format of CloudEvents. The integration sink is part of the Knative Eventing core installation.

## Supported Kamelet sinks

* [AWS S3](./aws_s3.md)
* [AWS SQS](./aws_sqs.md)
* [Generic logger](./logger.md)
