---
title: "ContainergSource"
linkTitle: "ContainergSource"
weight: 31
type: "docs"
---

![version](https://img.shields.io/badge/API_Version-v1alpha2-red?style=flat-square)

ContainerSource will start a container image which will generate events under
certain situations and send messages to a sink URI. It also can be an easy way
to support your own event sources in Knative. This guide shows how to configure
ContainerSource as an event source for functions and summarizes guidelines for
creating your own event source as a ContainerSource.

### Prerequisites
- Install [ko](https://github.com/google/ko)
- Set [`KO_DOCKER_REPO`](https://github.com/knative/serving/blob/master/DEVELOPMENT.md#environment-setup)
 (e.g. `gcr.io/[gcloud-project]` or `docker.io/<username>`)
- Authenticated with your `KO_DOCKER_REPO`
- Install [`docker`](https://docs.docker.com/install/)

## Installation

The ContainerSource source type is enabled by default when you install Knative Eventing.

## Example

This example shows how the heartbeats container sends events to a Knative Service.

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
### Creating a namespace

Create a new namespace called `containersource-example` by entering the following
command:

```shell
kubectl create namespace containersource-example
```

### Create a Knative Service

In order to verify `ContainerSource` is working, we will create a Event Display
Service that dumps incoming messages to its log.

```shell
kubectl -n containersource-example apply -f - << EOF
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
EOF
```


### Create a ContainerSource using the heartbeats image

In order to run the heartbeats container as an event source, you have to create
a concrete ContainerSource with specific arguments and environment settings. Be
sure to replace `heartbeats_image_uri` with a valid uri for your heartbeats
image you published in the previous step.
Note that arguments and environment variables are set and will be passed
to the container.

```shell
kubectl -n containersource-example apply -f - << EOF
apiVersion: sources.knative.dev/v1beta1
kind: ContainerSource
metadata:
  name: test-heartbeats
spec:
  template:
    spec:
      containers:
        # This corresponds to a heartbeats image uri you build and publish in the previous step
        # e.g. gcr.io/[gcloud-project]/knative.dev/eventing-contrib/cmd/heartbeats
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
EOF
```

### Verify

View the logs for the `event-display` event consumer by
entering the following command:

```shell
kubectl -n containersource-example logs -l serving.knative.dev/service=event-display -c user-container --since=10m
```

This returns the `Attributes` and `Data` of the events that the ContainerSource sent to the `event-display` Service:

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

### Cleanup

Delete the `containersource-example` namespace and all of its resources from your
cluster by entering the following command:

```shell
kubectl delete namespace containersource-example
```

## Reference Documentation

See the [ContainerSource specification](../../reference/eventing/#sources.knative.dev/v1alpha2.ContainerSource).

## Contact

For any inquiries about this source, please reach out on to the
[Knative users group](https://groups.google.com/forum/#!forum/knative-users).
