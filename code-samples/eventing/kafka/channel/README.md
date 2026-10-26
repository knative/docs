# Apache Kafka Channel Example

You can install and configure the Apache Kafka Channel as the
default Channel configuration for Knative Eventing, or select Kafka for an
individual Channel.

## Prerequisites

- A Kubernetes cluster with
  [Knative Eventing and the Kafka Channel components](https://knative.dev/docs/install/eventing/install-eventing-with-yaml/).
- An Apache Kafka cluster reachable by the Kafka Channel components. Configure
  `bootstrap.servers` in the `kafka-channel-config` ConfigMap in the
  `knative-eventing` namespace, as described in the
  [KafkaChannel installation instructions](https://github.com/knative-extensions/eventing-kafka-broker/blob/main/docs/channel/README.md#installation).
- [Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml/)
  for the event display Service.

Clone this repository and use the checked-in manifests rather than copying them
from the guide:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/eventing/kafka/channel
```

The commands below use the `default` namespace for sample resources. A Broker
implementation is not required. Changing the default Channel configuration is an
administrator operation that affects the cluster; skip that change on shared
clusters unless you have permission.

## Creating a Kafka Channel

Apply [kafka-channel.yaml](kafka-channel.yaml) to create `my-kafka-channel`
with three partitions and replication factor one:

```bash
kubectl -n default apply -f kafka-channel.yaml
```

## Specifying Kafka as the default Channel implementation
<!--TODO: Move to admin guide-->

To configure Kafka Channel as the
[default channel configuration](https://knative.dev/docs/eventing/channels/channel-types-defaults),
review [default-ch-webhook.yaml](default-ch-webhook.yaml). Merge its
`default-ch-config` with the existing `default-ch-webhook` ConfigMap in
`knative-eventing`; preserve any existing namespace overrides. If you are
intentionally replacing the configuration with this example, apply it with:

```bash
kubectl apply -f default-ch-webhook.yaml
```

This selects `KafkaChannel` with three partitions and replication factor one
for generic Channels without an explicit implementation. It is not required
when using the per-Channel template in the next section.

## Creating an Apache Kafka channel

Choose **one** of these manifests to create `testchannel-one`:

- After KafkaChannel is configured as the default, use
  [channel-default.yaml](channel-default.yaml). This generic Channel inherits
  the administrator's default implementation:

    ```bash
    kubectl -n default apply -f channel-default.yaml
    ```

- On a shared cluster, use [channel.yaml](channel.yaml) **instead**. Its explicit
  `spec.channelTemplate` selects KafkaChannel with three partitions and
  replication factor one for this Channel only, without changing defaults:

    ```bash
    kubectl -n default apply -f channel.yaml
    ```

Wait for the Channel to become ready and check its backing implementation:

```bash
kubectl -n default wait --for=condition=Ready channels.messaging.knative.dev/testchannel-one --timeout=120s
kubectl -n default get channels.messaging.knative.dev/testchannel-one -o jsonpath='{.spec.channelTemplate}'
```

The template must identify `messaging.knative.dev/v1beta1`, `KafkaChannel`,
with `numPartitions: 3` and `replicationFactor: 1`.

You can also inspect the topics in your Kafka cluster. If you are using Strimzi,
you can run the command:

```bash
kubectl -n kafka exec -it my-cluster-kafka-0 -- bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --list
```

Topic names vary by KafkaChannel implementation and version; do not depend
on a particular topic naming convention. Check Channel readiness rather than
using a topic name alone to determine whether the Channel is working.

**Note:** The topic of a Kafka Channel is an implementation detail and records
from it should not be consumed from different applications.

## Sending events through the Kafka Channel

The following example uses an ApiServerSource to publish Kubernetes events to
`testchannel-one`, and a Subscription to deliver those events from the Channel
to a Knative Service. The separate `my-kafka-channel` created earlier demonstrates
the explicit KafkaChannel API and is not used in this event flow.

1. Apply [event-display.yaml](event-display.yaml) to create the Knative Service:

    ```bash
    kubectl -n default apply -f event-display.yaml
    ```

1. Apply [event-source-rbac.yaml](event-source-rbac.yaml) to create the
   ServiceAccount, Role and RoleBinding. These grant access to events only in
   the `default` namespace:

    ```bash
    kubectl -n default apply -f event-source-rbac.yaml
    ```

1. Apply [event-source.yaml](event-source.yaml) to create the ApiServerSource
   that sends events to the Channel:

    ```bash
    kubectl -n default apply -f event-source.yaml
    ```

1. Apply [subscription.yaml](subscription.yaml) to deliver events from the
   Channel to the Service:

    ```bash
    kubectl -n default apply -f subscription.yaml
    ```

1. Wait for the Service, Subscription and source to become ready, then create a
   Kubernetes event with a recognizable message:

    ```bash
    kubectl -n default wait --for=condition=Ready service.serving.knative.dev/kafka-display subscription/testevents-subscription apiserversource/testevents-kafka-03 --timeout=180s
    kubectl -n default create -f - <<'EOF'
    apiVersion: v1
    kind: Event
    metadata:
      name: kafka-channel-smoke
    involvedObject:
      apiVersion: messaging.knative.dev/v1
      kind: Channel
      name: testchannel-one
      namespace: default
    reason: KafkaChannelSmoke
    message: Kafka Channel smoke test
    type: Normal
    EOF
    ```

1. Verify delivery through the Kafka Channel by observing the Service logs:

    ```bash
    kubectl -n default logs --selector='serving.knative.dev/service=kafka-display' -c user-container --tail=100
    ```

    The logs should contain a CloudEvent of type
    `dev.knative.apiserver.resource.add` whose data includes the message
    `Kafka Channel smoke test`. Delivery is asynchronous; repeat the log command
    if necessary. Other Kubernetes events may also appear.

## Channel configuration

KafkaChannel provides various configuration options, such as:

- Authentication
- Encryption
- Kafka Topic default values (number of partitions, replication factor and
  retention time)
- The brokers string for your Kafka connection

For detailed information on configuration options, see the
[KafkaChannel README](https://github.com/knative-extensions/eventing-kafka-broker/blob/main/docs/channel/README.md).
