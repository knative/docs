---
title: "PingSource example"
linkTitle: "PingSource"
weight: 10
type: "docs"
aliases:
  - ../cronjob-source
---

This example shows how to configure PingSource as an event source targeting
a Knative Service.

## Before you begin

1. Set up [Knative Serving](../../../serving).
1. Set up [Knative Eventing](../../../eventing).

## Create a Knative Service

To verify that `PingSource` is working, create a simple Knative
Service that dumps incoming messages to its log.

=== "Kubectl"
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
=== "Kn"
    Use following command to create the service using the kn cli:

    ```shell
    kn service create event-display --image gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
    ```

## Create a PingSource

For each set of ping events that you want to request, create an Event
Source in the same namespace as the destination.

=== "Kubectl"
    Use following command to create the event source from STDIN:

    ```shell
    cat <<EOF | kubectl create -f -
    apiVersion: sources.knative.dev/v1beta2
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
=== "Kn"
    Use following command to create the event source from the `ping-source.yaml` file:

    ```shell
    kn source ping create test-ping-source \
      --schedule "*/2 * * * *" --data \
      '{ "message": "Hello world!" }' \
      --sink ksvc:event-display
    ```

## (Optional) Create a PingSource with binary data

Sometimes you may want to send binary data, which cannot be directly serialized in yaml, to downstream. This can be achieved by using `dataBase64` as the payload. As the name suggests, `dataBase64` should carry data that is base64 encoded.

Please note that `data` and `dataBase64` cannot co-exist.

Use the following command to create the event source with binary data from STDIN:

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

## Verify

Verify that the message was sent to the Knative eventing system by
looking at message dumper logs.

=== "Kubectl"

    Use following command to view the logs of the event-display service:

    ```shell
    kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
    ```

=== "Kail"

    You can also use [`kail`](https://github.com/boz/kail) instead of `kubectl logs`
    to tail the logs of the subscriber.

    ```shell
    kail -l serving.knative.dev/service=event-display -c user-container --since=10m
    ```

You should see log lines showing the request headers and body from the source:

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

## Cleanup

You can delete the PingSource instance by entering the following command:

=== "Kubectl"
    ```shell
    kubectl delete pingsources.sources.knative.dev test-ping-source
    kubectl delete pingsources.sources.knative.dev test-ping-source-binary
    ```
=== "Kn"
    ```shell
    kn source ping delete test-ping-source
    kn source ping delete test-ping-source-binary
    ```

Similarly, you can delete the Service instance via:

=== "Kubectl"
    ```shell
    kubectl delete service.serving.knative.dev event-display
    ```
=== "Kn"
    ```shell
    kn service delete event-display
    ```
