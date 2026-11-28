---
audience: developer
components:
  - functions
  - eventing
function: how-to
hide_prev: true
hide_next: true
---

# Connect events

Deliver events to a function either through a Knative Eventing **Broker** and
**Trigger**, or directly from an **Apache Kafka** topic using a runtime sidecar.

## Broker subscription { #configure-a-broker-subscription }

**Requirements (Broker path):**

- An initialized function project using the `cloudevents` template
  (`func create -l <language> -t cloudevents <name>`), with a handler that logs
  or otherwise makes received events observable.
- A Kubernetes cluster with Knative Serving and Knative Eventing installed, and
  a ready Broker in your target namespace (for example `default`, or
  `example-broker` if reusing a Quickstart cluster).
- Registry push and cluster pull access as described in
  [Deploy a function](deploying-functions.md#requirements).

`func subscribe` records event subscription filters in `func.yaml` — it does
not modify the cluster until you deploy.

Pass `--source` with your Broker's name (if omitted, `func` defaults to a
Broker named `default`) and one or more `--filter` key/value pairs (all filters
must match):

=== "func"

    ```bash
    func subscribe \
      --source example-broker \
      --filter type=dev.knative.example
    ```

=== "kn func"

    ```bash
    kn func subscribe \
      --source example-broker \
      --filter type=dev.knative.example
    ```

Repeat `--filter key=value` to require additional CloudEvent attributes or
extensions. To change or remove subscriptions later, edit `deploy.subscriptions`
in `func.yaml` and redeploy.

## Deploy and verify delivery

Use the same target namespace (`<namespace>`) for deployment, Trigger checks,
and logs (pass `-n <namespace>` consistently if you are not using the current
context's namespace).

1. Deploy from inside the project directory. `func deploy` creates or updates
   the Knative Service and creates the matching Knative Triggers on the cluster:

    ```bash
    func deploy --registry <registry> -n <namespace>
    ```

1. Confirm the generated Trigger is ready (`READY=True`):

    ```bash
    kn trigger list -n <namespace>
    ```

1. Send a matching CloudEvent (`type: dev.knative.example`) to `example-broker`
   — for example using the CloudEvents Player from
   [Try Eventing](../getting-started/getting-started-eventing.md) or another
   event source connected to that Broker.

1. Verify your function received the event by checking its pod logs (or other
   observable effect from your handler):

    ```bash
    kubectl logs -n <namespace> \
      -l serving.knative.dev/service=<function-name> -c user-container
    ```

    Confirm your handler logged the event's ID and payload. Direct
    `func invoke` calls the function directly and does not verify Broker
    routing or Trigger filters.

<span id="kafka-functions"></span>

## Consume Kafka records

A function can also consume records directly from an Apache Kafka topic without
a Knative Eventing Broker. When `func.yaml` declares a `run.kafka`
configuration, `func` deploys a language-agnostic sidecar that consumes the
topic and delivers each record to your function as a CloudEvent over HTTP, so
your function needs no Kafka client code.

**Requirements (Kafka path):**

- An initialized `cloudevents` function project and container registry push/pull
  access.
- An accessible Apache Kafka cluster and topic.
- The **KEDA** or **raw** deployer — direct Kafka consumption (`run.kafka`) is
  **not** supported with the default Knative Serving deployer (KEDA requires
  KEDA installed on the cluster).

For the full walkthrough — including concepts, delivery and retries, scaling,
idempotency, local development, and troubleshooting — see the upstream guides:

- [Kafka functions guide](https://github.com/knative/func/blob/main/docs/kafka-functions/README.md){target=_blank}
- [`run.kafka` configuration reference](https://github.com/knative/func/blob/main/docs/reference/func_yaml.md#runkafka){target=_blank}
