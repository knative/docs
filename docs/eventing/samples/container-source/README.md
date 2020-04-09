ContainerSource will start a container image which will generate events under
certain situations and send messages to a sink URI. It also can be an easy way
to support your own event sources in Knative. This guide shows how to configure
ContainerSource as an event source for functions and summarizes guidelines for
creating your own event source as a ContainerSource.

## Create a heartbeats ContainerSource

### Prerequisites

1. Setup [Knative Serving](../../../serving).
1. Setup [Knative Eventing and Sources](../../../eventing).

### Prepare the heartbeats image

Knative [event-sources](https://github.com/knative/eventing-contrib) has a
sample of heartbeats event source. You could clone the source codes by

```
git clone -b "{{< branch >}}" https://github.com/knative/eventing-contrib.git
```

And then build a heartbeats image and publish to your image repo with

```
ko publish knative.dev/eventing-contrib/cmd/heartbeats
```

**Note**: `ko publish` requires:

- [`KO_DOCKER_REPO`](https://github.com/knative/serving/blob/master/DEVELOPMENT.md#environment-setup)
  to be set. (e.g. `gcr.io/[gcloud-project]` or `docker.io/<username>`)
- you to be authenticated with your `KO_DOCKER_REPO`
- [`docker`](https://docs.docker.com/install/) to be installed

### Create a Knative Service

In order to verify `ContainerSource` is working, we will create a Event Display
Service that dumps incoming messages to its log.

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

Use following command to create the service from `service.yaml`:

```shell
kubectl apply --filename service.yaml
```

The status of the created service can be seen using:

```shell
kubectl get ksvc

NAME            URL                                           LATESTCREATED         LATESTREADY           READY   REASON
event-display   http://event-display.default.1.2.3.4.xip.io   event-display-gqjbw   event-display-gqjbw   True    
```

### Create a ContainerSource using the heartbeats image

In order to run the heartbeats container as an event source, you have to create
a concrete ContainerSource with specific arguments and environment settings. Be
sure to replace `heartbeats_image_uri` with a valid uri for your heartbeats
image in your image repo in [heartbeats-source.yaml](./heartbeats-source.yaml)
file. Note that arguments and environment variables are set and will be passed
to the container.

```yaml
apiVersion: sources.knative.dev/v1alpha2
kind: ContainerSource
metadata:
  name: test-heartbeats
spec:
  template:
    spec:
      containers:
        - image: <heartbeats_image_uri>
          name: heartbeats
          args:
            - --period=1
          env:
            - name: POD_NAME
              value: "mypod"
            - name: POD_NAMESPACE
              value: "event-test"
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
```

Use the following command to create the event source from
`heartbeats-source.yaml`:

```shell
kubectl apply --filename heartbeats-source.yaml
```

### Verify

We will verify that the message was sent to the Knative eventing system by
looking at event-display service logs.

```shell
kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
```

You should see log lines showing the request headers and body of the event
message sent by the heartbeats source to the display function:

```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.eventing.samples.heartbeat
  source: https://knative.dev/eventing-contrib/cmd/heartbeats/#event-test/mypod
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

## Create a new event source using ContainerSource

In order to create a new event source using ContainerSource, you will create a
container image at first, and then create a ContainerSource with the image uri
and specify the values of parameters.

### Develop, build and publish a container image

The container image can be developed with any language, build and publish with
any tools you like. Here are some basic guidelines:

- The container image must have a `main` method to start with.
- The `main` method will accept parameters from arguments and environment
  variables.
- Two environments variables will be injected by the `ContainerSource` controller,
`K_SINK` and `K_CE_OVERRIDES`, resolved from `spec.sink` and `spec.ceOverrides` respectively.
- The event messages shall be sent to the sink URI specified in `K_SINK`. The message can be any
  format.
  [CloudEvents](https://github.com/cloudevents/spec/blob/master/spec.md#design-goals)
  format is recommended.

[heartbeats](https://github.com/knative/eventing-contrib/blob/master/cmd/heartbeats/main.go)
event source is a sample for your reference.

### Create the ContainerSource using this container image

When the container image is ready, a YAML file will be used to create a concrete
`ContainerSource`. Use [heartbeats-source.yaml](./heartbeats-source.yaml) as a
sample for reference. [Learn more about the ContainerSource
specification](../../../eventing#containersource).
