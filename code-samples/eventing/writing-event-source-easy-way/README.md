# Writing an event source using JavaScript

This tutorial provides instructions to build an event source in JavaScript and implement it with a ContainerSource or SinkBinding.

ContainerSource and SinkBinding both work by injecting environment variables to an application. Injected environment variables at minimum contain the URL of a sink that receives events.

## Bootstrapping

Create the project and add the dependencies:

```bash
npm init -y
npm install cloudevents got --save
```

## Using ContainerSource

A ContainerSource creates a container for your event source image and manages this container.

The sink URL where events are posted will be made available to the application through the `K_SINK` environment variable by the ContainerSource.

### Example

The following example event source emits an event to the sink every second:

```javascript
// File - index.js
const { CloudEvent, Emitter, emitterFor, httpTransport } = require('cloudevents');

const K_SINK = process.env['K_SINK'];
K_SINK || logExit('Error: K_SINK Environment variable is not defined');
console.log(`Sink URL is ${K_SINK}`);

const source = 'urn:event:from:heartbeat/example';
const type = 'heartbeat.example';

let eventIndex = 0;
setInterval(() => {
  console.log(`Emitting event # ${++eventIndex}`);

  // Create a new CloudEvent each second
  const event = new CloudEvent({ source, type, data: {'hello': `World # ${eventIndex}`} });

  // Emits the 'cloudevent' Node.js event application-wide
  event.emit();
}, 1000);

// Create a function that can post an event
const emit = emitterFor(httpTransport(K_SINK));

// Send the CloudEvent any time a Node.js 'cloudevent' event is emitted
Emitter.on('cloudevent', emit);

registerGracefulExit();

function registerGracefulExit() {
  process.on('exit', logExit);
  //catches ctrl+c event
  process.on('SIGINT', logExit);
  process.on('SIGTERM', logExit);
  // catches 'kill pid' (for example: nodemon restart)
  process.on('SIGUSR1', logExit);
  process.on('SIGUSR2', logExit);
}

function logExit(message = 'Exiting...') {
  // Handle graceful exit
  process.stdout.write(`${message}\n`);
  process.exit();
}
```

```dockerfile
# File - Dockerfile

FROM node:16
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8080
CMD [ "node", "index.js" ]
```

### Procedure

Before publishing the ContainerSource, you must build the application
image, and push it to a container registry that your cluster can access.

1. Build and push the image:

    ```bash
    export REGISTRY=docker.io/myregistry
    docker build . -t $REGISTRY/node-heartbeat-source:v1
    docker push $REGISTRY/node-heartbeat-source:v1
    ```

1. Create the event display service which logs any CloudEvents posted to it:

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

1. Create the ContainerSource object:

    ```yaml
    apiVersion: sources.knative.dev/v1
    kind: ContainerSource
    metadata:
      name: heartbeat-source
    spec:
      template:
        spec:
          containers:
            - image: docker.io/myregistry/node-heartbeat-source:v1
              name: heartbeats
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: event-display
    ```

1. Check the logs of the `event-display` Service. You can observe that a new message is pushed every second:

    ```bash
    $ kubectl logs -l serving.knative.dev/service=event-display -c user-container
    ```

    ```bash
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: heartbeat.example
      source: urn:event:from:heartbeat/example
      id: 47e69d34-def7-449b-8382-3652495f9163
      datacontenttype: application/json
    Data,
      {
        "hello": "World 1"
      }
    ```

1. Optional: If you are interested in seeing what is injected into the event source as a `K_SINK`, you can check the logs:

    ```bash
    $ kubectl logs heartbeat-source-7575c888c7-85w5t
    ```

    ```bash
    Sink URL is http://event-display.default.svc.cluster.local
    Emitting event #1
    Emitting event #2
    Event posted successfully
    Event posted successfully
    ```

## Using SinkBinding

SinkBinding does not create any containers. It injects the sink information to an already existing Kubernetes resources. This is a flexible approach as you can use any Kubernetes PodSpecable object as an event source, such as Deployment, Job, or Knative services.

### Procedure

1. Create the `event-display` service:

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

1. Create a Kubernetes Deployment that runs the event source:

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
            image: docker.io/myregistry/node-heartbeat-source:v1
            ports:
            - containerPort: 8080
    ```

1. Because the SinkBinding has not yet been created, you will see an error message, because the `K_SINK` environment variable is not yet injected:

    ```bash
    $ kubectl logs node-heartbeats-deployment-9ffbb644b-llkzk
    ```

    ```bash
    Sink URL is undefined
    Emitting event #1
    Error during event post
    TypeError [ERR_INVALID_ARG_TYPE]: The "url" argument must be of type string. Received type undefined
    ```

1. Create the SinkBinding object:

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

    Observe that the Pods are recreated and this time the `K_SINK` environment variable is injected.

    Since the `replicas` is set to 2, there are 2 pods that are posting events to the sink:

    ```bash
    $ kubectl logs event-display-dpplv-deployment-67c9949cf9-bvjvk -c user-container
    ```

    ```bash
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: heartbeat.example
      source: urn:event:from:heartbeat/example
      id: 47e69d34-def7-449b-8382-3652495f9163
      datacontenttype: application/json
    Data,
      {
        "hello": "World 1"
      }

    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: heartbeat.example
      source: urn:event:from:heartbeat/example
      id: 47e69d34-def7-449b-8382-3652495f9163
      datacontenttype: application/json
    Data,
      {
        "hello": "World 1"
      }
    ```
