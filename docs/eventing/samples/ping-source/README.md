This example shows how to configure PingSource as an event source for
functions.

## Before you begin

1. Set up [Knative Serving](../../../serving).
1. Set up [Knative Eventing](../../../eventing).

## Create a Knative Service

To verify that `PingSource` is working, create a simple Knative
Service that dumps incoming messages to its log.

{{< tabs name="create-service" default="By YAML" >}}
{{% tab name="By YAML" %}}
Use following command to create the service from STDIN:

```shell
cat <<EOF | kubectl create -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
EOF
```
{{< /tab >}}

{{% tab name="By filename" %}}
Use following command to create the service from the `service.yaml` file:

```shell
kubectl apply --filename service.yaml
```
{{< /tab >}}
{{< /tabs >}}

## Create a PingSource

For each set of ping events that you want to request, create an Event
Source in the same namespace as the destination.

{{< tabs name="create-source" default="By YAML" >}}
{{% tab name="By YAML" %}}
Use following command to create the event source from STDIN:

```shell
cat <<EOF | kubectl create -f -
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource
metadata:
  name: test-ping-source
spec:
  schedule: "*/2 * * * *"
  jsonData: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
EOF
```
{{< /tab >}}

{{% tab name="By filename" %}}
Use following command to create the event source from the `ping-source.yaml` file:

```shell
kubectl apply --filename ping-source.yaml
```
{{< /tab >}}
{{< /tabs >}}


## Verify

Verify that the message was sent to the Knative eventing system by
looking at message dumper logs.

{{< tabs name="view-event" default="kubectl" >}}
{{% tab name="kubectl" %}}

Use following command to view the logs of the event-display service:

```shell
kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
```

{{< /tab >}}
{{% tab name="kail" %}}

You can also use [`kail`](https://github.com/boz/kail) instead of `kubectl logs`
to tail the logs of the subscriber.

```shell
kail -l serving.knative.dev/service=event-display -c user-container --since=10m
```

{{< /tab >}}
{{< /tabs >}}

You should see log lines showing the request headers and body from the source:

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

## Cleanup

You can delete the PingSource instance by entering the following command:

{{< tabs name="delete-source" default="By name" >}}
{{% tab name="By name" %}}
```shell
kubectl delete pingsources.sources.knative.dev test-ping-source
```
{{< /tab >}}

{{% tab name="By filename" %}}
```shell
kubectl delete --filename ping-source.yaml
```
{{< /tab >}}
{{< /tabs >}}


Similarly, you can delete the Service instance via:

{{< tabs name="delete-service" default="By name" >}}
{{% tab name="By name" %}}
```shell
kubectl delete service.serving.knative.dev event-display
```
{{< /tab >}}
{{% tab name="By filename" %}}
```shell
kubectl delete --filename service.yaml
```
{{< /tab >}}

{{< /tabs >}}
