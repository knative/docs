---
audience: administrator
components:
  - eventing
function: how-to
---

# Configuring Kafka Features

There are many different configuration options for how Knative Eventing and the Knaitve Broker for Apache Kafka interact with the Apache Kafka clusters.

## Configure Knative Eventing Kafka features

There are various kafka features/default values the Knative Kafka Broker uses when interacting with Kafka.

### Consumer Group ID for Triggers

The `triggers.consumergroup.template` value determines the template used to generate the consumer group ID used by your triggers.

* **Global key:** `triggers.consumergroup.template`
* **Possible values:**: Any valid [go text/template](https://pkg.go.dev/text/template)
* **Default:** `{% raw %}knative-trigger-{{ .Namespace }}-{{ .Name }}{% endraw %}`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-kafka-features
      namespace: knative-eventing
    data:
      triggers.consumergroup.template: {% raw %}"knative-trigger-{{ .Namespace }}-{{ .Name }}"{% endraw %}
    ```

### Broker topic name template

The `brokers.topic.template` values determines the template used to generate the Kafka topic names used by your brokers.

* **Global Key:** `brokers.topic.template`
* **Possible values:** Any valid [go text/template](https://pkg.go.dev/text/template)
* **Default:** `{% raw %}knative-broker-{{ .Namespace }}-{{ .Name }}{% endraw %}`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-kafka-features
      namespace: knative-eventing
    data:
      brokers.topic.template: {% raw %}"knative-broker-{{ .Namespace }}-{{ .Name }}"{% endraw %}
    ```

## Channel topic name template

The `channels.topic.template` value determines the template used to generate the kafka topic names used by your channels.

* **Global Key:** `controller-autoscaler-keda`
* **Possible values:** One of: `enabled`, `disabled`
* **Default:** `disabled`
* **Stability**: Alpha

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-kafka-features
      namespace: knative-eventing
    data:
      controller-autoscaler-keda: enabled
    ```

## Dispatcher autoscaling with KEDA

The `controller-autoscaler-keda` value determines whether Knative Kafka dispatcher components will autoscale with KEDA.
For more information on this feature, please read [the documentation here](../../../configuration/keda-configuration.md)
