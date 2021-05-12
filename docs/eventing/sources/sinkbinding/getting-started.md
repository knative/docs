---
title: "Getting Started"
weight: 02
type: "docs"
aliases:
    - /docs/eventing/samples/sinkbinding/index
    - /docs/eventing/samples/sinkbinding/README
---

![API version v1](https://img.shields.io/badge/API_Version-v1-red?style=flat-square)

This topic describes how to create a SinkBinding and connect it to a subject in your cluster.

## Before you begin

Before you can create a SinkBinding, you must:

- Have Knative Serving installed on your cluster.
- Optional: If you want to use `kn` commands with a SinkBinding, install the `kn` CLI.

## Optional: Choose SinkBinding namespace selection behavior

The SinkBinding object operates in one of two modes: `exclusion` or `inclusion`.

The default mode is `exclusion`.
In exclusion mode, SinkBinding behavior is enabled for the namespace by default.
To disallow a namespace from being evaluated for mutation you must exclude it
using the label `bindings.knative.dev/exclude: true`.

In inclusion mode, SinkBinding behavior is not enabled for the namespace.
Before a namespace can be evaluated for mutation you must
explicitly include it using the label `bindings.knative.dev/include: true`.

### Set to inclusion mode

To set to inclusion mode, edit the `eventing-webhook` deployment.
Set `SINK_BINDING_SELECTION_MODE` to `inclusion`.
The mode determines the default scope of the webhook.

## Create a namespace

If you do not have an existing namespace, create a namespace for the SinkBinding:

    ```bash
    kubectl create namespace <namespace>
    ```
    Where `<namespace>` is the namespace that you want your SinkBinding to use.

    For example:
    ```bash
    kubectl create namespace sinkbinding-example
    ```

**NOTE:** if you have selected inclusion mode, you must add the
`bindings.knative.dev/include: true` label to the namespace to enable SinkBinding behavior.


## Create an event sink

The event sink can be any addressable Kubernetes object that can receive events.

If you do not have an existing event sink that you want to connect to the sink
binding, create a Knative service:

  {{< tabs name="knative_service" default="kn" >}}
  {{% tab name="kn" %}}

  ```bash
  kn service create <app-name> --image <image-url>
  ```
  Where:
  - `<app-name>` is the name of the application
  - `<image-url>` is the URL of the image container

  For example:

  ```bash
  kn service create hello --image gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
  ```
  {{< /tab >}}
  {{% tab name="yaml" %}}

  1. Copy the following YAML into a `service.yaml` file:
      ```yaml
      apiVersion: serving.knative.dev/v1
      kind: Service
      metadata:
        name: <app-name>
      spec:
        template:
          spec:
            containers:
              - image: <image-url>
      ```
      Where:
      - `<app-name>` is the name of the application. For example, `event-display`.
      - `<image-url>` is the URL of the image container.
      For example, `gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display`

  2. Apply the file:
      ```bash
      kubectl apply --filename service.yaml
      ```

  {{< /tab >}}
  {{< /tabs >}}

## Create a subject

The subject must be a PodSpecable resource.
You can use any PodSpecable resource in your cluster, for example:

- `Deployment`
- `Job`
- `DaemonSet`
- `StatefulSet`
- `Service.serving.knative.dev`

For instructions on how to create a subject, see (LINK). <!-- do we want to provide a link to guidance on creating a subject? -->

If you do not have an existing PodSpecable subject that you want to use for the
SinkBinding, you can use the following sample to create a `CronJob` object as the subject:

1. Copy the sample YAML below into a `cronjob.yaml` file:

    ```yaml
    apiVersion: batch/v1beta1
    kind: CronJob
    metadata:
      name: heartbeat-cron
    spec:
      # Run every minute
      schedule: "*/1 * * * *"
      jobTemplate:
        metadata:
          labels:
            app: heartbeat-cron
        spec:
          template:
            spec:
              restartPolicy: Never
              containers:
                - name: single-heartbeat
                  image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/heartbeats
                  args:
                  - --period=1
                  env:
                    - name: ONE_SHOT
                      value: "true"
                    - name: POD_NAME
                      valueFrom:
                        fieldRef:
                          fieldPath: metadata.name
                    - name: POD_NAMESPACE
                      valueFrom:
                        fieldRef:
                          fieldPath: metadata.namespace
    ```

2. Apply the subject's YAML file:
    ```bash
    kubectl apply --filename cronjob.yaml
    ```

## Create a SinkBinding object

Create a `SinkBinding` object that directs events from your subject to the event sink:

{{< tabs name="sinkbinding" default="kn" >}}
{{% tab name="kn" %}}

```bash
kn source binding create <name> \
  --namespace <namespace> \
  --subject <subject> \
  --sink <event-sink> \
  --ce-override "sink=bound"
```
Where:
- `<name>` is the name of the SinkBinding object you want to create.
- `<namespace>` is the namespace you created for your SinkBinding to use.
- `<subject>` is the subject to connect. Examples of subjects:
  - `"Job:batch/v1:app=heartbeat-cron"` matches all jobs in namespace with label `app=heartbeat-cron`.
  - `Deployment:apps/v1:myapp` matches deployment called myapp in the namespace.
  - `Service:serving.knative.dev/v1:hello` match the service called hello.
- `<event-sink>` is the event sink to connect. For example `http://event-display.svc.cluster.local`.

For example:
```bash
kn source binding create bind-heartbeat \
  --namespace sinkbinding-example \
  --subject "Job:batch/v1:app=heartbeat-cron" \
  --sink http://event-display.svc.cluster.local \
  --ce-override "sink=bound"
```

{{< /tab >}}
{{% tab name="yaml" %}}

1. Copy the following to a your subject's YAML file:

    ```yaml
    apiVersion: sources.knative.dev/v1alpha1
    kind: SinkBinding
    metadata:
      name: <name>
    spec:
      subject:
        apiVersion: <api-version>
        kind: <kind>
        selector:
          matchLabels:
            app: <app-name>
        sink:
          ref:
            apiVersion: serving.knative.dev/v1
            kind: Service
            name: <event-name>
    ```
    Where:
    - `<name>` is the name of the SinkBinding object you want to create. For example, `bind-heartbeat`.
    - `<kind>` is the Kind of your subject. For example `Job`.
    - `<api-version>` is the API version of the subject. For example `batch/v1`.
    - `<app-name>` is the name of the subject to connect. For example, `heartbeat-cron`. <!-- is this right? -->
    - `<event-sink>` is the event sink to connect. For example `event-display`.

2. Apply the file:
    ```bash
    kubectl apply --filename <filename>.yaml
    ```
    Where `filename` is the name of the YAML file for your subject.

    For example:

    ```bash
    kubectl apply --filename cronjob.yaml
    ```

{{< /tab >}}
{{< /tabs >}}

## Verify the SinkBinding

1. Verify that a message was sent to the Knative eventing system by looking at the
service logs for your event sink:

    ```bash
    kubectl logs -l <event-sink> -c <container> --since=10m
    ```
    Where:
    - `<event-sink>` is the name of the event sink you created.
    - `<container>` is the name of the container your event sink is running in.

    For example:
    ```bash
    kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
    ```
2. From the output, observe the lines showing the request headers and body of the event message,
sent by the source to the display function. For example:

    ```bash
      ☁️  cloudevents.Event
      Validation: valid
      Context Attributes,
        specversion: 1.0
        type: dev.knative.eventing.samples.heartbeat
        source: https://knative.dev/eventing-contrib/cmd/heartbeats/#default/heartbeat-cron-1582120020-75qrz
        id: 5f4122be-ac6f-4349-a94f-4bfc6eb3f687
        time: 2020-02-19T13:47:10.41428688Z
        datacontenttype: application/json
      Extensions,
        beats: true
        heart: yes
        the: 42
      Data,
        {
          "id": 1,
          "label": ""
        }
    ```

## Cleanup

To delete the SinkBinding and all of the related resources in the namespace,
delete the namespace by running:

```shell
kubectl delete namespace <namespace>
```
Where `<namespace>` is the name of the namespace that contains the SinkBinding object
