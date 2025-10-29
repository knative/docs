<!-- Referenced by:
- eventing/observability/metrics/collecting-metrics.md
- serving/observability/metrics/collecting-metrics.md
-->

# Collecting Metrics in Knative

Knative leverages [OpenTelemetry](https://opentelemetry.io/docs/what-is-opentelemetry/) for exporting metrics.
We currently support the following export protocols:

- [OTel (OTLP) over HTTP or gRPC](https://opentelemetry.io/docs/languages/go/exporters/#otlp)
- [Prometheus](https://opentelemetry.io/docs/languages/go/exporters/#prometheus-experimental)

You can also set up the OpenTelemetry Collector to receive metrics from Knative components and distribute them to other metrics providers that support OpenTelemetry.

!!! note
    The following monitoring setup is for illustrative purposes. Support is best-effort and changes
    are welcome in the [Knative Monitoring repository](https://github.com/knative-extensions/monitoring)
    By default metrics are exporting is off.

## About the Prometheus Stack

[Prometheus](https://prometheus.io/) is an open-source tool for collecting, aggregating timeseries metrics and alerting. It can also be used to scrape the OpenTelemetry Collector that is demonstrated below when Prometheus is used.

[Grafana](https://grafana.com/oss/) is an open-source platform for data analytics and visualization, enabling users to create customizable dashboards for monitoring and analyzing metrics from various data sources.

[Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) is a preconfigured collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules, combined to provide end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator. The stack includes by default some Prometheus packages and Grafana.

## Setting up the Prometheus Stack

1. Install the [Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) by using [Helm](https://helm.sh/docs/intro/using_helm/):

    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install knative prometheus-community/kube-prometheus-stack \
      --create-namespace \
      --namespace observability \
      -f https://raw.githubusercontent.com/knative-extensions/monitoring/main/promstack-values.yaml
    ```

### Access the Prometheus instance locally

By default, the Prometheus instance is only exposed on a private service named `prometheus-operated`.

To access the console in your web browser:

1. Enter the command:

    ```bash
    kubectl port-forward -n observability svc/prometheus-operated 9090:9090
    ```

1. Access the console in your browser via `http://localhost:9090`.

### Access the Grafana instance locally

By default, the Grafana instance is only exposed on a private service named `prometheus-grafana`.

To access the dashboards in your web browser:

1. Enter the command:

    ```bash
    kubectl port-forward -n observability svc/knative-grafana 3000:80
    ```

1. Access the dashboards in your browser via `http://localhost:3000`.

1. Use the default credentials to login:

    ```text
    username: admin
    password: prom-operator
    ```

