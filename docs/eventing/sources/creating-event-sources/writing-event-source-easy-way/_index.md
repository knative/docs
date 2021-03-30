---
title: "Writing an event source using Javascript"
weight: 10
type: "docs"
showlandingtoc: "false"
aliases:
  - /docs/eventing/samples/writing-event-source-easy-way
---

This tutorial provides instructions to build an event source in Javascript and implement it with a ContainerSource or SinkBinding.

- Using a [ContainerSource](../../containersource) is a simple way to turn any dispatcher container into a Knative event source.
- Using [SinkBinding](../../sinkbinding) provides a framework for injecting environment variables into any Kubernetes resource that has a `spec.template` and is [PodSpecable](https://pkg.go.dev/knative.dev/pkg/apis/duck/v1#PodSpecable).

ContainerSource and SinkBinding both work by injecting environment variables to an application. Injected environment variables at minimum contain the URL of a sink that will receive events.

## Bootstrapping

Create the project and add the dependencies:

```bash
npm init
npm install cloudevents-sdk@2.0.1 --save
```

**NOTE:** Due to this [bug](https://github.com/cloudevents/sdk-javascript/issues/191), you must use version 2.0.1 of the Javascript SDK or newer.

## Using ContainerSource

A ContainerSource creates a container for your event source image and manages this container.

The sink URL to post the events will be made available to the application through the `K_SINK` environment variable by the ContainerSource.

### Example

The following example event source emits an event to the sink every 1000 milliseconds:

```javascript
// File - index.js

const { CloudEvent, HTTPEmitter } = require("cloudevents-sdk");

let sinkUrl = process.env['K_SINK'];

console.log("Sink URL is " + sinkUrl);

let emitter = new HTTPEmitter({
    url: sinkUrl
});

let eventIndex = 0;
setInterval(function () {
    console.log("Emitting event #" + ++eventIndex);

    let myevent = new CloudEvent({
        source: "urn:event:from:my-api/resource/123",
        type: "your.event.source.type",
        id: "your-event-id",
        dataContentType: "application/json",
        data: {"hello": "World " + eventIndex},
    });

    // Emit the event
    emitter.send(myevent)
        .then(response => {
            // Treat the response
            console.log("Event posted successfully");
            console.log(response.data);
        })
        .catch(err => {
            // Deal with errors
            console.log("Error during event post");
            console.error(err);
        });
}, 1000);
```

```dockerfile
# File - Dockerfile

FROM node:10
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8080
CMD [ "node", "index.js" ]

```

The example code uses _Binary_ mode for CloudEvents. To employ structured code, change `let binding = new v1.BinaryHTTPEmitter(config);` to `let binding = new v1.StructuredHTTPEmitter(config);`.

Binary mode is used in most cases because:
- It is faster in terms of serialization and deserialization.
- It works better with CloudEvent-aware proxies, such as Knative Channels, and can simply check the header instead of parsing the payload.

### Procedure

1. Build and push the image:

    ```bash
    docker build . -t path/to/image/registry/node-knative-heartbeat-source:v1
    docker push path/to/image/registry/node-knative-heartbeat-source:v1
    ```

2. Create the event display service which logs any CloudEvents posted to it:

    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: event-display
    spec:
      template:
        spec:
          containers:
            - image: docker.io/aliok/event_display-864884f202126ec3150c5fcef437d90c@sha256:93cb4dcda8fee80a1f68662ae6bf20301471b046ede628f3c3f94f39752fbe08
    ```

3. Create the ContainerSource object:

    ```yaml
    apiVersion: sources.knative.dev/v1
    kind: ContainerSource
    metadata:
      name: test-heartbeats
    spec:
      template:
        spec:
          containers:
            - image: path/to/image/registry/node-knative-heartbeat-source:v1
              name: heartbeats
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: event-display
    ```

4. Check the logs of the event display service. You will see a new message is pushed every second:

    ```bash
    $ kubectl logs -l serving.knative.dev/service=event-display -c user-container

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

5. Optional: If you are interested in seeing what is injected into the event source as a `K_SINK`, you can check the logs:

    ```bash
    $ kubectl logs test-heartbeats-deployment-7575c888c7-85w5t

    Sink URL is http://event-display.default.svc.cluster.local
    Emitting event #1
    Emitting event #2
    Event posted successfully
    Event posted successfully
    ```

## Using SinkBinding

SinkBinding does not create any containers. It injects the sink information to an already existing Kubernetes resources. This is a flexible approach as you can use any Kubernetes PodSpecable object as an event source, such as Deployment, Job, or Knative services.

### Procedure

1. Create an event display service:

    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: event-display
    spec:
      template:
        spec:
          containers:
            - image: docker.io/aliok/event_display-864884f202126ec3150c5fcef437d90c@sha256:93cb4dcda8fee80a1f68662ae6bf20301471b046ede628f3c3f94f39752fbe08
    ```

2. Create a Kubernetes deployment that runs the event source:

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

3. Because the SinkBinding has not yet been created, you will see an error message, because the `K_SINK` environment variable is not yet injected:

    ```bash
    $ kubectl logs node-heartbeats-deployment-9ffbb644b-llkzk

    Sink URL is undefined
    Emitting event #1
    Error during event post
    TypeError [ERR_INVALID_ARG_TYPE]: The "url" argument must be of type string. Received type undefined
    ```

4. Create the SinkBinding object:

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

    You will see the pods are recreated and this time the `K_SINK` environment variable is injected.

    Also note that since the `replicas` is set to 2, there will be 2 pods that are posting events to the sink.

    ```bash
    $ kubectl logs event-display-dpplv-deployment-67c9949cf9-bvjvk -c user-container

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
