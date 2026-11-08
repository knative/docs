---
audience: administrator
components:
  - serving
function: how-to
---

!!! important "Choose the configuration authority"
    For an Operator-managed Serving installation, change the existing `KnativeServing` resource through `spec.config`; do not edit the generated `config-observability` ConfigMap. For an installation managed directly through YAML, update its authoritative ConfigMap manifest or use the labeled direct-edit route below. The monitoring stack itself is separate from the Knative Operator. If you already have a metrics backend, adapt the example to it rather than installing a second stack.

**Select the cluster before using the monitoring setup.** Replace these values before any Helm installation or port-forward command:

```bash
CONTEXT=my-cluster-context
SERVING_NAMESPACE=knative-serving
SERVING_RESOURCE=knative-serving
kubectl config get-contexts
kubectl --context "$CONTEXT" get services.serving.knative.dev -n "$SERVING_NAMESPACE"
```

Confirm the named context is the intended cluster and the read succeeds. Stop on a connection or permission error; do not continue using a different default context. `SERVING_RESOURCE` is the Operator resource name and is needed only for that route. Keep these variables available when using the shared setup and commands below; set the same `CONTEXT` in any additional terminal before port-forwarding. Cluster-targeting Helm commands must use `--kube-context "$CONTEXT"`, and cluster-targeting `kubectl` commands must use `--context "$CONTEXT"`; do not run them against an implicit default context. This does not change your kubeconfig's defaults. Inspect the monitoring example's values and target namespaces before installing it.

These examples target a same-cluster installation; use the [multi-cluster Operator guide](../../../install/operator/multi-cluster-deployment.md) for remote targets. You need list permission on Knative Services for the preflight, and the installation permissions required by your monitoring stack.

--8<-- "collecting-metrics.md"

## Before changing Serving configuration

- Identify your installation's configuration authority and retain its previous values for recovery. If GitOps manages it, update and synchronize that source instead of creating competing live changes.
- You need permission to read the component configuration and update either the `KnativeServing` resource or the ConfigMap, according to that authority. Installing monitor resources also requires permissions for the monitoring stack.
- The backend must support the chosen protocols. This example scrapes control-plane Prometheus endpoints and pushes request metrics through OTLP HTTP to Prometheus's enabled OTLP receiver. Verify that your backend has that receiver enabled and is reachable from the Serving workloads; configuring an endpoint alone does not establish connectivity.

Continue using the context and namespace selected before the monitoring setup.

### Enabling Metric Collection

Use the following values for the example monitoring stack, or substitute your backend endpoints. Merge only the intended settings into the existing configuration; the tracing entries shown here are retained from the monitoring example, not required merely to enable metrics. Preserve your existing tracing policy if you are not changing it.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-observability
  namespace: knative-serving
data:
  metrics-protocol: prometheus
  request-metrics-protocol: http/protobuf
  request-metrics-endpoint: http://knative-kube-prometheus-st-prometheus.observability.svc:9090/api/v1/otlp/v1/metrics
  # Optional tracing settings from the example stack:
  tracing-protocol: http/protobuf
  tracing-endpoint: http://jaeger-collector.observability.svc:4318/v1/traces
  tracing-sampling-rate: "1"
```

For protocol identifiers and other settings, consult the [Serving observability ConfigMap](https://github.com/knative/serving/blob/knative-v1.23.0/config/core/configmaps/observability.yaml){target=_blank}, checking the corresponding release for your installation.

=== "Operator-managed Serving"

    Inspect the current custom resource and its authoritative source manifest:

    ```bash
    kubectl --context "$CONTEXT" get knativeserving "$SERVING_RESOURCE" -n "$SERVING_NAMESPACE" -o yaml
    ```

    Check `spec.config` for `config-observability` and `observability` before selecting an entry to change. Use the existing winning entry; do not add a shortened entry that is shadowed by a full-name entry, even if the full-name entry is empty. Do not delete an existing entry merely to bypass its precedence. Consult the [ConfigMap mapping reference](../../../install/operator/configuration-reference.md#configmap-mapping) for the lookup rules.

    Merge the intended `data` values from the example into that entry under `spec.config`, not as a complete ConfigMap resource. Preserve unrelated keys. If neither naming form exists, choose one form according to the mapping reference. After selecting the entry through the mapping reference, follow the [generic Serving Operator apply/verify workflow](../../../install/operator/configuring-serving-cr.md#apply-and-verify-a-configuration-change) for authoritative application, resource status, and recovery. Check `config-observability` as the affected resource and perform the backend checks below. Do not follow the separate domain example or its `config-domain` guards, and do not run the direct-edit command in the next tab.

=== "YAML-managed Serving"

    Update the intended `data` keys in your authoritative `config-observability` manifest and apply it through your normal configuration workflow, preserving unrelated values and the actual component namespace.

    For an installation not managed by either the Operator or GitOps, you can edit the ConfigMap directly:

    ```bash
    kubectl --context "$CONTEXT" edit configmap config-observability -n "$SERVING_NAMESPACE"
    ```

    Merge the intended example values into `data`. See [Working with ConfigMaps](../../../admin/editing-configmaps.md) for the distinction between active values and documentation in `_example`.

Apply the ServiceMonitors/PodMonitors to collect Serving control-plane metrics:

```bash
kubectl --context "$CONTEXT" apply -f https://raw.githubusercontent.com/knative-extensions/monitoring/main/config/serving-monitors.yaml
```

These are resources for the example monitoring stack, not values to put under the Knative Operator's `spec.config`. Check their namespaces and selectors against your stack before applying them.

### Verify collection

1. Inspect the active configuration after your chosen workflow has propagated it:

    ```bash
    kubectl --context "$CONTEXT" get configmap config-observability -n "$SERVING_NAMESPACE" -o yaml
    ```

    Confirm that active `data` contains your intended metric protocols and endpoint, not merely an `_example` description. For the Operator route, also confirm that the custom resource reports Ready through the linked generic apply/verify workflow. These checks verify configuration propagation, not receipt of metrics.

2. Open the Prometheus console using the access instructions above, or your existing backend's interface. In Prometheus's **Targets** view, confirm that the expected Serving control-plane targets are present and **UP**, and that queries return recent samples. Missing targets suggest monitor selection/discovery problems; targets that are present but down require checking reachability and scrape errors.

3. Verify request-metric delivery separately. Send requests to a known Ready Service using the [deployment request checks](../../services/creating-services.md#verify-readiness-and-a-response). In your backend, select an exposed request metric for that Service/Revision and confirm fresh samples and request counts reflecting the test traffic. Use the [Serving metrics reference](serving-metrics.md) to identify the relevant instruments and attributes; exported names depend on the backend's format. A healthy control-plane scrape does not prove that request metrics reached the OTLP receiver.

If request samples remain absent, check the receiver configuration, endpoint, and network access from the workloads before assuming collection succeeded. To recover configuration, restore the recorded values through the same authoritative workflow and repeat both propagation and backend checks; do not restore Operator-managed values by editing the generated ConfigMap.

### Import Grafana dashboards

1. Grafana dashboards can be imported from the [`monitoring` repository](https://github.com/knative-extensions/monitoring).

1. If you are using the Grafana Helm Chart with the dashboard sidecar enabled (the default), you can load the dashboards by applying the following ConfigMaps:

    ```bash
    kubectl --context "$CONTEXT" apply -f https://raw.githubusercontent.com/knative-extensions/monitoring/main/config/configmap-serving-dashboard.json
    ```

    Confirm that the dashboards appear in Grafana and show recent data from the intended backend. An imported dashboard without data does not verify metric collection.
