---
title: "Accessing logs"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 5
type: "docs"
---

If you have not yet installed the logging and monitoring components, go through
the [installation instructions](./installing-logging-metrics-traces.md) to set
up the necessary components first.

## Kibana and Elasticsearch

- To open the Kibana UI (the visualization tool for
  [Elasticsearch](https://info.elastic.co)), start a local proxy with the
  following command:

  ```shell
  kubectl proxy
  ```

  This command starts a local proxy of Kibana on port 8001. For security
  reasons, the Kibana UI is exposed only within the cluster.

- Navigate to the
  [Kibana UI](http://localhost:8001/api/v1/namespaces/knative-monitoring/services/kibana-logging/proxy/app/kibana).
  _It might take a couple of minutes for the proxy to work_.

  The Discover tab of the Kibana UI looks like this:

  ![Kibana UI Discover tab](./images/kibana-discover-tab-annotated.png)

  You can change the time frame of logs Kibana displays in the upper right
  corner of the screen. The main search bar is across the top of the Discover
  page.

- As more logs are ingested, new fields will be discovered. To have them
  indexed, go to "Management" > "Index Patterns" > Refresh button (on top
  right) > "Refresh fields".

<!-- TODO: create a video walkthrough of the Kibana UI -->

### Accessing stdout/stderr logs

To find the logs sent to `stdout/stderr` from your application in the Kibana UI:

1. Click `Discover` on the left side bar.
1. Choose `logstash-*` index pattern on the left top.
1. Input `tag: kubernetes*` in the top search bar then search.

### Accessing request logs

To access the request logs (if enabled), enter the following search in Kibana:

```text
_exists_:"httpRequest.requestUrl"
```

Request logs contain customized details about requests served by the revision.
Below is a sample request log:

```text
@timestamp                                            July 10th 2018, 10:09:28.000
kubernetes.labels.serving_knative_dev/configuration   helloworld-go
kubernetes.labels.serving_knative_dev/revision	      helloworld-go-6vf4x
kubernetes.labels.serving_knative_dev/service         helloworld-go
httpRequest.protocol                                  HTTP/1.1
httpRequest.referer
httpRequest.remoteIp                                  10.32.0.2:46866
httpRequest.requestMethod                             GET
httpRequest.requestSize                               0
httpRequest.requestUrl                                /
httpRequest.responseSize                              20
httpRequest.serverIp                                  10.32.1.36
httpRequest.status                                    200
httpRequest.userAgent                                 curl/7.60.0
traceId                                               0def9abf835ad90e9d824f7a492e2dcb
```

### Accessing configuration and revision logs

To access the logs for a configuration:

- Find the configuration's name with the following command:

```
kubectl get configurations
```

- Replace `<CONFIGURATION_NAME>` and enter the following search query in Kibana:

```
kubernetes.labels.serving_knative_dev\/configuration: <CONFIGURATION_NAME>
```

To access logs for a revision:

- Find the revision's name with the following command:

```
kubectl get revisions
```

- Replace `<REVISION_NAME>` and enter the following search query in Kibana:

```
kubernetes.labels.serving_knative_dev\/revision: <REVISION_NAME>
```

### Accessing end to end request traces

See [Accessing Traces](./accessing-traces.md) page for details.

## Stackdriver

Go to the
[GCP Console logging page](https://console.cloud.google.com/logs/viewer) for
your GCP project, which stores your logs via Stackdriver.


