# Using a ContainerSource

A ContainerSource creates a container for your event source image and manages this container. The sink URL to post the events is made available to the application through the `K_SINK` environment variable provided by the ContainerSource.

## Prerequisites

To implement your own event source by using a ContainerSource, you will need:

- An image of the event source that you want to create.
<!--TODO: which sample images do we provide, why only javascript? How are they provided and maintained?-->
- Optional. An event sink where CloudEvents can be sent to from the event source that you create.
- Knative Eventing installed on your cluster.

## Procedure

1. Create a ContainerSource object:

    ```yaml
    apiVersion: sources.knative.dev/v1
    kind: ContainerSource
    metadata:
      name: <container_source_name>
    spec:
      template:
        spec:
          containers:
            - image: <event_source_image>
              name: <container_name>
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: example-service
    ```

    where;

    - `<container_source_name>` is the name of the ContainerSource that you want to create.
    - `<event_source_image>` is the URI of the image that you want to use to create your event source.
    - `<container_name>` is the container name.
    - Optional. `sink` contains information about the sink that you want to connect to your event source. In the previous example, the sink is a Knative Service named `example-service`.

    !!! tip
        See the documentation on [Creating a ContainerSource object](../../../../developer/eventing/sources/containersource) for more information.


1. Optional. If you want to view the contents of the `K_SINK` that are injected into the event source, you can check the event source logs by running the command:

    ```bash
    $ kubectl logs test-heartbeats-deployment-7575c888c7-85w5t
    ```
    <!--QUESTION: Where does this test-heartbeats thing come from, how would someone get this ID/name in this format for their own source? What component are we checking logs for?--->
    **Example output:**
    ```bash
    Sink URL is http://event-display.default.svc.cluster.local
    Emitting event #1
    Emitting event #2
    Event posted successfully
    Event posted successfully
    ```

## Example of an event source image written in JavaScript

The following example event source emits an event to the sink every 1000 milliseconds, and uses _Binary_ mode for CloudEvents.

Binary mode is used in most cases because:

- Binary allows quicker serialization and deserialization.
- Binary works better with CloudEvent-aware proxies, such as Knative Channels, and can simply check the header instead of parsing the entire payload.

To employ structured code instead for the example, you can change `let binding = new v1.BinaryHTTPEmitter(config);` to `let binding = new v1.StructuredHTTPEmitter(config);`.

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
