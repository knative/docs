# Installing Logging, Metrics and Traces

If you installed the [full Knative release](../install/README.md#installing-knative),
the monitoring components are already installed and you can skip down to the
[Create Elasticsearch Indices](#create-elasticsearch-indices) section.

## Metrics

Run:

```shell
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.2/monitoring-metrics-prometheus.yaml
```

The installation is complete when logging & monitoring components are all
reported `Running` or `Completed`:

```shell
kubectl get pods --namespace monitoring --watch
```

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

Hit CTRL+C to exit watch and visit [Accessing Metrics](./accessing-metrics.md) to learn more about metrics.

## Logs

Knative offers three different setups for collecting logs:

1. [Elasticsearch and Kibana](#elasticsearch-and-kibana)
1. [Stackdriver](#stackdriver)
1. [Custom logging plugin](setting-up-a-logging-plugin.md)

### Elasticsearch and Kibana

Run:

```shell
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.2/monitoring-logs-elasticsearch.yaml
```

The installation is complete when logging & monitoring components are all
reported `Running` or `Completed`:

```shell
kubectl get pods --namespace monitoring --watch
```

```text
NAME                                  READY     STATUS    RESTARTS   AGE
elasticsearch-logging-0               1/1       Running   0          2d
elasticsearch-logging-1               1/1       Running   0          2d
fluentd-ds-5kc85                      1/1       Running   0          2d
fluentd-ds-vhrcq                      1/1       Running   0          2d
fluentd-ds-xghk9                      1/1       Running   0          2d
kibana-logging-7d474fbb45-6qb8x       1/1       Running   0          2d
```

Hit CTRL+C to exit watch and continue to [Create Elasticsearch Indices](#create-elasticsearch-indices) section.

#### Create Elasticsearch Indices

To visualize logs with Kibana, you need to set which Elasticsearch indices to explore.

- To open the Kibana UI (the visualization tool for [Elasticsearch](https://info.elastic.co)),
  you must start a local proxy by running the following command:

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

![Create logstash-* index](images/kibana-landing-page-configure-index.png)

Visit [Accessing Logs](./accessing-logs.md) to learn more about logs.

### Stackdriver

To configure and setup monitoring:

1. Clone the Knative Serving repository:

    ```shell
    git clone https://github.com/knative/serving knative-serving
    cd knative-serving
    git checkout v0.2.1
    ```

1. Choose a container image that meets the
   [Fluentd image requirements](fluentd/README.md#requirements). For example, you can use a
   public image. Or you can create a custom one and upload the image to a
   container registry which your cluster has read access to.
   You must configure and build your own Fluentd image if either of the following are true:
    - Your Knative Serving component is not hosted on a Google Cloud Platform (GCP) based cluster.
    - You want to send logs to another GCP project.

1. Follow the instructions in
   ["Setting up a logging plugin"](setting-up-a-logging-plugin.md#Configuring)
   to configure the stackdriver components settings.

1. Install Knative Stackdriver components by running the following command from the root directory of
   [knative/serving](https://github.com/knative/serving) repository:

      ```shell
        kubectl apply --recursive --filename config/monitoring/100-namespace.yaml \
            --filename third_party/config/monitoring/logging/stackdriver
      ```

   The installation is complete when logging & monitoring components are all
   reported `Running` or `Completed`:

     ```shell
     kubectl get pods --namespace monitoring --watch
     ```

     ```text
     NAME                                  READY     STATUS    RESTARTS   AGE
     fluentd-ds-5kc85                      1/1       Running   0          2d
     fluentd-ds-vhrcq                      1/1       Running   0          2d
     fluentd-ds-xghk9                      1/1       Running   0          2d
     ```

  Hit CTRL+C to exit watch and visit [Accessing Logs](./accessing-logs.md) to learn more about logs.

## End to end traces

- If Elasticsearch is not installed or if you don't want to persist end to end traces, run:

    ```shell
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.2/monitoring-tracing-zipkin-in-mem.yaml
    ```

- If Elasticsearch is installed and you want to persist end to end traces, first run:

    ```shell
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.2/monitoring-tracing-zipkin.yaml
    ```
  
    Next, create an Elasticsearch index for end to end traces:

  - Open Kibana UI as described in [Create Elasticsearch Indices](#create-elasticsearch-indices) section.
  - Select `Create Index Pattern` button on top left of the page.
    Enter `zipkin*` to `Index pattern` and select `timestamp_millis`
    from `Time Filter field name` and click on `Create` button.

Visit [Accessing Traces](./accessing-traces.md) for more information on end to end traces.

## Learn More

- Learn more about accessing logs, metrics, and traces:
  - [Accessing Logs](./accessing-logs.md)
  - [Accessing Metrics](./accessing-metrics.md)
  - [Accessing Traces](./accessing-traces.md)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
