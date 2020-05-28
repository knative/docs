# Introduction

As stated in [tutorial on writing a Source with a Receive Adapter](../writing-receive-adapter-source/README.md), there are multiple ways to
create event sources. The way in that tutorial is to create an independent event source that has its own CRD.

This tutorial provides a simpler mechanism to build an event source in Javascript and use it with
[ContainerSource](../../../eventing/sources/README.md#meta-sources) and / or the [SinkBinding](../../../eventing/sources/README.md#meta-sources).

[ContainerSource](../../../eventing/sources/README.md#meta-sources) is an easy way to turn any dispatcher container into an Event Source.
Similarly, another option is using [SinkBinding](../../../eventing/sources/README.md#meta-sources)
which provides a framework for injecting environment variables into any Kubernetes resource which has a `spec.template` that looks like a Pod (aka PodSpecable).

SinkBinding is a newer concept and it should be preferred over ContainerSource.

Code for this tutorial is available [here](https://github.com/knative/docs/tree/master/docs/eventing/samples/writing-event-source-easy-way).

# Bootstrapping

Create the project and add the dependencies:
```bash
npm init
npm install cloudevents-sdk --save
```

## Making use of ContainerSource

`ContainerSource` and `SinkBinding` both work by injecting environment variables to an application.
Injected environment variables at minimum contain the URL of a sink that will receive events.

Following example emits an event to the sink every 1000 milliseconds.
The sink URL to post the events will be made available to the application via the `K_SINK` environment variable by `ContainerSource`.

```javascript
// File - index.js

const v1 = require("cloudevents-sdk/v1");

let sinkUrl = process.env['K_SINK'];

console.log("Sink URL is " + sinkUrl);

let config = {
    method: "POST",
    url: sinkUrl
};

// The binding instance
let binding = new v1.BinaryHTTPEmitter(config);

let eventIndex = 0;
setInterval(function () {
    console.log("Emitting event #" + ++eventIndex);

    // create the event
    let myevent = v1.event()
        .id('your-event-id')
        .type("your.event.source.type")
        .source("urn:event:from:your-api/resource/123")
        .dataContentType("application/json")
        .data({"hello": "World " + eventIndex});

    // Emit the event
    binding.emit(myevent)
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

Build and push the image:
```bash
docker build . -t path/to/image/registry/node-knative-heartbeat-source:v1
docker push path/to/image/registry/node-knative-heartbeat-source:v1
```

Create the event display service which simply logs any cloudevents posted to it.
```bash
cat <<EOS |kubectl apply -f -
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - image: docker.io/aliok/event_display-864884f202126ec3150c5fcef437d90c@sha256:93cb4dcda8fee80a1f68662ae6bf20301471b046ede628f3c3f94f39752fbe08
EOS
```

Create the `ContainerSource`:
```bash
cat <<EOS |kubectl apply -f -
---
apiVersion: sources.knative.dev/v1alpha2
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
EOS
```

Check the logs of the event display service. You will see a new message is pushed every second:
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

If you are interested in seeing what is injected into the event source as a `K_SINK`, you can check the logs:
```bash
$ kubectl logs test-heartbeats-deployment-7575c888c7-85w5t

Sink URL is http://event-display.default.svc.cluster.local
Emitting event #1
Emitting event #2
Event posted successfully
Event posted successfully
```

Please note that the example code above is using _Binary_ mode for CloudEvents.
Simply change
```javascript
let binding = new v1.BinaryHTTPEmitter(config);
```
with
```javascript
let binding = new v1.StructuredHTTPEmitter(config);
```
to employ structured mode.

However, binary mode should be used in most of the cases as:
- It is faster in terms of serialization and deserialization
- It works better with cloudevents-aware proxies (like Knative Channels) can simply check the header instead of parsing the payload

## Making use of SinkBinding

`SinkBinding` is a more powerful way of making any Kubernetes resource an event source.

`ContainerSource` will create the container for your event source's image and it will be `ContainerSource` responsibility to manage the container.

`SinkBinding` though, will not create any containers. It will inject the sink information to the already existing Kubernetes resources.
This is a more flexible approach as you can use any Kubernetes `PodSpecable` as an event source, such as `Deployment`, `Job`, `Knative Service`, `DaemonSet` etc.

We don't need any code changes in our source for making it work with `SinkBinding`.

Create the event display as in the section before:
```bash
cat <<EOS |kubectl apply -f -
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - image: docker.io/aliok/event_display-864884f202126ec3150c5fcef437d90c@sha256:93cb4dcda8fee80a1f68662ae6bf20301471b046ede628f3c3f94f39752fbe08
EOS
```

Create a Kubernetes deployment that runs the event source:
```bash
cat <<EOS |kubectl apply -f -
---
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
EOS
```

As the `SinkBinding` is not created yet, `K_SINK` environment variable is not yet injected and the event source will complain about that.

```
$ kubectl logs node-heartbeats-deployment-9ffbb644b-llkzk

Sink URL is undefined
Emitting event #1
Error during event post
TypeError [ERR_INVALID_ARG_TYPE]: The "url" argument must be of type string. Received type undefined
```

Create the `SinkBinding`:
```bash
cat <<EOS |kubectl apply -f -
---
apiVersion: sources.knative.dev/v1alpha1
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
EOS
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
