# Monitoring, Logging and Tracing Installation

Knative Serving offers two different monitoring setups:
One that uses Elasticsearch, Kibana, Prometheus and Grafana and
another that uses Stackdriver, Prometheus and Grafana. See below
for installation instructions for these two setups. You can install
only one of these two setups and side-by-side installation of these two are not supported.

## Elasticsearch, Kibana, Prometheus & Grafana Setup

*If you installed Knative Serving using [Easy Install](../install/README.md#Installing-Knative) guide,
skip this step and continue to [Create Elasticsearch Indices](#create-elasticsearch-indices)*

1. Choose a container image that meets the basic
   [requirements](fluentd/README.md#requirements). For example, you can use the
   public image [k8s.gcr.io/fluentd-elasticsearch:v2.0.4](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch/fluentd-es-image).
   Or you can create a custom one and upload the image to a container registry
   which your cluster has read access to.
1. Follow the instructions in
   ["Setting up a logging plugin"](setting-up-a-logging-plugin.md#Configuring)
   to configure the Elasticsearch components settings.
1. From the root directory of [knative/serving](https://github.com/knative/serving)
   repository, run:

   ```shell
   kubectl apply -R -f config/monitoring/100-common \
       -f config/monitoring/150-elasticsearch-prod \
       -f third_party/config/monitoring/common \
       -f third_party/config/monitoring/elasticsearch \
       -f config/monitoring/200-common \
       -f config/monitoring/200-common/100-istio.yaml
   ```

Monitor logging & monitoring components, until all of the components report Running or Completed:

```shell
kubectl get pods -n monitoring --watch
```

CTRL+C when it's done.

### Create Elasticsearch Indices

We will create two indexes in ElasticSearch - one for application logs and one for request traces.
To create the indexes, open Kibana Index Management UI at this [link](http://localhost:8001/api/v1/namespaces/monitoring/services/kibana-logging/proxy/app/kibana#/management/kibana/index)
(*it might take a couple of minutes for the proxy to work the first time after the installation*).

Within the "Configure an index pattern" page, enter `logstash-*` to `Index pattern` and select `@timestamp`
from `Time Filter field name` and click on `Create` button. See below for a screenshot:

![Create logstash-* index](images/kibana-landing-page-configure-index.png)

To create the second index, select `Create Index Pattern` button on top left of the page.
Enter `zipkin*` to `Index pattern` and select `timestamp_millis` from `Time Filter field name`
and click on `Create` button.

Next, visit instructions below to access to logs, metrics and traces:

* [Accessing Logs](./accessing-logs.md)
* [Accessing Metrics](./accessing-metrics.md)
* [Accessing Traces](./accessing-traces.md)

## Stackdriver(logs), Prometheus & Grafana Setup

1. Choose a container image that meets the basic
   [requirements](fluentd/README.md#requirements). For example, you can use a
   public image. Or you can create a custom one and upload the image to a
   container registry which your cluster has read access to.
2. Follow the instructions in
   ["Setting up a logging plugin"](setting-up-a-logging-plugin.md#Configuring)
   to configure the stackdriver components settings.
3. From the root directory of [knative/serving](https://github.com/knative/serving)
   repository, run:

   ```shell
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
