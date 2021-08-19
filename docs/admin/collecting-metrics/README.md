# Collecting Metrics in Knative

Knative offers two solutions for collecting metrics:
- [Prometheus](https://prometheus.io/)
- [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)

[Grafana](https://grafana.com/oss/) dashboards are available for metrics collected directly with Prometheus.

You can also set up the OpenTelemetry Collector to receive metrics from Knative components and distribute them to other metrics providers that support OpenTelemetry.

## About Prometheus

[Prometheus](https://prometheus.io/) is an open-source tool for collecting and
aggregating timeseries metrics. It can be used to scrape the OpenTelemetry collector that you created in the previous step.

## Setting up Prometheus

1. Install the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator/helm) by entering the following command:

       ```bash
       helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
       helm repo update
       helm install prometheus prometheus-community/kube-prometheus-stack -n default
       ```
        
    !!! caution
        You will need to ensure that the helm chart has following values configured, otherwise the ServiceMonitors/Podmonitors will not work.
         ```yaml
         kube-state-metrics:
           metricLabelsAllowlist:
             - pods=[*]
             - deployments=[app.kubernetes.io/name,app.kubernetes.io/component,app.kubernetes.io/instance]
           prometheus:
             prometheusSpec:
               serviceMonitorSelectorNilUsesHelmValues: false
               podMonitorSelectorNilUsesHelmValues: false
 
1. Apply the ServiceMonitors/PodMonitors to collect metrics from Knative.

       ```bash
       kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/monitoring/main/servicemonitor.yaml
       ```
1. Grafana dashboards can be imported from https://github.com/knative-sandbox/monitoring/tree/main/grafana.
 

## About OpenTelemetry

OpenTelemetry is a CNCF observability framework for cloud-native software, which provides a collection of tools, APIs, and SDKs.

You can use OpenTelemetry to instrument, generate, collect, and export telemetry data. This data includes metrics, logs, and traces, that you can analyze to understand the performance and behavior of Knative components.

OpenTelemetry allows you to easily export metrics to multiple monitoring services without needing to rebuild or reconfigure the Knative binaries.

## Understanding the collector

The collector provides a location where various Knative components can push metrics to be retained and collected by a monitoring service.

In the following example, you can configure a single collector instance using a ConfigMap and a Deployment.

!!! tip
    For more complex deployments, you can automate some of these steps by using the [OpenTelemetry Operator](https://github.com/open-telemetry/opentelemetry-operator).
    
!!! caution
    The Grafana dashboards at https://github.com/knative-sandbox/monitoring/tree/main/grafana don't work with metrics scraped from OpenTelemetry Collector.

![Diagram of components reporting to collector, which is scraped by Prometheus](system-diagram.svg)

<!-- yuml.me UML rendering of:
[queue-proxy1]->[Collector]
[queue-proxy2]->[Collector]
[autoscaler]->[Collector]
[controller]->[Collector]
[Collector]<-scrape[Prometheus]
-->

## Set up the collector

1. Create a namespace for the collector to run in, by entering the following command:

       ```bash
       kubectl create namespace <namespace>
       ```
    Where

    - `<namespace>` is the name of the namespace that you want to create for the collector.

1. Create a Deployment, Service, and ConfigMap for the collector by entering the following command:

       ```bash
       kubectl apply -f https://raw.githubusercontent.com/knative/docs/master/docs/install/collecting-metrics/collector.yaml
       ```

1. Update the `config-observability` ConfigMaps in the Knative Serving and
   Eventing namespaces, by entering the follow command:

       ```bash
       kubectl patch --namespace knative-serving configmap/config-observability \
         --type merge \
         --patch '{"data":{"metrics.backend-destination":"opencensus","request-metrics-backend-destination":"opencensus","metrics.opencensus-address":"otel-collector.metrics:55678"}}'
       kubectl patch --namespace knative-eventing configmap/config-observability \
         --type merge \
         --patch '{"data":{"metrics.backend-destination":"opencensus","metrics.opencensus-address":"otel-collector.metrics:55678"}}'
       ```

## Verify the collector setup

1. You can check that metrics are being forwarded by loading the Prometheus export port on the collector, by entering the following command:

    ```bash
    kubectl port-forward --namespace metrics deployment/otel-collector 8889
    ```

1. Fetch `http://localhost:8889/metrics` to see the exported metrics.

