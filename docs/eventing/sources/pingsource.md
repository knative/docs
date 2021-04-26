---
title: "PingSource example"
linkTitle: "PingSource"
weight: 10
type: "docs"
aliases:
  - ../cronjob-source
---

This topic explains event-driven architecture in terms of producers and consumers, and shows how to configure PingSource as an event source targeting a Knative service.

## Before you begin

1. Set up [Knative Serving](../../../serving).
1. Set up [Knative Eventing](../../../eventing).

## Overview

In event-driven architecture the most straightforward use case is a producer creating an event and a
consumer acting on that event.

### Producers

Producers create events. Using GitHub as an example, the producer is the GitHub webhook that sends
information when a pull request is created.
Essentially, you ask the producer for events that they are capable of sending and you tell the
producer where to send those events.

Producers send the event data per specifications that make it easy for consumers to handle it.
Knative uses the CloudEvents specifications by default.
For more information, see the [Cloud Events](https://cloudevents.io/) website.

### Consumers

Consumers consume the data that producers create. Consumers are usually functions.

In the GitHub example above, a consumer might update a ticket in the ticketing system with the data
from the pull request.


## Create a consumer (Knative service)

To create a consumer, and verify that `PingSource` is working, create a simple Knative service that
receives CloudEvents and writes them to stdout.

{{< tabs name="create-service" default="YAML" >}}
{{% tab name="YAML" %}}
Create the service from stdin by running:

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

{{% tab name="kn" %}}
Create a service using the `kn` CLI:

```shell
kn service create event-display --image gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
```
{{< /tab >}}
{{< /tabs >}}

## Create a producer (PingSource)

Create a producer (PingSource) that sends events to your consumer every two minutes.
The `sink` element in the metadata describes where to send events.
In this case, events are sent to a service with the name `event-display`.
This is a tight connection between the producer and consumer.

For each set of ping events that you want to request, create an event source in the same namespace
as the destination.

{{< tabs name="create-source" default="YAML" >}}
{{% tab name="YAML" %}}
Create the event source from stdin by running:

```shell
cat <<EOF | kubectl create -f -
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource
metadata:
  name: test-ping-source
spec:
  schedule: "*/2 * * * *"
  contentType: "application/json"
  data: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
EOF
```
{{< /tab >}}

{{% tab name="kn" %}}
Create a PingSource by using the `kn` CLI:

```shell
kn source ping create test-ping-source \
  --schedule "*/2 * * * *" --data \
  '{ "message": "Hello world!" }' \
  --sink ksvc:event-display
```
{{< /tab >}}
{{< /tabs >}}

## (Optional) Create a PingSource with binary data

You can send binary data, that cannot be directly serialized by using YAML, to downstream, by using `dataBase64` as the payload. `dataBase64` carries data that is base64-encoded.

**Note:** `data` and `dataBase64` cannot co-exist.

Create the event source with binary data from stdin by running:

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

## Verify the message was sent

Verify that the message was sent to the Knative Eventing system by looking at message dumper logs.

{{< tabs name="view-event" default="kubectl" >}}
{{% tab name="kubectl" %}}

View the logs of the event-display service by running:

```shell
kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
```

{{< /tab >}}
{{% tab name="kail" %}}

Use `kail` to tail the logs of the subscriber by running:

```shell
kail -l serving.knative.dev/service=event-display -c user-container --since=10m
```

For more information, see the [`kail`](https://github.com/boz/kail) repository in GitHub.

{{< /tab >}}
{{< /tabs >}}


Log entries appear showing the request headers and body from the source:

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

If you created a PingSource with binary data, the output will be similar to the following:

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

## Clean up

Delete the PingSource instance:

{{< tabs name="delete-source" default="kubectl" >}}
{{% tab name="kubectl" %}}

Delete the PingSource instance by running:

```shell
kubectl delete pingsources.sources.knative.dev test-ping-source
kubectl delete pingsources.sources.knative.dev test-ping-source-binary
```

{{< /tab >}}

{{% tab name="kn" %}}

Delete the PingSource instance by running:

```shell
kn source ping delete test-ping-source
kn source ping delete test-ping-source-binary
```

{{< /tab >}}
{{< /tabs >}}


Delete the service instance:

{{< tabs name="delete-service" default="kubectl" >}}
{{% tab name="kubectl" %}}

Delete the Service instance by running:

```shell
kubectl delete service.serving.knative.dev event-display
```

{{< /tab >}}

{{% tab name="kn" %}}

Delete the service instance by running:

```shell
kn service delete event-display
```

{{< /tab >}}
{{< /tabs >}}
