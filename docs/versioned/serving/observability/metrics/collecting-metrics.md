---
audience: administrator
components:
  - serving
function: how-to
---

--8<-- "collecting-metrics.md"


### Enabling Metric Collection

1. To enable prometheus metrics collection you will want to update `config-observability` ConfigMap and set the `metrics-protocol` to `prometheus`. For request-metrics we recommend setting up pushing metrics to prometheus. This requires enabling the Prometheus OLTP receiver. This is already configured in our monitoring example.


    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-observability
      namespace: knative-serving
    data:
      # metrics-protocol field specifies the protocol used when exporting metrics
      # It supports either 'none' (the default), 'prometheus', 'http/protobuf' (OTLP HTTP), 'grpc' (OTLP gRPC)
      metrics-protocol: prometheus

      # request-metrics-protocol
      request-metrics-protocol: http/protobuf
      request-metrics-endpoint: http://knative-kube-prometheus-st-prometheus.observability.svc:9090/api/v1/otlp/v1/metrics

      tracing-protocol:      http/protobuf
      tracing-endpoint:      http://jaeger-collector.observability.svc:4318/v1/traces
      tracing-sampling-rate: "1"
    ```

1. Apply the ServiceMonitors/PodMonitors to collect metrics from Knative Serving Control Plane.

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/knative-extensions/monitoring/main/config/serving-monitors.yaml
    ```

### Import Grafana dashboards

1. Grafana dashboards can be imported from the [`monitoring` repository](https://github.com/knative-extensions/monitoring).

1. If you are using the Grafana Helm Chart with the dashboard sidecar enabled (the default), you can load the dashboards by applying the following configmaps.

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/knative-extensions/monitoring/main/config/configmap-serving-dashboard.json
    ```
