---
title: "Fluentd container image requirements"
linkTitle: "Fluentd requirements"
weight: 10
type: "docs"
---

Knative Serving uses a [Fluentd](https://www.fluentd.org/) docker image to
collect logs. Operators can customize their own Fluentd docker image and
configuration to define logging output.

## Requirements

Knative requires the customized Fluentd docker image with the following plugins
installed:

- [fluentd](https://github.com/fluent/fluentd) >= v0.14.0
- [fluent-plugin-kubernetes_metadata_filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) >=
  1.0.0 AND < 2.1.0: To enrich log entries with Kubernetes metadata.
- [fluent-plugin-detect-exceptions](https://github.com/GoogleCloudPlatform/fluent-plugin-detect-exceptions) >=
  0.0.9: To combine multi-line exception stack traces logs into one log entry.
- [fluent-plugin-multi-format-parser](https://github.com/repeatedly/fluent-plugin-multi-format-parser) >=
  1.0.0: To detect log format as Json or plain text.

## Sample images

Operators can use any Docker image which meets the requirements above and
includes the desired output plugin. Two examples below:

### Send logs to Elasticsearch

Operators can use
[k8s.gcr.io/fluentd-elasticsearch:v2.0.4](https://github.com/kubernetes/kubernetes/tree/{{< branch >}}/cluster/addons/fluentd-elasticsearch/fluentd-es-image)
which includes
[fluent-plugin-elasticsearch](https://github.com/uken/fluent-plugin-elasticsearch)
that allows sending logs to a Elasticsearch service.

### Send logs to Stackdriver

This sample [Dockerfile](./stackdriver/Dockerfile) is based on
[k8s.gcr.io/fluentd-elasticsearch:v2.0.4](https://github.com/kubernetes/kubernetes/tree/{{< branch >}}/cluster/addons/fluentd-elasticsearch).
It additionally adds one more plugin -
[fluent-plugin-google-cloud](https://github.com/GoogleCloudPlatform/fluent-plugin-google-cloud)
which allows sending logs to Stackdriver.

Operators can build this image and push it to a container registry which their
Kubernetes cluster has access to. See
[Setting Up A Logging Plugin](./setting-up-a-logging-plugin.md) for details.

> **NOTE**: Operators must add the credentials file the Stackdriver agent needs
> to the Docker image if their Knative Serving is not built on a Google Cloud
> Platform-based cluster or if they want to send logs to another Google Cloud
> Platform project. See
> [here](https://cloud.google.com/logging/docs/agent/authorization) for more
> information.
