---
title: "Installing logging, metrics, and traces"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 40
---

If you followed one of the
[comprehensive install guides](../../install/#install-guides) or you
performed a custom installation and included the `monitoring.yaml` file in your
installation, all of the observability features are already installed and you
can skip down to the
[Create Elasticsearch Indices](#create-elasticsearch-indices) section.

If you have not yet installed any observability plugins, continue to the next
sections to do so now.

## Metrics

1. Run the following command to install Prometheus and Grafana:

   ```shell
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.3.0/monitoring-metrics-prometheus.yaml
   ```

1. Ensure that the `grafana-*`, `kibana-logging-*`, `kube-state-metrics-*`, `node-exporter-*` and `prometheus-system-*` 
   pods all report a `Running` status:

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

[Accessing Metrics](../accessing-metrics/) for more information about metrics in Knative.

## Logs

Knative offers three different setups for collecting logs. Choose one to install:

1. [Elasticsearch and Kibana](#elasticsearch-and-kibana)
1. [Stackdriver](#stackdriver)
1. [Custom logging plugin](setting-up-a-logging-plugin/)

### Elasticsearch and Kibana

1. Run the following command to install an ELK stack:

   ```shell
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.3.0/monitoring-logs-elasticsearch.yaml
   ```

1. Ensure that the `elasticsearch-logging-*`, `fluentd-ds-*`, and `kibana-logging-*` pods all report a `Running` status:

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

1. Verify that each of your nodes have the `beta.kubernetes.io/fluentd-ds-ready=true` label:

   ```shell
   kubectl get nodes --selector beta.kubernetes.io/fluentd-ds-ready=true
   ```

1. If you receive the `No Resources Found` response:

   1. Run the following command to ensure that the Fluentd DaemonSet runs on all your nodes:

      ```shell
      kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready="true"
      ```

   1. Run the following command to ensure that the `fluentd-ds` daemonset is ready on at least one node:

      ```shell
      kubectl get daemonset fluentd-ds --namespace knative-monitoring --watch
      ```
   
      Tip: Hit CTRL+C to exit watch mode.

1. When the installation is complete and all the resources are running, you can continue to the next section 
   and begin creating your Elasticsearch indices.

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

See [Accessing Logs](../accessing-logs/) for more information about logs in Knative.

### Stackdriver

To configure and setup monitoring:

1. Clone the Knative Serving repository:

    ```shell
    git clone https://github.com/knative/serving knative-serving
    cd knative-serving
    git checkout v0.3.0
    ```

1. Choose a container image that meets the
   [Fluentd image requirements](fluentd/#requirements). For example, you can use a
   public image. Or you can create a custom one and upload the image to a
   container registry which your cluster has read access to.

   You must configure and build your own Fluentd image if either of the following are true:
    - Your Knative Serving component is not hosted on a Google Cloud Platform (GCP) based cluster.
    - You want to send logs to another GCP project.

1. Follow the instructions in
   ["Setting up a logging plugin"](setting-up-a-logging-plugin/#Configuring)
   to configure the stackdriver components settings.

1. Install Knative Stackdriver components by running the following command from the root directory of
   [knative/serving](https://github.com/knative/serving) repository:

      ```shell
        kubectl apply --recursive --filename config/monitoring/100-namespace.yaml \
            --filename third_party/config/monitoring/logging/stackdriver
      ```

 1. Ensure that the `fluentd-ds-*` pods all report a `Running` status:

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
  
1. Verify that each of your nodes have the `beta.kubernetes.io/fluentd-ds-ready=true` label:

   ```shell
   kubectl get nodes --selector beta.kubernetes.io/fluentd-ds-ready=true
   ```

1. If you receive the `No Resources Found` response:

   1. Run the following command to ensure that the Fluentd DaemonSet runs on all your nodes:

      ```shell
      kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready="true"
      ```

   1. Run the following command to ensure that the `fluentd-ds` daemonset is ready on at least one node:

      ```shell
      kubectl get daemonset fluentd-ds --namespace knative-monitoring
      ```
See [Accessing Logs](../accessing-logs/) for more information about logs in Knative.

## End to end traces

- If Elasticsearch is not installed or if you don't want to persist end to end traces, run:

    ```shell
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.3.0/monitoring-tracing-zipkin-in-mem.yaml
    ```

- If Elasticsearch is installed and you want to persist end to end traces, first run:

    ```shell
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.3.0/monitoring-tracing-zipkin.yaml
    ```
  
    Next, create an Elasticsearch index for end to end traces:

  - Open Kibana UI as described in [Create Elasticsearch Indices](#create-elasticsearch-indices) section.
  - Select `Create Index Pattern` button on top left of the page.
    Enter `zipkin*` to `Index pattern` and select `timestamp_millis`
    from `Time Filter field name` and click on `Create` button.

Visit [Accessing Traces](../accessing-traces/) for more information on end to end traces.

## Learn More

- Learn more about accessing logs, metrics, and traces:
  - [Accessing Logs](../accessing-logs/)
  - [Accessing Metrics](../accessing-metrics/)
  - [Accessing Traces](../accessing-traces/)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
