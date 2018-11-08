# Monitoring, Logging and Tracing Installation

Knative Serving offers three different monitoring setups:
[Elasticsearch and Kibana for logging, Prometheus and Grafana for metrics Setup](#elasticsearch-and-kibana-for-logging--prometheus-and-grafana-for-metrics-setup), [Stackdriver for logging, Prometheus & Grafana for metrics Setup](#stackdriver-for-logging--prometheus--grafana-for-metrics-setup), or [Stackdriver for both logging and metrics](#stackdriver-for-both-logging-and-metrics).

You can install only one of these three setups and side-by-side installation of these three are not supported.

## Before you begin

The following instructions assume that you [installed Knative Serving](../install/README.md).

## Elasticsearch and Kibana for logging, Prometheus and Grafana for metrics Setup

If you installed the [full Knative release](../install/README.md#installing-knative), the monitoring component is already installed and you can skip down to the [Create Elasticsearch Indices](#create-elasticsearch-indices) section.

To configure and setup monitoring:

1. Choose a container image that meets the
   [Fluentd image requirements](fluentd/README.md#requirements). For example, you can use the
   public image [k8s.gcr.io/fluentd-elasticsearch:v2.0.4](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch/fluentd-es-image).
   Or you can create a custom one and upload the image to a container registry
   which your cluster has read access to.
2. Follow the instructions in
   ["Setting up a logging plugin"](setting-up-a-logging-plugin.md#Configuring)
   to configure the Elasticsearch components settings.
3. Install Knative monitoring components by running the following command from the root directory of
   [knative/serving](https://github.com/knative/serving) repository:

   ```shell
    kubectl apply -R -f config/monitoring/100-namespace.yaml \
      -f third_party/config/monitoring/logging/elasticsearch \
      -f config/monitoring/logging/elasticsearch \
      -f third_party/config/monitoring/metrics/prometheus \
      -f config/monitoring/metrics/prometheus \
      -f config/monitoring/tracing/zipkin
   ```

   The installation is complete when logging & monitoring components are all
   reported `Running` or `Completed`:

     ```shell
     kubectl get pods --namespace monitoring --watch
     ```

     ```
     NAME                                  READY     STATUS    RESTARTS   AGE
     elasticsearch-logging-0               1/1       Running   0          2d
     elasticsearch-logging-1               1/1       Running   0          2d
     fluentd-ds-5kc85                      1/1       Running   0          2d
     fluentd-ds-vhrcq                      1/1       Running   0          2d
     fluentd-ds-xghk9                      1/1       Running   0          2d
     grafana-798cf569ff-v4q74              1/1       Running   0          2d
     kibana-logging-7d474fbb45-6qb8x       1/1       Running   0          2d
     kube-state-metrics-75bd4f5b8b-8t2h2   4/4       Running   0          2d
     node-exporter-cr6bh                   2/2       Running   0          2d
     node-exporter-mf6k7                   2/2       Running   0          2d
     node-exporter-rhzr7                   2/2       Running   0          2d
     prometheus-system-0                   1/1       Running   0          2d
     prometheus-system-1                   1/1       Running   0          2d
     ```

  CTRL+C to exit watch.

### Create Elasticsearch Indices

To visualize logs with Kibana, you need to set which Elasticsearch indices to explore. We will
create two indices in Elasticsearch using `Logstash` for application logs and `Zipkin`
for request traces.

- To open the Kibana UI (the visualization tool for [Elasticsearch](https://info.elastic.co)),
  you must start a local proxy by running the following command:

  ```shell
  kubectl proxy
  ```

  This command starts a local proxy of Kibana on port 8001. For security
  reasons, the Kibana UI is exposed only within the cluster.

- Navigate to the
  [Kibana UI](http://localhost:8001/api/v1/namespaces/monitoring/services/kibana-logging/proxy/app/kibana).
  _It might take a couple of minutes for the proxy to work_.

- Within the "Configure an index pattern" page, enter `logstash-*` to
  `Index pattern` and select `@timestamp` from `Time Filter field name` and
  click on `Create` button.

![Create logstash-* index](images/kibana-landing-page-configure-index.png)

- To create the second index, select `Create Index Pattern` button on top left
  of the page. Enter `zipkin*` to `Index pattern` and select `timestamp_millis`
  from `Time Filter field name` and click on `Create` button.


## Stackdriver for logging, Prometheus & Grafana for metrics Setup

You must configure and build your own Fluentd image if either of the following are true:

 * Your Knative Serving component is not hosted on a Google Cloud Platform (GCP) based cluster.
 * You want to send logs to another GCP project.

To configure and setup monitoring:

1. Choose a container image that meets the
   [Fluentd image requirements](fluentd/README.md#requirements). For example, you can use a
   public image. Or you can create a custom one and upload the image to a
   container registry which your cluster has read access to.
2. Follow the instructions in
   ["Setting up a logging plugin"](setting-up-a-logging-plugin.md#Configuring)
   to configure the stackdriver components settings.
3. Install Knative monitoring components by running the following command from the root directory of
   [knative/serving](https://github.com/knative/serving) repository:

   ```shell
    kubectl apply -R -f config/monitoring/100-namespace.yaml \
      -f config/monitoring/logging/stackdriver \
      -f third_party/config/monitoring/metrics/prometheus \
      -f config/monitoring/metrics/prometheus \
      -f config/monitoring/tracing/zipkin
   ```   

   The installation is complete when logging & monitoring components are all
   reported `Running` or `Completed`:

     ```shell
     kubectl get pods -n knative-monitoring --watch
     ```

     ```
     NAME                                  READY     STATUS    RESTARTS   AGE
     fluentd-ds-5kc85                      1/1       Running   0          2d
     fluentd-ds-vhrcq                      1/1       Running   0          2d
     fluentd-ds-xghk9                      1/1       Running   0          2d
     grafana-798cf569ff-v4q74              1/1       Running   0          2d
     kube-state-metrics-75bd4f5b8b-8t2h2   4/4       Running   0          2d
     node-exporter-cr6bh                   2/2       Running   0          2d
     node-exporter-mf6k7                   2/2       Running   0          2d
     node-exporter-rhzr7                   2/2       Running   0          2d
     prometheus-system-0                   1/1       Running   0          2d
     prometheus-system-1                   1/1       Running   0          2d
     ```

  CTRL+C to exit watch.

## Stackdriver for both logging and metrics

You need to apply the same first two steps to deploy Fluentd image as in [Stackdriver for logging, Prometheus & Grafana for metrics Setup](#stackdriver-for-logging--prometheus--grafana-for-metrics-setup). In the third step, do the following to send the **Knative system metrics** to stackdriver:
3. Install Knative monitoring components by running the following command from the root directory of
   [knative/serving](https://github.com/knative/serving) repository:
   1. Update *metrics.backend-destination* to be stackdriver in [config-observability.yaml](https://github.com/knative/serving/blob/388f98a0a4bb6799ecf174aafc768098890e6cba/config/config-observability.yaml#L92).
   2. Run:
    ```shell
    kubectl apply -R -f config/monitoring/100-namespace.yaml \
    -f config/config-observability.yaml \
    -f config/monitoring/logging/stackdriver \
    -f config/monitoring/metrics/stackdriver \
    -f config/monitoring/tracing/zipkin
    ```

To include **Istio metrics**, such as request count and request latency, you'll need to install Istio 1.0.4 or later.
To include **[Kubernetes metrics](https://cloud.google.com/monitoring/api/metrics_other#other-kubernetes.io)** if Knative is deployed to GKE, create a Kubernetes cluster on GKE with [Stackdriver Kubernetes Monitoring](https://cloud.google.com/kubernetes-monitoring/) feature:
    <pre>
    gcloud <b>beta</b> container clusters create $CLUSTER_NAME \
      --zone=$CLUSTER_ZONE \
      --cluster-version=latest \
      --machine-type=n1-standard-4 \
      --enable-autoscaling --min-nodes=1 --max-nodes=10 \
      --enable-autorepair \
      <b>--enable-stackdriver-kubernetes \</b>
      --scopes=service-control,service-management,compute-rw,storage-ro,cloud-platform,logging-write,monitoring-write,pubsub,datastore \
      --num-nodes=3
    </pre>

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
