---
title: "PingSource"
weight: 20
type: "docs"
---

![version](https://img.shields.io/badge/API_Version-v1alpha2-green?style=for-the-badge)

`PingSource` produces events with a fixed payload on a specified cron schedule.

## Installation

`PingSource` is pre-installed with Knative Eventing.

## Example

This example shows how to send an event every second to the event display
service.

### Creating a namespace

Create a new namespace called `pingsource-example` by entering the following
command:

```shell
kubectl create namespace pingsource-example
```

This will help us with cleaning up all the resources you are about to create.

### Creating the event display service

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

{{< tabs name="create-source" default="By YAML" >}} {{% tab name="YAML" %}} Add
a PingSource by using the following command:

```shell
kubectl create -n pingsource-example -f - <<EOF
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource
metadata:
  name: test-ping-source
spec:
  schedule: "*/1 * * * *"
  jsonData: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
EOF
```

{{< /tab >}}

{{% tab name="CLI" %}}

```shell
kn source ping create test-ping-source \
  --namespace pingsource-example
  --schedule "*/1 * * * *" \
  --data '{"message": "Hello world!"}' \
  --sink http://event-display.svc.cluster.local
```

{{< /tab >}} {{< /tabs >}}

### Verify

Wait a bit and look at the logs for the `event-display` event consumer by
entering the following command:

```shell
kubectl -n pingsource-example logs -l app=event-display --tail=100
```

This returns the `Attributes` and `Data` of the events the `PingSource` sent to
`event-display`:

```
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

### Cleanup

Delete the `pingsource-example` namespace and all of its resources from your
cluster by entering the following command:

```shell
kubectl delete namespace pingsource-example
```

## Reference Documentation

See
[the specification](../../../reference/eventing/eventing.md#sources.knative.dev/v1alpha2.PingSource).

## Contact

For any inquiries about this source, please reach out on to the
[Knative users group](https://groups.google.com/forum/#!forum/knative-users).
