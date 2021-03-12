---
title: "Sink binding"
weight: 60
type: "docs"
aliases:
    - /docs/eventing/samples/sinkbinding/index
    - /docs/eventing/samples/sinkbinding/README
---

![version](https://img.shields.io/badge/API_Version-v1-red?style=flat-square)

The `SinkBinding` custom object supports decoupling event production from delivery addressing.

You can use sink binding to connect Kubernetes resources that embed a `PodSpec` and want to produce events, such as an event source, to an addressable Kubernetes object that can receive events, also known as an _event sink_.

Sink binding can be used to create new event sources using any of the familiar compute objects that Kubernetes makes available.
For example, `Deployment`, `Job`, `DaemonSet`, or `StatefulSet` objects, or Knative abstractions, such as `Service` or `Configuration` objects, can be used.

Sink binding injects environment variables into the `PodTemplateSpec` of the event sink, so that the application code does not need to interact directly with the Kubernetes API to locate the event destination.

Sink binding operates in one of two modes; `Inclusion` or `Exclusion`.
You can set the mode by modifying the `SINK_BINDING_SELECTION_MODE` of the `eventing-webhook` deployment accordingly. The mode determines the default scope of the webhook.

By default, the webhook is set to `exclusion` mode, which means that any namespace that does not have the label `bindings.knative.dev/exclude: true` will be subject to mutation evalutation.

If `SINK_BINDING_SELECTION_MODE` is set to `inclusion`, only the resources in a namespace labelled with `bindings.knative.dev/include: true` will be considered.  In `inclusion` mode, any SinkBinding resource created will automatically label the `subject` namespace with `bindings.knative.dev/include: true` for inclusion in the potential environment variable inclusions.

## Getting started

The following procedures show how you can create a sink binding and connect it to a service and event source in your cluster.

### Creating a namespace

Create a namespace called `sinkbinding-example`:

  ```bash
  kubectl create namespace sinkbinding-example
  ```

### Creating a Knative service

Create a Knative service if you do not have an existing event sink that you want to connect to the sink binding.

#### Prerequisites
- You must have Knative Serving installed on your cluster.
- Optional: If you want to use `kn` commands with sink binding, you must install the `kn` CLI.

#### Procedure
Create a Knative service:

{{< tabs name="knative_service" default="kn" >}}
{{% tab name="kn" %}}

```bash
kn service create hello --image gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display --env RESPONSE="Hello Serverless!"
```

{{< /tab >}}
{{% tab name="yaml" %}}

1. Copy the sample YAML into a `service.yaml` file:
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: event-display
    spec:
      template:
        spec:
          containers:
            - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
    ```
2. Apply the file:
    ```bash
    kubectl apply --filename service.yaml
    ```

{{< /tab >}}
{{< /tabs >}}

### Creating a cron job

Create a cron job if you do not have an existing event source that you want to connect to the sink binding.

<!-- TODO: Add kn command-->
Create a `CronJob` object:

1. Copy the sample YAML into a `cronjob.yaml` file:
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
2. Apply the file:
    ```bash
    kubectl apply --filename heartbeats-source.yaml
    ```

#### Cloning a sample heartbeat cron job

Knative [event-contrib](https://github.com/knative/eventing-contrib) contains a
sample heartbeats event source.

##### Prerequisites

- Ensure that `ko publish` is set up correctly:
  - [`KO_DOCKER_REPO`](https://github.com/knative/serving/blob/main/DEVELOPMENT.md#environment-setup)
  must be set. For example, `gcr.io/[gcloud-project]` or `docker.io/<username>`.
  - You must have authenticated with your `KO_DOCKER_REPO`.

##### Procedure

1. Clone the `event-contib` repository:
    ```bash
    $ git clone -b "{{< branch >}}" https://github.com/knative/eventing-contrib.git
    ```
2. Build a heartbeats image, and publish the image to your image repository:
    ```bash
    $ ko publish knative.dev/eventing-contrib/cmd/heartbeats
    ```
<!-- TODO: Add tabs if there are kn commands etc to do this also-->

## Creating a SinkBinding object

Create a `SinkBinding` object that directs events from your cron job to the event sink.

### Prerequisites

- You must have Knative Eventing installed on your cluster.
- Optional: If you want to use `kn` commands with sink binding, you must install the `kn` CLI.

### Procedure

Create a sink binding:

{{< tabs name="sinkbinding" default="kn" >}}
{{% tab name="kn" %}}

```bash
kn source binding create bind-heartbeat \
  --namespace sinkbinding-example \
  --subject "Job:batch/v1:app=heartbeat-cron" \
  --sink http://event-display.svc.cluster.local \
  --ce-override "sink=bound"
```

{{< /tab >}}
{{% tab name="yaml" %}}

1. Copy the sample YAML into a `cronjob.yaml` file:
    ```yaml
    apiVersion: sources.knative.dev/v1alpha1
    kind: SinkBinding
    metadata:
      name: bind-heartbeat
    spec:
      subject:
        apiVersion: batch/v1
        kind: Job
        selector:
          matchLabels:
            app: heartbeat-cron
        sink:
          ref:
            apiVersion: serving.knative.dev/v1
            kind: Service
            name: event-display
    ```
2. Apply the file:
    ```bash
    kubectl apply --filename heartbeats-source.yaml
    ```

{{< /tab >}}
{{< /tabs >}}

## Verification steps

1. Verify that a message was sent to the Knative eventing system by looking at the `event-display` service logs:
    ```bash
    kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
    ```
2. Observe the lines showing the request headers and body of the event message, sent by the heartbeats source to the display function:
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

Delete the `sinkbinding-example` namespace and all of its resources from your
cluster:

  ```bash
  kubectl delete namespace sinkbinding-example
  ```
