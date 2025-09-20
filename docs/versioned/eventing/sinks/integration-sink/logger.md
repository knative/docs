---
audience: developer
components:
  - eventing
function: how-to
---

# Log Sink

The `IntegrationSink` supports the _Log Sink Kamelet_ that logs all data that it receives, through its `log` property. This sink useful for debugging purposes.

## Log Sink Example

Below is an `IntegrationSink` that logs all data that it receives:

  ```yaml
  apiVersion: sinks.knative.dev/v1alpha1
  kind: IntegrationSink
  metadata:
    name: integration-log-sink
    namespace: knative-samples
  spec:
    log:
      showHeaders: true
      level: INFO
  ```

Inside of the `log` object we define the logging `level` and define to also show (HTTP) headers it received.

More details about the Apache Camel Kamelet [timer-sink](https://camel.apache.org/camel-kamelets/latest/timer-sink.html).
