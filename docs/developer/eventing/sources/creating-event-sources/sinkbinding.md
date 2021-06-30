# Using SinkBinding

SinkBinding does not create any containers. It injects the sink information to an already existing Kubernetes PodSpecable object. You can use any Kubernetes PodSpecable object as an event source, such as a Deployment, Job, or Knative Service.

## Procedure

1. Create a Kubernetes PodSpecable object of any type that you want to use as an event source.
<!--TODO: Add links to object docs-->

1. Create a Kubernetes deployment that runs the object you have created.

    **Example Deployment**
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: node-heartbeats-deployment
      labels:
        app: node-heartbeats
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: node-heartbeats
      template:
        metadata:
          labels:
            app: node-heartbeats
        spec:
          containers:
          - name: node-heartbeats
            image: path/to/image/registry/node-knative-heartbeat-source:v1
            ports:
            - containerPort: 8080
    ```

1. Check the logs for the Deployment:

    ```bash
    $ kubectl logs node-heartbeats-deployment-9ffbb644b-llkzk
    ```
    <!--TODO: determine how this name is found, is it the name of the pod? Can just the name of the Deployment be used?-->

    Because the SinkBinding has not yet been created, you will see an error message, because the `K_SINK` environment variable is not yet injected:

    ```
    Sink URL is undefined
    Emitting event #1
    Error during event post
    TypeError [ERR_INVALID_ARG_TYPE]: The "url" argument must be of type string. Received type undefined
    ```

1. Create a SinkBinding object that contains the Deployment as a `subject` and the PodSpecable object as a `sink`:

    **Example Sinkbinding:**
    ```yaml
    apiVersion: sources.knative.dev/v1
    kind: SinkBinding
    metadata:
      name: bind-node-heartbeat
    spec:
      subject:
        apiVersion: apps/v1
        kind: Deployment
        selector:
          matchLabels:
            app: node-heartbeats
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: event-display
    ```

1. The pods are now recreated and the `K_SINK` environment variable is injected. Since `replicas` is set to 2, there are 2 pods that post events to the sink.

    You can verify this by checking the Deployment logs by running the command:

    ```bash
    $ kubectl logs event-display-dpplv-deployment-67c9949cf9-bvjvk -c user-container
    ```

    **Example output:**
    ```bash
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: your.event.source.type
      source: urn:event:from:your-api/resource/123
      id: your-event-id
      datacontenttype: application/json
    Data,
      {
        "hello": "World 1"
      }

    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: your.event.source.type
      source: urn:event:from:your-api/resource/123
      id: your-event-id
      datacontenttype: application/json
    Data,
      {
        "hello": "World 1"
      }
    ```
