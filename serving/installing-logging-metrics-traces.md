# Monitoring, Logging and Tracing Installation

Knative Serving offers two different monitoring setups:
[Elasticsearch, Kibana, Prometheus and Grafana](#Elasticsearch,-Kibana,-Prometheus-&-Grafana-Setup) or [Stackdriver, Prometheus and Grafana](#Stackdriver,-Prometheus-&-Grafana-Setup). You can install only one of these two setups and side-by-side installation of these two are not supported.

## Elasticsearch, Kibana, Prometheus & Grafana Setup

If you installed the [latest Knative Serving components](../install/README.md#Installing-Knative),
skip this step and continue to [Create Elasticsearch Indices](#Create-Elasticsearch-Indices)

* Install Knative monitoring components:
```
kubectl apply -R -f config/monitoring/100-common \
    -f config/monitoring/150-elasticsearch-prod \
    -f third_party/config/monitoring/common \
    -f third_party/config/monitoring/elasticsearch \
    -f config/monitoring/200-common \
    -f config/monitoring/200-common/100-istio.yaml
```
* The installation is complete when logging & monitoring components are all reported `Running` or `Completed`:
```
kubectl get pods -n monitoring --watch
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
CTRL+C when it's done.

### Create Elasticsearch Indices

We will create two indexes in ElasticSearch - one for application logs and one for request traces.

* To create the indexes, open [Kibana Index Management UI](http://localhost:8001/api/v1/namespaces/monitoring/services/kibana-logging/proxy/app/kibana#/management/kibana/index). *It might take a couple of minutes for the proxy to work the first time after the installation*.

* Within the "Configure an index pattern" page, enter `logstash-*` to `Index pattern` and select `@timestamp` from `Time Filter field name` and click on `Create` button.

![Create logstash-* index](images/kibana-landing-page-configure-index.png)

* To create the second index, select `Create Index Pattern` button on top left of the page.
Enter `zipkin*` to `Index pattern` and select `timestamp_millis` from `Time Filter field name` and click on `Create` button.

* Learn more about accessing logs, metrics, and traces:
  * [Accessing Logs](./accessing-logs.md)
  * [Accessing Metrics](./accessing-metrics.md)
  * [Accessing Traces](./accessing-traces.md)

## Stackdriver, Prometheus & Grafana Setup

If your Knative Serving is not built on a Google Cloud Platform (GCP) based cluster or you want to send logs to another GCP project, you need to build your own Fluentd image and modify the configuration first. See

1. [Fluentd image on Knative Serving](/image/fluentd/README.md)
2. [Setting up a logging plugin](setting-up-a-logging-plugin.md)
3. Install monitoring components:  
  ```
  kubectl apply -R -f config/monitoring/100-common \
      -f config/monitoring/150-stackdriver-prod \
      -f third_party/config/monitoring/common \
      -f config/monitoring/200-common \
      -f config/monitoring/200-common/100-istio.yaml
  ```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
