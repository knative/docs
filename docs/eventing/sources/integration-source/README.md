# Knative Source for Apache Camel Kamelet integrations

![stage](https://img.shields.io/badge/Stage-alpah-red?style=flat-square)
![version](https://img.shields.io/badge/API_Version-v1alpha1-red?style=flat-square)

The `IntegrationSource` is a Knative Eventing custom resource supporting selected [_Kamelets_](https://camel.apache.org/camel-k/latest/kamelets/kamelets.html) from the [Apache Camel](https://camel.apache.org/) project. Kamelets allow users to connect to 3rd party system for improved connectivity, they can act as "sources" or as "sinks". Therefore the `IntegrationSource` allows to consume data from external systems and forward them into Knative Eventing. The integration source is part of the Knative Eventing core installation.

## Supported Kamelet sources

* [AWS DDB Streams](./aws_ddbstreams.md)
* [AWS S3](./aws_s3.md)
* [AWS SQS](./aws_sqs.md)
* [Generic timer](./timer.md)
