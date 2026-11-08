---
audience: administrator
components:
  - eventing
function: how-to
---

Before any installation or configuration change, identify the owner and
configuration authority for this Eventing installation. You need approval and
permissions for the target cluster/namespace, an authoritative manifest, and a
recoverable record of the previous value (including whether it was absent).
If GitOps manages the resource, change that source through its normal workflow.

- **Knative Operator-managed:** change the existing `KnativeEventing` resource,
  not the generated `config-observability` ConfigMap. Follow the
  [Operator ConfigMap mapping reference](../../../install/operator/configuration-reference.md#configmap-mapping)
  and [Eventing configuration apply/verify procedure](../../../install/operator/configuring-eventing-cr.md#apply-and-verify-a-configuration-change).
- **YAML-managed:** update the authoritative ConfigMap manifest or use an
  explicitly approved direct-edit workflow, preserving unrelated data.
- **Unknown authority or read-only access:** ask the platform owner to identify
  the authority or perform the change; do not begin by editing a live ConfigMap.

Establish the approved target **before** any shared monitoring setup below.
Replace both placeholders, keep these values for this page's commands, and
inspect the selected context without changing your default context:

```bash
CONTEXT=<approved-context-name>
EVENTING_NAMESPACE=<eventing-component-namespace>
: "${CONTEXT:?Set CONTEXT to the approved Kubernetes context}"
: "${EVENTING_NAMESPACE:?Set the Eventing component namespace}"
kubectl --context="$CONTEXT" config view --minify
```

Confirm that the selected context and cluster/server are the intended target.
Stop if either value is unknown, the context cannot be resolved, or the target
is not approved. Keep `--context` on Kubernetes commands and `--kube-context` on
Helm installation; do not rely on whichever default context another terminal
last selected. Also retain the approved `--context "$CONTEXT"` and actual
resource names/namespaces when adapting the linked Operator apply/verify commands;
do not run their example commands against an unrelated default context. The
namespace for the monitoring stack may differ from the Eventing component
namespace.

The shared Prometheus-stack setup below is illustrative and optional if you
already have a suitable monitoring stack. Installing monitors requires the
Prometheus Operator APIs and a stack configured to select those monitors. That
monitoring operator is separate from the Knative Operator managing Eventing.

--8<-- "collecting-metrics.md"

### Enabling Metric Collection

**v1.24 source scope:** [Eventing's observability parser](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/observability/config.go)
delegates metric parsing to the
[`knative.dev/pkg` revision pinned by Eventing v1.24](https://github.com/knative/pkg/blob/cfa0ac991c5a/observability/metrics/config.go).
It recognizes `metrics-protocol`, `metrics-endpoint`, and
`metrics-export-interval`, with protocols `none`, `prometheus`, `http/protobuf`,
and `grpc`. The parser default is `none`; the sample `http/protobuf` value in
[the release ConfigMap's `_example` block](https://github.com/knative/eventing/blob/knative-v1.24.0/config/core/configmaps/observability.yaml)
is not active configuration. This check does not validate monitoring repository
manifests, historic metric names, or successful collection on a cluster.

1. Using the approved context and Eventing namespace established above, inspect
   the current ConfigMap:

    ```bash
    kubectl --context="$CONTEXT" -n "$EVENTING_NAMESPACE" get configmap config-observability -o yaml
    ```

1. Set the intended `metrics-protocol` to `prometheus` through **one** applicable
   authority path:

    - **Knative Operator-managed:** inspect `spec.config` in the live
      `KnativeEventing` resource and its authoritative manifest. Use the
      [mapping reference](../../../install/operator/configuration-reference.md#configmap-mapping)
      to identify the winning entry for `config-observability`; update that
      entry's `metrics-protocol` through the owner's custom-resource workflow.
      Do not add a second naming-form entry to bypass an existing one or assume
      entries merge. This guide intentionally does not supply a competing
      `spec.config` fragment. Apply and verify using the linked Eventing Operator
      procedure, preserving other settings.
    - **YAML-managed:** change only the intended key in the authoritative
      ConfigMap manifest and apply it through that workflow. If direct live
      editing is explicitly the approved authority, use:

        ```bash
        kubectl --context="$CONTEXT" -n "$EVENTING_NAMESPACE" edit configmap config-observability
        ```

      Do not use this direct edit on an Operator-managed ConfigMap.

    The retained example below illustrates the ConfigMap data, **not** a complete
    replacement for your existing configuration or an Operator manifest. It also
    contains tracing examples; enabling metrics does not require changing those
    tracing values. Preserve the workload's existing tracing and other data.

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-observability
      namespace: knative-eventing
    data:
      # metrics-protocol field specifies the protocol used when exporting metrics
      # It supports either 'none' (the default), 'prometheus', 'http/protobuf' (OTLP HTTP), 'grpc' (OTLP gRPC)
      metrics-protocol: prometheus

      tracing-protocol:      http/protobuf
      tracing-endpoint:      http://jaeger-collector.observability.svc:4318/v1/traces
      tracing-sampling-rate: "1"
    ```

### Apply the Eventing Service/Pod Monitors

1. With the monitoring owner's approval, apply the ServiceMonitors/PodMonitors
   for the Knative Eventing control plane. If suitable monitors already exist,
   inspect them rather than installing a competing copy. The example tracks the
   monitoring repository's `main`; check it against your stack and component
   release before application.

    ```bash
    kubectl --context="$CONTEXT" apply -f https://raw.githubusercontent.com/knative-extensions/monitoring/main/config/eventing-monitors.yaml
    ```

### Verify configuration and metric collection

1. After the authoritative change reconciles, inspect the active ConfigMap key:

    ```bash
    kubectl --context="$CONTEXT" -n "$EVENTING_NAMESPACE" get configmap config-observability -o jsonpath='{.data.metrics-protocol}{"\n"}'
    ```

    For this task it should print `prometheus`. A blank result means the key is
    absent, not proof of any effective exporter default. For Operator-managed
    installations, also inspect the actual `KnativeEventing` resource's readiness
    and conditions using the linked Operator procedure. If the value does not
    persist, investigate the configuration authority; do not keep patching a
    generated ConfigMap.
1. In the existing Prometheus console, inspect the discovered targets for the
   intended Eventing components and confirm successful scrapes. If targets are
   absent, ask the monitoring owner to inspect monitor selection, namespaces,
   and access; if scrapes fail, inspect target errors and component logs.
1. Query a metric actually exported by the installed component release and
   inspect recent samples. The [Eventing metrics reference](eventing-metrics.md)
   records a migration/freshness caveat; do not assume every listed historic
   name or label applies to your exporter. Ask the component/monitoring owner
   for its matching-release metric identifiers where needed.

A matching ConfigMap checks propagation; successful scrapes and samples check
collection. Neither proves that an event reached a subscriber. Use the
[existing-workload troubleshooting guide](../../troubleshooting/events-not-delivered.md)
for event receipt. Dashboard import below is optional, not a collection-success
criterion. To recover configuration, restore the recorded value or absence in
its authoritative source and repeat the same checks, rather than editing an
Operator-generated ConfigMap.

### Import Grafana dashboards

1. Grafana dashboards can be imported from the [`monitoring` repository](https://github.com/knative-extensions/monitoring).

1. If you are using the Grafana Helm Chart with the dashboard sidecar enabled (the default), you can load the dashboards by applying the following configmaps.

    ```bash
    kubectl --context="$CONTEXT" apply -f https://raw.githubusercontent.com/knative-extensions/monitoring/main/config/configmap-eventing-dashboard.json
    ```
