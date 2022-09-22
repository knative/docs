# Create a SinkBinding

![API version v1](https://img.shields.io/badge/API_Version-v1-green?style=flat-square)

This topic describes how to create a SinkBinding object.
SinkBinding resolves a sink as a URI, sets the URI in the environment
variable `K_SINK`, and adds the URI to a subject using `K_SINK`.
If the URI changes, SinkBinding updates the value of `K_SINK`.

In the following examples, the sink is a Knative Service and the subject is a CronJob.
If you have an existing subject and sink, you can replace the examples with your
own values.

## Before you begin

Before you can create a SinkBinding object:

- You must have Knative Eventing installed on your cluster.
- Optional: If you want to use `kn` commands with SinkBinding, install the `kn` CLI.

## Optional: Choose SinkBinding namespace selection behavior

The SinkBinding object operates in one of two modes: `exclusion` or `inclusion`.

The default mode is `exclusion`.
In exclusion mode, SinkBinding behavior is enabled for the namespace by default.
To disallow a namespace from being evaluated for mutation you must exclude it
using the label `bindings.knative.dev/exclude: true`.

In inclusion mode, SinkBinding behavior is not enabled for the namespace.
Before a namespace can be evaluated for mutation, you must
explicitly include it using the label `bindings.knative.dev/include: true`.

To set the SinkBinding object to inclusion mode:

1. Change the value of `SINK_BINDING_SELECTION_MODE` from `exclusion` to `inclusion` by running:

    ```bash
    kubectl -n knative-eventing set env deployments eventing-webhook --containers="eventing-webhook" SINK_BINDING_SELECTION_MODE=inclusion
    ```

2. To verify that `SINK_BINDING_SELECTION_MODE` is set as desired, run:

    ```bash
    kubectl -n knative-eventing set env deployments eventing-webhook --containers="eventing-webhook" --list | grep SINK_BINDING
    ```

## Create a namespace

If you do not have an existing namespace, create a namespace for the SinkBinding object:

```bash
kubectl create namespace <namespace>
```
Where `<namespace>` is the namespace that you want your SinkBinding to use.
For example, `sinkbinding-example`.

!!! note
    If you have selected inclusion mode, you must add the
    `bindings.knative.dev/include: true` label to the namespace to enable
    SinkBinding behavior.

## Create a sink

The sink can be any addressable Kubernetes object that can receive events.

If you do not have an existing sink that you want to connect to the SinkBinding object,
create a Knative service.

!!! note
    To create a Knative service you must have Knative Serving installed on your cluster.

=== "kn"

    Create a Knative service by running:

    ```bash
    kn service create <app-name> --image <image-url>
    ```
    Where:

    - `<app-name>` is the name of the application.
    - `<image-url>` is the URL of the image container.

    For example:

    ```bash
    $ kn service create event-display --image gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
    ```

=== "YAML"
    1. Create a YAML file for the Knative service using the following template:

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
        For example, `gcr.io/knative-releases/knative.dev/eventing/cmd/event_display`.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

## Create a subject

The subject must be a PodSpecable resource.
You can use any PodSpecable resource in your cluster, for example:

- `Deployment`
- `Job`
- `DaemonSet`
- `StatefulSet`
- `Service.serving.knative.dev`

If you do not have an existing PodSpecable subject that you want to use, you can
use the following sample to create a CronJob object as the subject.
The following CronJob makes a single cloud event that targets `K_SINK` and adds
any extra overrides given by `CE_OVERRIDES`.

1. Create a YAML file for the CronJob using the following example:

    ```yaml
    apiVersion: batch/v1
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
                  image: gcr.io/knative-nightly/knative.dev/eventing/cmd/heartbeats
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

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

## Create a SinkBinding object

Create a `SinkBinding` object that directs events from your subject to the sink.

=== "kn"

    Create a `SinkBinding` object by running:

    ```bash
    kn source binding create <name> \
      --namespace <namespace> \
      --subject "<subject>" \
      --sink <sink> \
      --ce-override "<cloudevent-overrides>"
    ```
    Where:

    - `<name>` is the name of the SinkBinding object you want to create.
    - `<namespace>` is the namespace you created for your SinkBinding to use.
    - `<subject>` is the subject to connect. Examples:
        - `Job:batch/v1:app=heartbeat-cron` matches all jobs in namespace with label `app=heartbeat-cron`.
        - `Deployment:apps/v1:myapp` matches a deployment called `myapp` in the namespace.
        - `Service:serving.knative.dev/v1:hello` matches the service called `hello`.
    - `<sink>` is the sink to connect. For example `http://event-display.svc.cluster.local`.
    - Optional: `<cloudevent-overrides>` in the form `key=value`.
    Cloud Event overrides control the output format and modifications of the event
    sent to the sink and are applied before sending the event.
    You can provide this flag multiple times.

    For a list of available options, see the [Knative client documentation](https://github.com/knative/client/blob/main/docs/cmd/kn_source_binding_create.md#kn-source-binding-create).

    For example:
    ```bash
    $ kn source binding create bind-heartbeat \
      --namespace sinkbinding-example \
      --subject "Job:batch/v1:app=heartbeat-cron" \
      --sink http://event-display.svc.cluster.local \
      --ce-override "sink=bound"
    ```

=== "YAML"
    1. Create a YAML file for the `SinkBinding` object using the following template:

        ```yaml
        apiVersion: sources.knative.dev/v1
        kind: SinkBinding
        metadata:
          name: <name>
        spec:
          subject:
            apiVersion: <api-version>
            kind: <kind>
            selector:
              matchLabels:
                <label-key>: <label-value>
          sink:
            ref:
              apiVersion: serving.knative.dev/v1
              kind: Service
              name: <sink>
        ```
        Where:

        - `<name>` is the name of the SinkBinding object you want to create. For example, `bind-heartbeat`.
        - `<api-version>` is the API version of the subject. For example `batch/v1`.
        - `<kind>` is the Kind of your subject. For example `Job`.
        - `<label-key>: <label-value>` is a map of key-value pairs to select subjects
        that have a matching label. For example, `app: heartbeat-cron` selects any subject
        with the label `app=heartbeat-cron`.
        - `<sink>` is the sink to connect. For example `event-display`.

        For more information about the fields you can configure for the SinkBinding
        object, see [Sink Binding Reference](reference.md).

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

## Verify the SinkBinding object

1. Verify that a message was sent to the Knative eventing system by looking at the
service logs for your sink:

    ```bash
    kubectl logs -l <sink> -c <container> --since=10m
    ```
    Where:

    - `<sink>` is the name of your sink.
    - `<container>` is the name of the container your sink is running in.

    For example:
    ```bash
    $ kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
    ```

2. From the output, observe the lines showing the request headers and body of the event message,
sent by the source to the display function. For example:

    ```{ .bash .no-copy }
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

## Delete a SinkBinding

To delete the SinkBinding object and all of the related resources in the namespace,
delete the namespace by running:

```bash
kubectl delete namespace <namespace>
```
Where `<namespace>` is the name of the namespace that contains the SinkBinding object.
