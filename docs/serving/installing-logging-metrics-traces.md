---
title: "Installing logging, metrics, and traces"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 40
type: "docs"
---

If you followed one of the
[comprehensive install guides](../install/README.md#install-guides) or you
performed a custom installation and included the `monitoring.yaml` file in your
installation, all of the observability features are already installed and you
can skip down to the
[Create Elasticsearch Indices](#create-elasticsearch-indices) section.

If you have not yet installed any observability plugins, continue to the next
sections to do so now.

## Metrics

1. Run the following command and follow the instructions below to enable request
   metrics if they are wanted:

   ```
   kubectl edit cm -n knative-serving config-observability
   ```

   Add `metrics.request-metrics-backend-destination: prometheus` to `data`
   field. You can find detailed information in `data._example` field in the
   `ConfigMap` you are editing.

1. Run the following command to install Prometheus and Grafana:

   ```shell
   kubectl apply --filename {{< artifact repo="serving" file="monitoring-metrics-prometheus.yaml" >}}
   ```

1. Ensure that the `grafana-*`, `kibana-logging-*`, `kube-state-metrics-*`,
   `node-exporter-*` and `prometheus-system-*` pods all report a `Running`
   status:

   ```shell
   kubectl get pods --namespace knative-monitoring --watch
   ```

   For example:

   ```text
   NAME                                  READY     STATUS    RESTARTS   AGE
   grafana-798cf569ff-v4q74              1/1       Running   0          2d
   kibana-logging-7d474fbb45-6qb8x       1/1       Running   0          2d
   kube-state-metrics-75bd4f5b8b-8t2h2   4/4       Running   0          2d
   node-exporter-cr6bh                   2/2       Running   0          2d
   node-exporter-mf6k7                   2/2       Running   0          2d
   node-exporter-rhzr7                   2/2       Running   0          2d
   prometheus-system-0                   1/1       Running   0          2d
   prometheus-system-1                   1/1       Running   0          2d
   ```

   Tip: Hit CTRL+C to exit watch mode.

[Accessing Metrics](./accessing-metrics.md) for more information about metrics
in Knative.

## Logs

### Enable Request Logs

Run the following command and follow the instructions below to enable request
logs if they are wanted:

```
kubectl edit cm -n knative-serving config-observability
```

Copy `logging.request-log-template` from `data._example` field to`data` field in
the `ConfigMap` you are editing. You can find detailed information in
`data._example` field to customize the request log format.

### Choose One Logging Backend

Knative offers three different setups for collecting logs. Choose one to
install:

1. [Elasticsearch and Kibana](#elasticsearch-and-kibana)
1. [Stackdriver](#stackdriver)
1. [Custom logging plugin](./setting-up-a-logging-plugin.md)

#### Elasticsearch and Kibana

1. Run the following command to install an ELK stack:

   ```shell
   kubectl apply --filename {{< artifact repo="serving" file="monitoring-logs-elasticsearch.yaml" >}}
   ```

1. Ensure that the `elasticsearch-logging-*`, `fluentd-ds-*`, and
   `kibana-logging-*` pods all report a `Running` status:

   ```shell
   kubectl get pods --namespace knative-monitoring --watch
   ```

   For example:

   ```text
   NAME                                  READY     STATUS    RESTARTS   AGE
   elasticsearch-logging-0               1/1       Running   0          2d
   elasticsearch-logging-1               1/1       Running   0          2d
   fluentd-ds-5kc85                      1/1       Running   0          2d
   fluentd-ds-vhrcq                      1/1       Running   0          2d
   fluentd-ds-xghk9                      1/1       Running   0          2d
   kibana-logging-7d474fbb45-6qb8x       1/1       Running   0          2d
   ```

   Tip: Hit CTRL+C to exit watch mode.

1. Verify that each of your nodes have the
   `beta.kubernetes.io/fluentd-ds-ready=true` label:

   ```shell
   kubectl get nodes --selector beta.kubernetes.io/fluentd-ds-ready=true
   ```

1. If you receive the `No Resources Found` response:

   1. Run the following command to ensure that the Fluentd DaemonSet runs on all
      your nodes:

      ```shell
      kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready="true"
      ```

   1. Run the following command to ensure that the `fluentd-ds` daemonset is
      ready on at least one node:

      ```shell
      kubectl get daemonset fluentd-ds --namespace knative-monitoring --watch
      ```

      Tip: Hit CTRL+C to exit watch mode.

1. When the installation is complete and all the resources are running, you can
   continue to the next section and begin creating your Elasticsearch indices.

##### Create Elasticsearch Indices

To visualize logs with Kibana, you need to set which Elasticsearch indices to
explore.

- To open the Kibana UI (the visualization tool for
  [Elasticsearch](https://info.elastic.co)), you must start a local proxy by
  running the following command:

  ```shell
  kubectl proxy
  ```

  This command starts a local proxy of Kibana on port 8001. For security
  reasons, the Kibana UI is exposed only within the cluster.

- Navigate to the
  [Kibana UI](http://localhost:8001/api/v1/namespaces/knative-monitoring/services/kibana-logging/proxy/app/kibana).
  _It might take a couple of minutes for the proxy to work_.

- Within the "Configure an index pattern" page, enter `logstash-*` to
  `Index pattern` and select `@timestamp` from `Time Filter field name` and
  click on `Create` button.

![Create logstash-* index](./images/kibana-landing-page-configure-index.png)

See [Accessing Logs](./accessing-logs.md) for more information about logs in
Knative.

#### Stackdriver

To configure and setup monitoring:

1.  Clone the Knative Serving repository:

    ```shell
    git clone -b {{< version >}} https://github.com/knative/serving knative-serving
    cd knative-serving
    ```

1.  Choose a container image that meets the
    [Fluentd image requirements](./fluentd-requirements.md#requirements). For
    example, you can use a public image. Or you can create a custom one and
    upload the image to a container registry which your cluster has read access
    to.

    You must configure and build your own Fluentd image if either of the
    following are true:

    - Your Knative Serving component is not hosted on a Google Cloud Platform
      (GCP) based cluster.
    - You want to send logs to another GCP project.

1.  Follow the instructions in
    [Setting up a logging plugin](./setting-up-a-logging-plugin.md#Configuring)
    to configure the stackdriver components settings.

1.  Install Knative Stackdriver components by running the following command from
    the root directory of [knative/serving](https://github.com/knative/serving)
    repository:

    ```shell
      kubectl apply --recursive --filename config/monitoring/100-namespace.yaml \
          --filename config/monitoring/logging/stackdriver
    ```

1.  Ensure that the `fluentd-ds-*` pods all report a `Running` status:

    ```shell
    kubectl get pods --namespace knative-monitoring --watch
    ```

    For example:

    ```text
    NAME                                  READY     STATUS    RESTARTS   AGE
    fluentd-ds-5kc85                      1/1       Running   0          2d
    fluentd-ds-vhrcq                      1/1       Running   0          2d
    fluentd-ds-xghk9                      1/1       Running   0          2d
    ```

    Tip: Hit CTRL+C to exit watch mode.

1.  Verify that each of your nodes have the
    `beta.kubernetes.io/fluentd-ds-ready=true` label:

    ```shell
    kubectl get nodes --selector beta.kubernetes.io/fluentd-ds-ready=true
    ```

1.  If you receive the `No Resources Found` response:

    1.  Run the following command to ensure that the Fluentd DaemonSet runs on
        all your nodes:

        ```shell
        kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready="true"
        ```

    1.  Run the following command to ensure that the `fluentd-ds` daemonset is
        ready on at least one node:

        ```shell
        kubectl get daemonset fluentd-ds --namespace knative-monitoring
        ```

See [Accessing Logs](./accessing-logs.md) for more information about logs in
Knative.

## End to end request tracing

You can choose from one of the following options to enable request tracing in
your Knative Serving cluster.

**Important**: Your cluster supports only a single request trace tool. If you
want to replace a currently installed request trace tool, you must first
uninstall that tool before installing the new tool.

### Zipkin

1. Install support for Zipkin:

   - If Elasticsearch is not installed or if you don't want to persist end to
     end traces, run:

     ```shell
     kubectl apply --filename {{< artifact repo="serving" file="monitoring-tracing-zipkin-in-mem.yaml" >}}
     ```

   - If Elasticsearch is installed and you want to persist end to end traces,
     first run:

     ```shell
     kubectl apply --filename {{< artifact repo="serving" file="monitoring-tracing-zipkin.yaml" >}}
     ```

1. Create an Elasticsearch index for end to end traces:

   1. Open Kibana UI as described in
      [Create Elasticsearch Indices](#create-elasticsearch-indices) section.

   1. Select `Create Index Pattern` button on top left of the page. Enter
      `zipkin*` to `Index pattern` and select `timestamp_millis` from
      `Time Filter field name` and click on `Create` button.

Visit [Accessing Traces](./accessing-traces.md) for more information on end to
end traces.

### Jaeger

1. Install the Jaeger operator. Use the instructions in
   jaegertracing/jaeger-operator repository and follow only the steps in the
   [Installing the operator](https://github.com/jaegertracing/jaeger-operator#installing-the-operator)
   section.

1. Install support for Jaeger:

   - If Elasticsearch is not installed or if you don't want to persist end to
     end traces, run:

     ```shell
     kubectl apply --filename {{< artifact repo="serving" file="monitoring-tracing-jaeger-in-mem.yaml" >}}
     ```

   - If Elasticsearch is installed and you want to persist end to end traces,
     first run:

     ```shell
     kubectl apply --filename {{< artifact repo="serving" file="monitoring-tracing-jaeger.yaml" >}}
     ```

1. Create an Elasticsearch index for end to end traces:

   1. Open Kibana UI as described in
      [Create Elasticsearch Indices](#create-elasticsearch-indices) section.

   1. Select `Create Index Pattern` button on top left of the page. Enter
      `jaeger*` to `Index pattern` and select `timestamp_millis` from
      `Time Filter field name` and click on `Create` button.

Visit [Accessing Traces](./accessing-traces.md) for more information on end to
end traces.

## Learn More

- Learn more about accessing logs, metrics, and traces:
  - [Accessing Logs](./accessing-logs.md)
  - [Accessing Metrics](./accessing-metrics.md)
  - [Accessing Traces](./accessing-traces.md)


