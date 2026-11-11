---
audience: developer
components:
  - eventing
function: how-to
---

# Handling Delivery Failure

Configure Broker retries and a dead-letter sink, then confirm that a deliberately
failed event reaches that sink in an isolated test. For an existing workload
that is already failing, start with
[Events repeatedly fail delivery](troubleshooting/delivery-failures.md).

Field definitions, implementation support, and failure extensions now live in
the [Event delivery reference](reference/event-delivery.md).
[Brokers](brokers/README.md#event-delivery) explains why behavior depends on the
Broker implementation.

## Prerequisites and scope

- Knative Eventing and a Broker implementation are installed, and you can
  create Brokers and Triggers with `kubectl`.
- Use a disposable namespace with no production event producers. Set
  `NAMESPACE` to it below. This test creates a new Broker rather than breaking a
  subscriber on an existing route.
- Verify that the selected Broker class supports `retry`, `backoffPolicy`,
  `backoffDelay`, and `deadLetterSink` in its release-specific implementation
  documentation. The [historical support table](reference/event-delivery.md#broker-support)
  is only a starting point, not validated current compatibility. For an
  MTChannelBasedBroker, check the underlying Channel too. This example uses a
  Knative Service sink and does not apply to the `googlecloud` Broker's Pub/Sub
  topic destination requirement.
- In the test namespace, provide a Ready Knative Service named `example-sink`
  that records received CloudEvents and returns a successful HTTP response.
  You must be able to inspect its event IDs.
- Provide a Kubernetes Service named `failing-subscriber` in the same namespace
  whose receiver records event IDs and **deliberately returns HTTP 500** for
  event POSTs. Confirm this behavior independently before using it here. A
  missing Service or invalid address may prevent the Trigger from becoming
  Ready instead of exercising delivery retries.
- An HTTP client can reach the Broker address. The send command below assumes
  in-cluster plain HTTP is permitted; if your cluster requires authentication
  or TLS, use an approved client configured for those requirements instead.

This is a configuration how-to, not a complete receiver deployment tutorial.
Do not point the failure test at a production application.

## Configure a test Broker

1. Set the namespace and check for name collisions. If a named resource below
   already exists, choose different names consistently in the manifests and
   commands rather than overwriting or deleting it. Stop on permission or
   connection errors; only `NotFound` establishes that a name is available.

    ```bash
    NAMESPACE=<test-namespace>
    kubectl -n "$NAMESPACE" get broker with-dead-letter-sink
    kubectl -n "$NAMESPACE" get trigger delivery-failure-test
    kubectl -n "$NAMESPACE" get pod delivery-failure-client
    ```

    An interrupted curl run can leave `delivery-failure-client` behind despite
    `--rm`. Inspect any existing Pod and retain its logs/event ID before retrying.
    Only if you confirm that it belongs to your test and is no longer running,
    delete that Pod with `kubectl -n "$NAMESPACE" delete pod delivery-failure-client`.
    Otherwise choose a new client Pod name; do not delete an unrelated or active
    client. Repeat the Pod lookup immediately before the send command if the test
    was interrupted or resumed.

1. Save this manifest as `broker-delivery.yaml`. If the cluster default is not
   the implementation you checked, add the appropriate Broker class and
   configuration from [Creating a Broker](brokers/create-broker.md).

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      name: with-dead-letter-sink
    spec:
      delivery:
        deadLetterSink:
          ref:
            apiVersion: serving.knative.dev/v1
            kind: Service
            name: example-sink
        backoffDelay: PT1S
        backoffPolicy: exponential
        retry: 3
    ```

    These are explicit example settings, not defaults. The API describes
    `retry` as a minimum; do not infer an exact attempt count or schedule from
    `retry: 3`. See the reference's
    [API and shared-sender retry semantics](reference/event-delivery.md#retry-and-backoff-semantics).

1. Apply and inspect the Broker:

    ```bash
    kubectl -n "$NAMESPACE" apply -f broker-delivery.yaml
    kubectl -n "$NAMESPACE" wait --for=condition=Ready broker/with-dead-letter-sink --timeout=60s
    kubectl -n "$NAMESPACE" get broker with-dead-letter-sink -o yaml
    ```

    Confirm `spec.delivery` contains your settings and examine status for
    conditions and the resolved dead-letter destination if exposed by your
    implementation. If it is not Ready, resolve that condition before sending
    an event; [troubleshoot readiness](troubleshooting/events-not-delivered.md#broker-or-trigger-is-not-ready).

## Route a controlled failure

1. Save this manifest as `delivery-failure-trigger.yaml`:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: delivery-failure-test
    spec:
      broker: with-dead-letter-sink
      filter:
        attributes:
          type: dev.knative.delivery.failure-test
      subscriber:
        ref:
          apiVersion: v1
          kind: Service
          name: failing-subscriber
    ```

1. Apply it and wait for readiness:

    ```bash
    kubectl -n "$NAMESPACE" apply -f delivery-failure-trigger.yaml
    kubectl -n "$NAMESPACE" wait --for=condition=Ready trigger/delivery-failure-test --timeout=60s
    ```

1. Send one event with a distinct ID. For a cluster allowing plain HTTP, the
   following starts a temporary curl Pod in the test namespace:

    ```bash
    BROKER_URL=$(kubectl -n "$NAMESPACE" get broker with-dead-letter-sink -o jsonpath='{.status.address.url}')
    EVENT_ID="delivery-failure-test-$(date +%s)"
    printf 'Event ID: %s\n' "$EVENT_ID"
    kubectl -n "$NAMESPACE" run delivery-failure-client \
      --image=curlimages/curl --rm=true --restart=Never -i -- \
      -v "$BROKER_URL" \
      -H 'Content-Type: application/json' \
      -H 'Ce-Specversion: 1.0' \
      -H 'Ce-Source: /delivery-failure-test' \
      -H 'Ce-Type: dev.knative.delivery.failure-test' \
      -H "Ce-Id: $EVENT_ID" \
      -d '{"message":"controlled delivery failure"}'
    ```

    A successful Broker ingress response alone does not prove delivery to the
    subscriber or the dead-letter sink.

## Confirm dead-letter delivery

1. Inspect the failure receiver's records for the event ID and HTTP 500
   responses. Confirm that retry attempts occur using receiver records and,
   where available, implementation logs or metrics. Do not infer exact timing
   solely from the configured backoff values.
1. Inspect `example-sink`'s records for the **same event ID** after the failed
   delivery attempts. This receipt, rather than Ready status or the ingress
   response, verifies the dead-letter route.
1. If the event never reaches the sink, follow
   [Events repeatedly fail delivery](troubleshooting/delivery-failures.md#events-do-not-reach-the-dead-letter-sink).
   Do not assume every implementation adds the same failure extensions.

## Apply the verified settings to an existing workload

After the isolated test succeeds, edit the existing Broker manifest's
`spec.delivery` with settings and a sink appropriate to that workload. Retain
its class, configuration, and other fields. Review `kubectl diff`, apply in the
correct namespace, and check the Broker's status again. Broker-level delivery
changes may affect multiple routes: inventory its Triggers and any
implementation-specific Trigger overrides before changing it. This guide does
not establish override precedence; consult your implementation's documentation.
Do not force a production failure to verify the change.

## Clean up the test

Delete only the resources created for this test:

```bash
kubectl -n "$NAMESPACE" delete trigger delivery-failure-test
kubectl -n "$NAMESPACE" delete broker with-dead-letter-sink
```

Remove the two test receivers only if you created them for this exercise.

## Configuring Subscription event delivery

[Subscription delivery fields and example](reference/event-delivery.md#configuring-subscription-event-delivery).
For the Subscription task context, see [Subscriptions](channels/subscriptions.md).

## Configuring Broker event delivery

[Broker delivery fields and example](reference/event-delivery.md#configuring-broker-event-delivery).
The task above configures and verifies a Broker dead-letter route.

### Broker support

[Broker implementation support table](reference/event-delivery.md#broker-support).

## Configuring Channel event delivery

[Implementation-dependent failure extensions](reference/event-delivery.md#configuring-channel-event-delivery).

### Channel support

[Channel implementation support table](reference/event-delivery.md#channel-support).

These section links retain destinations for older field-reference URLs.
