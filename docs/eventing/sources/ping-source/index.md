---
title: "PingSource"
weight: 31
type: "docs"
aliases:
  - /docs/eventing/sources/pingsource
  - ../cronjob-source
  - /docs/eventing/samples/ping-source
---

![version](https://img.shields.io/badge/API_Version-v1beta2-red?style=flat-square)

A PingSource is an event source that produces events with a fixed payload on a specified [cron](https://en.wikipedia.org/wiki/Cron) schedule.

The following example shows how you can configure a PingSource as an event source that sends events every minute to a Knative service named `event-display` that is used as a sink.

## Before you begin

1. To create a Knative service to use as a sink, you must install [Knative Serving](../../../install).
1. To create a PingSource, you must install [Knative Eventing](../../../eventing). The PingSource event source type is enabled by default when you install Knative Eventing.
1. Optional: You can use either `kubectl` or [`kn`](../../../client/install-kn) commands to create components such as a Knative service and PingSource.
1. Optional: You can use either `kubectl` or [`kail`](https://github.com/boz/kail) for logging during the verification step in this procedure.

## Procedure

1. Optional: Create a new namespace called `pingsource-example` by entering the following command:

    ```shell
    kubectl create namespace pingsource-example
    ```

    Creating a namespace for the PingSource example allows you to isolate the components created by this demo, so that it is easier for you to view changes and remove components when you are finished.

1. To verify that the PingSource is working correctly, create a simple Knative service that dumps incoming messages to its log, by entering the command:

    {{< tabs name="create-service" default="kn" >}}
    {{% tab name="YAML" %}}

```shell
kubectl -n pingsource-example apply -f - << EOF
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - name: event-display
          image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
EOF
```

    {{< /tab >}}
    {{% tab name="kn" %}}

```shell
kn service create event-display --image gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
```
    {{< /tab >}}
    {{< /tabs >}}
    <br>

1. Create a PingSource that sends an event containing `{"message": "Hello world!"}` every minute, by entering the command:

    {{< tabs name="create-source" default="kn" >}}
    {{% tab name="YAML" %}}

```shell
kubectl -n pingsource-example apply -f - <<EOF
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

```shell
kn source ping create test-ping-source \
  --namespace pingsource-example \
  --schedule "*/1 * * * *" \
  --data '{"message": "Hello world!"}' \
  --sink http://event-display.pingsource-example.svc.cluster.local
```

    {{< /tab >}}
    {{< /tabs >}}
    <br>

1. Optional: Create a PingSource that sends binary data.

    If you want to send binary data in an event, this cannot be directly serialized in YAML. However, you can use `dataBase64` in place of `data` in the PingSource spec to carry a data payload that is base64 encoded.

    To create a PingSource that uses base64 encoded data, enter the command:

    ```shell
    kubectl -n pingsource-example apply -f - <<EOF
    apiVersion: sources.knative.dev/v1beta2
    kind: PingSource
    metadata:
      name: test-ping-source-binary
    spec:
      schedule: "*/1 * * * *"
      contentType: "text/plain"
      dataBase64: "ZGF0YQ=="
      sink:
        ref:
          apiVersion: v1
          kind: Service
          name: event-display
    EOF
    ```

1. View the logs for the `event-display` event consumer by
entering the following command:

    {{< tabs name="View logs" default="kubectl" >}}
    {{% tab name="kubectl" %}}

```shell
kubectl -n pingsource-example logs -l app=event-display --tail=100
```

    {{< /tab >}}
    {{% tab name="kail" %}}

```shell
kail -l serving.knative.dev/service=event-display -c user-container --since=10m
```

    {{< /tab >}}
    {{< /tabs >}}
    <br>

    This returns the `Attributes` and `Data` of the events that the PingSource sent to the `event-display` service:

    ```shell
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: dev.knative.sources.ping
      source: /apis/v1/namespaces/pingsource-example/pingsources/test-ping-source
      id: 49f04fe2-7708-453d-ae0a-5fbaca9586a8
      time: 2021-03-25T19:41:00.444508332Z
      datacontenttype: application/json
    Data,
      {
        "message": "Hello world!"
      }
    ```

    If you created a PingSource that sends binary data, you will also see output similar to the following:

    ```shell
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: dev.knative.sources.ping
      source: /apis/v1/namespaces/pingsource-example/pingsources/test-ping-source-binary
      id: ddd7bad2-9b6a-42a7-8f9b-b64494a6ce43
      time: 2021-03-25T19:38:00.455013472Z
      datacontenttype: text/plain
    Data,
      data
    ```

1. Optional: You can delete the `pingsource-example` namespace and all related resources from your cluster by entering the following command:


    ```shell
    kubectl delete namespace pingsource-example
    ```

1. Optional: You can also delete the PingSource instance only by entering the following command:

    {{< tabs name="delete-source" default="kubectl" >}}
    {{% tab name="kubectl" %}}

```shell
kubectl delete pingsources.sources.knative.dev test-ping-source
```

    {{< /tab >}}
    {{% tab name="kn" %}}

```shell
kn source ping delete test-ping-source
```

    {{< /tab >}}
    {{% tab name="kubectl: binary data PingSource" %}}

```shell
kubectl delete pingsources.sources.knative.dev test-ping-source-binary
```

    {{< /tab >}}
    {{% tab name="kn: binary data PingSource" %}}

```shell
kn source ping delete test-ping-source-binary
```

    {{< /tab >}}
    {{< /tabs >}}
    <br>


1. Optional: Delete the `event-delivery` service:

    {{< tabs name="delete-service" default="kubectl" >}}
    {{% tab name="kubectl" %}}

```shell
kubectl delete service.serving.knative.dev event-display
```

    {{< /tab >}}
    {{% tab name="kn" %}}

```shell
kn service delete event-display
```

    {{< /tab >}}
    {{< /tabs >}}
