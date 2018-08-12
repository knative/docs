# Accessing logs

If you have not yet installed the logging and monitoring components, go through the 
[installation instructions](./installing-logging-metrics-traces.md) to set up the 
necessary components first.

## Kibana and Elasticsearch

To open the Kibana UI (the visualization tool for [Elasticsearch](https://info.elastic.co),
enter the following command:

```shell
kubectl proxy
```

This command starts a local proxy of Kibana on port 8001. For security reasons, the 
Kibana UI is exposed only within the cluster.

Navigate to the
[Kibana UI](http://localhost:8001/api/v1/namespaces/monitoring/services/kibana-logging/proxy/app/kibana)
 (*It might take a couple of minutes for the proxy to work*).

The Discover tab of the Kibana UI looks like this:

![Kibana UI Discover tab](./images/kibana-discover-tab-annotated.png)

You can change the time frame of logs Kibana displays in the upper right corner
of the screen. The main search bar is across the top of the Discover page.

As more logs are ingested, new fields will be discovered. To have them indexed,
go to Management > Index Patterns > Refresh button (on top right) > Refresh
fields.

<!-- TODO: create a video walkthrough of the Kibana UI -->

### Accessing configuration and revision logs

To access the logs for a configuration, enter the following search query in Kibana:

```text
kubernetes.labels.serving_knative_dev\/configuration: "configuration-example"
```

Replace `configuration-example` with your configuration's name. Enter the following
command to get your configuration's name:

```shell
kubectl get configurations
```

To access logs for a revision, enter the following search query in Kibana:

```text
kubernetes.labels.serving_knative_dev\/revision: "configuration-example-00001"
```

Replace `configuration-example-00001` with your revision's name.

### Accessing build logs

To access the logs for a build, enter the following search query in Kibana:

```text
kubernetes.labels.build\-name: "test-build"
```

Replace `test-build` with your build's name. The build name is specified in the `.yaml` file as follows:

```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: test-build
```

### Accessing request logs

To access the request logs, enter the following search in Kibana:

```text
tag: "requestlog.logentry.istio-system"
```

Request logs contain details about requests served by the revision. Below is a sample request log:

```text
@timestamp                   July 10th 2018, 10:09:28.000
destinationConfiguration     configuration-example
destinationNamespace         default
destinationRevision          configuration-example-00001
destinationService           configuration-example-00001-service.default.svc.cluster.local
latency                      1.232902ms
method                       GET
protocol                     http
referer                      unknown
requestHost                  route-example.default.example.com
requestSize                  0
responseCode                 200
responseSize                 36
severity                     Info
sourceNamespace              istio-system
sourceService                unknown
tag                          requestlog.logentry.istio-system
traceId                      986d6faa02d49533
url                          /
userAgent                    curl/7.60.0
```

### Accessing end to end request traces

See [Accessing Traces](./accessing-traces.md) page for details.

## Stackdriver

Go to the [GCP Console logging page](https://console.cloud.google.com/logs/viewer) for
your GCP project, which stores your logs via Stackdriver.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
