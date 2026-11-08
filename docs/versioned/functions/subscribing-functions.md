---
audience: developer
components:
  - functions
function: how-to
---

# Subscribe functions to CloudEvents

Configure which Broker events should reach a function, then deploy that configuration as Knative Triggers. `func subscribe` writes subscription metadata to the local `func.yaml`; it does **not** create a Trigger on the cluster by itself.

### Prerequisites

- You have [installed the CLI](install-func.md) and opened the initialized function project directory.
- The handler accepts CloudEvents; use an appropriate [CloudEvents template](creating-functions.md#choose-a-language-and-template) or implement the corresponding handler contract.
- The handler satisfies the event response contract, not merely accepts an event POST. Return a successful HTTP response with an **empty body**—for example, `204 No Content`—or a valid reply CloudEvent with a successful status. A generic HTTP greeting body is not automatically a valid event-sink response. The [MTChannelBasedBroker v1.24 response handler](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/broker/filter/filter_handler.go#L551-L583){target=_blank} rejects non-empty responses that are not recognized as CloudEvents and rejects malformed reply events.
- Knative Serving and Eventing are installed on the intended cluster. You can deploy the function and create Triggers in the intended namespace.
- A [Broker](../eventing/brokers/create-broker.md) exists and is Ready in that namespace. The name `default` is a convention, not a guarantee that a Broker exists.
- You know the attributes of the events the producer sends **to that Broker**, and can send a matching test event using the producer's documented procedure.
- You meet the [deployment prerequisites](deploying-functions.md#prerequisites), including registry access when building/pushing.

### Procedure

--8<-- "proc-subscribe-function.md"

### Deployment with Triggers

Inspect `deploy.subscriptions` in `func.yaml` to confirm the Broker and filters, then deploy using the [deployment guide](deploying-functions.md). Only configured subscriptions result in Triggers; the CLI's "Creating Triggers" message alone is not proof that a subscription exists.

Before any deployment, select the intended cluster and the Broker's namespace in this shell:

--8<-- "func-cluster-context.md"

!!! warning "Existing generated-name Triggers, including first deployment"
    In Functions from Knative v1.24.0, the [Knative deployer](https://github.com/knative/func/blob/knative-v1.24.0/pkg/knative/deployer.go#L389-L440){target=_blank} ignores an already-existing generated Trigger rather than updating it. This can hide a **first-deployment name collision**, not just stale filters after redeployment. Inspect any existing `<function-name>-function-trigger-<index>` resources before deploying; the index corresponds to the entry in `deploy.subscriptions`.

    Compare the Trigger owner reference's **apiVersion, kind, name, and UID** with the live Knative Service you are authorized to manage (`serving.knative.dev/v1`, `Service`, its name, and its current `metadata.uid`). Also compare `spec.subscriber.ref`, `spec.broker`, and `spec.filter.attributes` with that Service and the intended subscription. A matching generated-looking name is not evidence of ownership.

    **Stop** if the owner is absent, foreign, or refers to an older Service UID, or if any intended routing/filter setting differs. If no function Service exists yet, an existing generated-name Trigger cannot be assumed to belong to the Service you are about to create. Consult the resource owner and the [Eventing Trigger guide](../eventing/triggers/README.md) for an authorized resolution; do not delete shared resources or assume redeployment updates them.

For read-only preflight inspection, replace `hello` with your project name and use the guarded context/namespace:

```bash
FUNCTION_NAME=hello
check_func_context && kubectl --context "$EXPECTED_CONTEXT" get kservice "$FUNCTION_NAME" --namespace "$NAMESPACE" -o yaml
check_func_context && kubectl --context "$EXPECTED_CONTEXT" get triggers --namespace "$NAMESPACE"
```

For a new Service, `NotFound` is expected for the Service check; still inspect any colliding Trigger names. Authentication/permission failures are not evidence that no resources exist—stop and ask the operator. Inspect relevant Trigger YAML as shown under [verification](#verify-event-delivery) before deciding it is safe to proceed.

If the project's registry is already configured and these checks pass, deploy to the Broker's namespace:

=== "func"

    Deploy the function with Triggers by running the command inside the project directory:

    ```bash
    check_func_context && func deploy --remote=false --deployer=knative --namespace "$NAMESPACE"
    ```

=== "kn func"

    Deploy the function with Triggers by running the command inside the project directory:

    ```bash
    check_func_context && kn func deploy --remote=false --deployer=knative --namespace "$NAMESPACE"
    ```

!!! Success "Example output"
    ```{ .bash .no-copy }
        🙌 Function image built: <registry>/hello:latest
        🎯 Creating Triggers on the cluster
        ✅ Function deployed in namespace "default" and exposed at URL:
        http://hello.default.127.0.0.1.sslip.io
    ```

    Your image, namespace, and URL will differ. Use your deployment's values for verification.

## Verify event delivery

Keep the same guarded kubeconfig/current context, `FUNCTION_NAME`, and Broker namespace used for deployment. Use read-only checks:

```bash
check_func_context && kubectl --context "$EXPECTED_CONTEXT" get broker --namespace "$NAMESPACE"
check_func_context && kubectl --context "$EXPECTED_CONTEXT" get kservice "$FUNCTION_NAME" --namespace "$NAMESPACE" -o yaml
check_func_context && kubectl --context "$EXPECTED_CONTEXT" get triggers --namespace "$NAMESPACE"
```

Repeat the full owner apiVersion/kind/name/UID and subscriber/Broker/filter comparisons from preflight, using the live Service's current UID. Stop on a foreign/stale owner or configuration mismatch; an existing name does not make a Trigger automatically safe to update. For Functions from Knative v1.24.0, the first generated name is typically `hello-function-trigger-0`; use the actual name in your namespace:

```bash
check_func_context && kubectl --context "$EXPECTED_CONTEXT" get trigger hello-function-trigger-0 --namespace "$NAMESPACE" -o yaml
check_func_context && kubectl --context "$EXPECTED_CONTEXT" describe trigger hello-function-trigger-0 --namespace "$NAMESPACE"
```

Check the Broker, subscriber, filters, and Ready condition. Then verify a **fresh, correlated delivery**, not just any earlier handler response:

1. Prepare a new test event with a fresh CloudEvents `id` and record its send time. If your handler does not expose the ID, use a unique payload correlation marker supported by the application and record it instead.
2. Send that event to the **Broker** through your producer's documented path, with all filter attributes matching. For the example filters above, both `type=com.example` and `extension=my-extension-value` must match.
3. Inspect the function's logs or application result in the corresponding test time window. Confirm the same fresh event ID or correlation marker from this Broker test; old log entries, a generic "received" message, or an earlier direct `func invoke` response do not establish this delivery.

Correlating a fresh event ID establishes receipt, not successful acknowledgment. Also verify the handler's response and check the Broker's delivery diagnostics for response-contract failures during the test window. Record repeated receipts separately: successful acknowledgment does not prove that no retries occurred, and this check does not establish exactly-once delivery. A fresh receipt accompanied by an invalid-response error is not a successful delivery check.

If your available output cannot identify the fresh event, report the delivery check as **inconclusive**, not successful. Consult the application owner for a supported correlation/observability method rather than inventing a logging guarantee.

`func invoke --target=remote` bypasses the Broker; it can isolate handler/endpoint problems but cannot verify this subscription. If the handler works directly but events do not arrive, follow [Events are not delivered](../eventing/troubleshooting/events-not-delivered.md). Stop at permission or ownership barriers and pass the condition output to the responsible operator; do not infer that every missing event is a handler failure.
