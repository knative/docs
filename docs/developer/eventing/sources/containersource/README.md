# Creating a ContainerSource object

![API version v1](https://img.shields.io/badge/API_Version-v1-red?style=flat-square)

This topic describes how to configure ContainerSource as an event source for
functions.

The ContainerSource object starts a container image that generates events and
sends messages to a sink URI. You can also use ContainerSource to support your
own event sources in Knative.

In the examples below, the event source is a heartbeats container and the sink
is a Knative Service.
If you have an existing event source and sink, you can replace the examples with
your own values.

## Before you begin

Before you can create a ContainerSource object:

- You must have [Knative Eventing](../../../admin/install/install-eventing-with-yaml)
installed on your cluster.
- If you want to use the example heartbeats event source below, you must also:
    - Install [ko](https://github.com/google/ko)
    - Set `KO_DOCKER_REPO`. For example, `gcr.io/[gcloud-project]` or `docker.io/<username>`
    - Authenticate with your `KO_DOCKER_REPO`
    - Install [`docker`](https://docs.docker.com/install/)

## Create a ContainerSource object

1. Build an image of your event source and publish it to your image repository.
Your image must read the environment variable `K_SINK` and post messages to the
URL specified in  `K_SINK`. If you do not already have an image, you can use
the following example heartbeats event source by running the commands:

    ```bash
    git clone -b "{{ branch }}" https://github.com/knative/eventing.git
    ```

    ```bash
    ko publish ko://knative.dev/eventing/cmd/heartbeats
    ```

1. Create a namespace for your ContainerSource by running the command:

    ```bash
    kubectl create namespace <namespace>
    ```

    Where `<namespace>` is the namespace that you want your ContainerSource to use.
    For example, `containersource-example`.

1. Create a sink. If you do not already have a sink, you can use the following Knative
Service, which dumps incoming messages into its log:

    !!! note
        To create a Knative service you must have Knative Serving installed on your cluster.

    === "kn"
    - To create a sink, run the command:

        ```bash
        kn service create event-display --port 8080 --image gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
        ```

    === "YAML"
    1. Create a YAML file using the example below:

        ```yaml
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
                  image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display

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
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply --filename <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.


1. Create a concrete ContainerSource with specific arguments and environment settings:

    === "kn"
        - To create the ContainerSource, run the command:

            ```bash
            kn source container create <name> --image <image-uri> --sink <sink>
            ```
            Where:

            - `<name>` is the name you want for your ContainerSource object,
            for example, `test-heartbeats`.
            - `<image-uri>` corresponds to the image URI you built and published
            in step 1, for example, `gcr.io/[gcloud-project]/knative.dev/eventing/cmd/heartbeats`.
            - `<sink>` is the name of your sink, for example `<event-display>`.

            For a list of available options, see the [Knative client documentation](https://github.com/knative/client/blob/main/docs/cmd/kn_source_container_create.md#kn-source-container-create).

    === "YAML"
        1. Create a YAML file using the template below:

            ```yaml
            apiVersion: sources.knative.dev/v1
            kind: ContainerSource
            metadata:
              name: <containersource-name>
            spec:
              template:
                spec:
                  containers:
                    - image: <event-source-image-uri>
                      name: <container-name>
                      env:
                        - name: POD_NAME
                          value: "<pod-name>"
                        - name: POD_NAMESPACE
                          value: "<pod-namespace>"
              sink:
                ref:
                  apiVersion: v1
                  kind: Service
                  name: <sink>
            ```
            Where:

            - `<namespace>` is the namespace you created for your ContainerSource,
            for example, `containersource-example`.
            - `<containersource-name>` is the name you want for your ContainerSource,
            for example, `test-heartbeats`.
            - `<event-source-image-uri>` corresponds to the image URI you built and published
            in step 1, for example, `gcr.io/[gcloud-project]/knative.dev/eventing/cmd/heartbeats`.
            - `<container-name>` is the name of your event source, for example, `heartbeats`.
            - `<pod-name>` is the name of the Pod that the container runs in, for example, `mypod`.
            - `<pod-namespace>` is the namespace that the Pod runs in, for example, `event-test`.
            - `<sink>` is the name of your sink, for example, `event-display`.

            For more information about the fields you can configure for the ContainerSource
            object, see [ContainerSource Reference](reference.md).

        1. Apply the YAML file by running the command:

            ```bash
            kubectl apply --filename <filename>.yaml
            ```
            Where `<filename>` is the name of the file you created in the previous step.

    !!! note
        Arguments and environment variables are set and are passed to the container.

## Verify the ContainerSource object

1. View the logs for your event consumer by running the command:

    ```shell
    kubectl -n <namespace> logs -l <pod-name> --tail=200
    ```
    Where:

    - `<namespace>` is the namespace that contains the ContainerSource object.
    - `<pod-name>` is the name of the Pod that the container runs in.

    For example:

    ```shell
    $ kubectl -n containersource-example logs -l app=event-display --tail=200
    ```

1. Verify that the output returns the properties of the events that your
ContainerSource sent to your sink.
In the example below, the command has returned the `Attributes` and `Data` properties
of the events that the ContainerSource sent to the `event-display` Service:

    ```
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: dev.knative.eventing.samples.heartbeat
      source: https://knative.dev/eventing/cmd/heartbeats/#event-test/mypod
      id: 2b72d7bf-c38f-4a98-a433-608fbcdd2596
      time: 2019-10-18T15:23:20.809775386Z
      contenttype: application/json
    Extensions,
      beats: true
      heart: yes
      the: 42
    Data,
      {
        "id": 2,
        "label": ""
      }
    ```

## Cleanup

To delete the ContainerSource object and all of the related resources in the
namespace:

- Delete the namespace by running the command:

    ```shell
    kubectl delete namespace <namespace>
    ```

    Where `<namespace>` is the namespace that contains the ContainerSource object.

## Reference Documentation

See the [ContainerSource specification](../../../reference/api/eventing/eventing/#sources.knative.dev/v1.ContainerSource).
