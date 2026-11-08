---
audience: administrator
components:
  - eventing
function: how-to
---

Investigating an existing workload? Go directly to
[Read existing workload logs](#read-existing-workload-logs). The collector setup
below is a separate, optional platform-owner task, not a prerequisite for reading
logs already available through Kubernetes or your log provider.

--8<-- "collecting-logs.md"

## Read existing workload logs

Use this section to retrieve evidence for an existing Broker/Trigger route.
You need permission to read the relevant Pods and their logs, or access to the
existing log provider. Ask the application owner for subscriber logs and the
platform owner for the identified Broker implementation's controller/data-plane
logs. The Pod namespace and container differ by implementation and deployment;
there is no universal Eventing selector in this procedure.

1. In your existing log provider, search the affected namespace/resource and the
   recorded event ID and time window. Ask the owner which records correspond to
   ingress, filtering/dispatch, and subscriber receipt. Not every implementation
   logs event IDs or every successful send; an absent log entry alone is not
   proof that an event never reached that stage.
1. If the owner identifies a specific Pod and you have access, inspect its
   container names and read the relevant container's logs. Confirm the intended
   context without switching it; replace the placeholders with actual values:

    ```bash
    kubectl config current-context
    POD_NAMESPACE=<identified-pod-namespace>
    POD_NAME=<identified-pod-name>
    kubectl -n "$POD_NAMESPACE" get pod "$POD_NAME" -o jsonpath='{.spec.containers[*].name}'
    ```

    Select the container identified by the owner, and set `--since` to cover the
    event's time window (30 minutes is only an example):

    ```bash
    CONTAINER=<identified-container-name>
    kubectl -n "$POD_NAMESPACE" logs "$POD_NAME" -c "$CONTAINER" --since=30m --timestamps=true
    ```

    If that container restarted and its previous instance's logs are available,
    the same command with `--previous` reads that instance. It does not recover
    logs from a deleted Pod or guarantee that older records are retained.
1. Correlate available records with the event ID/time window, original and
   resolved destinations, and observed response or transport error. Redact
   credentials and sensitive payloads before sharing. If access or records are
   missing, request redacted evidence from the responsible owner and record the
   gap; do not infer successful delivery or loss from missing logs alone.

Installing a collector cannot retroactively recover unretained logs. Do not
install logging components, restart Pods, or change logging configuration as
part of this read-only inspection. If future collection is needed, hand the
requirement to the platform owner using
[Setting up logging components](#setting-up-logging-components). That optional
setup changes cluster resources and requires its own approval and permissions.

Return to [Events do not reach a subscriber](../../troubleshooting/events-not-delivered.md)
or [Events repeatedly fail delivery](../../troubleshooting/delivery-failures.md)
with the evidence you obtained.
