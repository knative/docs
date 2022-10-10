# Creating a PingSource object

![stage](https://img.shields.io/badge/Stage-stable-green?style=flat-square)
![version](https://img.shields.io/badge/API_Version-v1-green?style=flat-square)

This topic describes how to create a PingSource object.

A PingSource is an event source that produces events with a fixed payload on a specified [cron](https://en.wikipedia.org/wiki/Cron) schedule.

The following example shows how you can configure a PingSource as an event source
that sends events every minute to a Knative service named `event-display` that is used as a sink.
If you have an existing sink, you can replace the examples with your own values.

## Before you begin

To create a PingSource:

- You must install [Knative Eventing](../../../install/yaml-install/eventing/install-eventing-with-yaml.md).
The PingSource event source type is enabled by default when you install Knative Eventing.
- You can use either `kubectl` or [`kn`](../../../client/install-kn.md) commands
to create components such as a sink and PingSource.
- You can use either `kubectl` or [`kail`](https://github.com/boz/kail) for logging
during the verification step in this procedure.

## Create a PingSource object

1. Optional: Create a namespace for your PingSource by running the command:

    ```bash
    kubectl create namespace <namespace>
    ```

    Where `<namespace>` is the namespace that you want your PingSource to use.
    For example, `pingsource-example`.

    !!! note
        Creating a namespace for your PingSource and related components allows
        you to view changes and events for this workflow more easily, because
        these are isolated from the other components that might exist in your
        `default` namespace.<br><br>
        It also makes removing the source easier, because you can delete the
        namespace to remove all of the resources.

1. Create a sink. If you do not have your own sink, you can use the following example Service that dumps incoming messages to a log:

    1. Copy the YAML below into a file:

        ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: event-display
          namespace: <namespace>
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
          namespace: <namespace>
        spec:
          selector:
            app: event-display
          ports:
          - protocol: TCP
            port: 80
            targetPort: 8080
        ```

        Where `<namespace>` is the name of the namespace that you created in step 1 above.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. Create the PingSource object.

    !!! note
        The data you want to send must be represented as text in the PingSource YAML file.
        Events that send binary data cannot be directly serialized in YAML.
        However, you can send binary data that is base64 encoded by using
        `dataBase64` in place of `data` in the PingSource spec.

    Use one of the following options:

    === "kn"

        - To create a PingSource that sends data that can be represented as
        plain text, such as text, JSON, or XML, run the command:

            ```bash
            kn source ping create <pingsource-name> \
              --namespace <namespace> \
              --schedule "<cron-schedule>" \
              --data '<data>' \
              --sink <sink-name>
            ```
            Where:

            - `<pingsource-name>` is the name of the PingSource that you want to create, for example, `test-ping-source`.
            - `<namespace>` is the name of the namespace that you created in step 1 above.
            - `<cron-schedule>` is a cron expression for the schedule for the PingSource to send events, for example, `*/1 * * * *` sends an event every minute.
            - `<data>` is the data you want to send. This data must be represented as text, not binary. For example, a JSON object such as `{"message": "Hello world!"}`.
            - `<sink-name>` is the name of your sink, for example, `http://event-display.pingsource-example.svc.cluster.local`.

            For a list of available options, see the [Knative client documentation](https://github.com/knative/client/blob/main/docs/cmd/kn_source_ping_create.md).

    === "kn: binary data"

        - To create a PingSource that sends binary data, run the command:

            ```bash
            kn source ping create <pingsource-name> \
              --namespace <namespace> \
              --schedule "<cron-schedule>" \
              --data '<base64-data>' \
              --encoding 'base64' \
              --sink <sink-name>
            ```
            Where:

            - `<pingsource-name>` is the name of the PingSource that you want to create, for example, `test-ping-source`.
            - `<namespace>` is the name of the namespace that you created in step 1 above.
            - `<cron-schedule>` is a cron expression for the schedule for the PingSource to send events, for example, `*/1 * * * *` sends an event every minute.
            -  `<base64-data>` is the base64 encoded binary data that you want to send, for example, `ZGF0YQ==`.
            - `<sink-name>` is the name of your sink, for example, `http://event-display.pingsource-example.svc.cluster.local`.

            For a list of available options, see the [Knative client documentation](https://github.com/knative/client/blob/main/docs/cmd/kn_source_ping_create.md).

    === "YAML"

        - To create a PingSource that sends data that can be represented as plain text,
        such as text, JSON, or XML:

            1. Create a YAML file using the template below:

                ```yaml
                apiVersion: sources.knative.dev/v1
                kind: PingSource
                metadata:
                  name: <pingsource-name>
                  namespace: <namespace>
                spec:
                  schedule: "<cron-schedule>"
                  contentType: "<content-type>"
                  data: '<data>'
                  sink:
                    ref:
                      apiVersion: v1
                      kind: <sink-kind>
                      name: <sink-name>
                ```
                Where:

                - `<pingsource-name>` is the name of the PingSource that you want to create, for example, `test-ping-source`.
                - `<namespace>` is the name of the namespace that you created in step 1 above.
                - `<cron-schedule>` is a cron expression for the schedule for the PingSource to send events, for example, `*/1 * * * *` sends an event every minute.
                - `<content-type>` is the media type of the data you want to send, for example, `application/json`.
                - `<data>` is the data you want to send. This data must be represented as text, not binary. For example, a JSON object such as `{"message": "Hello world!"}`.
                - `<sink-kind>` is any supported Addressable object that you want to use as a sink, for example, a `Service` or `Deployment`.
                - `<sink-name>` is the name of your sink, for example, `event-display`.

                For more information about the fields you can configure for the PingSource object, see [PingSource reference](reference.md).

            1. Apply the YAML file by running the command:

                ```bash
                kubectl apply -f <filename>.yaml
                ```
                Where `<filename>` is the name of the file you created in the previous step.

    === "YAML: binary data"

        - To create a PingSource that sends binary data:

            1. Create a YAML file using the template below:

                ```yaml
                apiVersion: sources.knative.dev/v1
                kind: PingSource
                metadata:
                  name: <pingsource-name>
                  namespace: <namespace>
                spec:
                  schedule: "<cron-schedule>"
                  contentType: "<content-type>"
                  dataBase64: "<base64-data>"
                  sink:
                    ref:
                      apiVersion: v1
                      kind: <sink-kind>
                      name: <sink-name>
                ```
                Where:

                - `<pingsource-name>` is the name of the PingSource that you want to create, for example, `test-ping-source-binary`.
                - `<namespace>` is the name of the namespace that you created in step 1 above.
                - `<cron-schedule>` is a cron expression for the schedule for the PingSource to send events, for example, `*/1 * * * *` sends an event every minute.
                - `<content-type>` is the media type of the data you want to send, for example, `application/json`.
                - `<base64-data>` is the base64 encoded binary data that you want to send, for example, `ZGF0YQ==`.
                - `<sink-kind>` is any supported Addressable object that you want to use as a sink, for example, a Kubernetes Service.
                - `<sink-name>` is the name of your sink, for example, `event-display`.

                For more information about the fields you can configure for the PingSource object, see [PingSource reference](reference.md).

            1. Apply the YAML file by running the command:

                ```bash
                kubectl apply -f <filename>.yaml
                ```
                Where `<filename>` is the name of the file you created in the previous step.


## Verify the PingSource object

1. View the logs for the `event-display` event consumer by running the command:

    === "kubectl"

        ```bash
        kubectl -n pingsource-example logs -l app=event-display --tail=100
        ```


    === "kail"

        ```bash
        kail -l serving.knative.dev/service=event-display -c user-container --since=10m
        ```

1. Verify that the output returns the properties of the events that your
PingSource sent to your sink.
In the example below, the command has returned the `Attributes` and `Data` properties
of the events that the PingSource sent to the `event-display` Service:

    ```{ .bash .no-copy }
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


## Delete the PingSource object

You can either delete the PingSource and all related resources, or delete the resources individually:

- To remove the PingSource object and all of the related resources, delete the namespace by running the command:

    ```bash
    kubectl delete namespace <namespace>
    ```
    Where `<namespace>` is the namespace that contains the PingSource object.


- To delete the PingSource instance only, run the command:

    === "kn"

        ```bash
        kn source ping delete <pingsource-name>
        ```
        Where `<pingsource-name>` is the name of the PingSource you want to delete, for example, `test-ping-source`.

    === "kubectl"

        ```bash
        kubectl delete pingsources.sources.knative.dev <pingsource-name>
        ```
        Where `<pingsource-name>` is the name of the PingSource you want to delete, for example, `test-ping-source`.

- To delete the sink only, run the command:

    === "kn"

        ```bash
        kn service delete <sink-name>
        ```
        Where `<sink-name>` is the name of your sink, for example, `event-display`.

    === "kubectl"

        ```bash
        kubectl delete service.serving.knative.dev <sink-name>
        ```
        Where `<sink-name>` is the name of your sink, for example, `event-display`.
