---
title: "PingSource"
linkTitle: "PingSource"
weight: 31
type: "docs"
---

![version](https://img.shields.io/badge/API_Version-v1beta2-red?style=flat-square)

A PingSource produces events with a fixed payload on a specified cron schedule.

## Installation

The PingSource source type is enabled by default when you install Knative Eventing.

## Example

This example shows how to send an event every second to a Event Display Service.

### Creating a namespace

Create a new namespace called `pingsource-example` by entering the following
command:

```shell
kubectl create namespace pingsource-example
```

### Creating the Event Display Service

In this step, you create one event consumer, `event-display` to verify that
`PingSource` is properly working.

To deploy the `event-display` consumer to your cluster, run the following
command:

```shell
kubectl -n pingsource-example apply -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: event-display
spec:
  replicas: 1
  selector:
    matchLabels: &labels
      app: event-display
  template:
    metadata:
      labels: *labels
    spec:
      containers:
        - name: event-display
          image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display

---

kind: Service
apiVersion: v1
metadata:
  name: event-display
spec:
  selector:
    app: event-display
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOF
```

### Creating the PingSource

You can now create the `PingSource` sending an event containing
`{"message": "Hello world!"}` every second.

{{< tabs name="create-source" default="YAML" >}}
{{% tab name="YAML" %}}

```shell
kubectl create -n pingsource-example -f - <<EOF
apiVersion: sources.knative.dev/v1beta2
kind: PingSource
metadata:
  name: test-ping-source
spec:
  schedule: "*/1 * * * *"
  contentType: "application/json"
  data: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: v1
      kind: Service
      name: event-display
EOF
```

{{< /tab >}}

{{% tab name="kn" %}}
Notice that the namespace is specified in two places in the command in `--namespace` and the `--sink` hostname
```shell
kn source ping create test-ping-source \
  --namespace pingsource-example \
  --schedule "*/1 * * * *" \
  --data '{"message": "Hello world!"}' \
  --sink http://event-display.pingsource-example.svc.cluster.local
```

{{< /tab >}}
{{< /tabs >}}

## (Optional) Create a PingSource with binary data

Sometimes you may want to send binary data, which cannot be directly serialized in yaml, to downstream. This can be achieved by using `dataBase64` as the payload. As the name suggests, `dataBase64` should carry data that is base64 encoded.

Please note that `data` and `dataBase64` cannot co-exist.

```shell
cat <<EOF | kubectl create -f -
apiVersion: sources.knative.dev/v1beta2
kind: PingSource
metadata:
  name: test-ping-source-binary
spec:
  schedule: "*/2 * * * *"
  contentType: "text/plain"
  dataBase64: "ZGF0YQ=="
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
EOF
```

### Verify

View the logs for the `event-display` event consumer by
entering the following command:

```shell
kubectl -n pingsource-example logs -l app=event-display --tail=100
```

This returns the `Attributes` and `Data` of the events that the PingSource sent to the `event-display` Service:

```shell
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/default/pingsources/test-ping-source
  id: d8e761eb-30c7-49a3-a421-cd5895239f2d
  time: 2019-12-04T14:24:00.000702251Z
  datacontenttype: application/json
Data,
  {
    "message": "Hello world!"
  }
```

If you created a PingSource with binary data, you should also see the following:

```shell
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/default/pingsources/test-ping-source-binary
  id: a195be33-ff65-49af-9045-0e0711d05e94
  time: 2020-11-17T19:48:00.48334181Z
  datacontenttype: text/plain
Data,
  ZGF0YQ==
```

### Cleanup

Delete the `pingsource-example` namespace and all of its resources from your
cluster by entering the following command:

```shell
kubectl delete namespace pingsource-example
```

## Reference Documentation

See the [PingSource specification](../../reference/api/eventing/#sources.knative.dev/v1beta2.PingSource).

## Contact

For any inquiries about this source, please reach out on to the
[Knative users group](https://groups.google.com/forum/#!forum/knative-users).
