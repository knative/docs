---
title: "Migrating from ContainerSource to SinkBinding"
weight: 20
type: "docs"
aliases:
   - /docs/eventing/ping.md
---

The deprecated `ContainerSource` should be converted to a `SinkBinding`.

The YAML file for a `ContainerSource` that emits events to a Knative Serving service will look similar to this:

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: ContainerSource
metadata:
  name: urbanobservatory-event-source
spec:
  image: quay.io/openshift-knative/knative-eventing-sources-websocketsource:latest
  args:
    - '--source=wss://api.usb.urbanobservatory.ac.uk/stream'
    - '--eventType=my.custom.event'
  sink:
    apiVersion: serving.knative.dev/v1
    kind: Service
    name: wss-event-display
```

The referenced image of the `ContainerSource` needed an "sink" argument, [see](https://knative.dev/docs/eventing/#containersource) for details.

To migrate this source to a `SinkBinding`, a few steps are required. Instead of using a `ContainerSource`,
you need to create a `SinkBinding`, like:

```yaml
apiVersion: sources.knative.dev/v1alpha2
kind: SinkBinding
metadata:
  name: bind-wss
spec:
  subject:
    apiVersion: apps/v1
    kind: Deployment
    selector:
      matchLabels:
        app: wss
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: wss-event-display
```

Here the `SinkBinding`'s `subject` references to a Kubernetes `Deployment`, that is labeled with `app: wss`. The YAML for the `Deployment`
looks like:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wss
  labels:
    app: wss
spec:
  selector:
    matchLabels:
      app: wss
  template:
    metadata:
      labels:
        app: wss
    spec:
      containers:
        - image: quay.io/openshift-knative/knative-eventing-sources-websocketsource:latest
          name: wss
          args:
            - '--source=wss://api.usb.urbanobservatory.ac.uk/stream'
            - '--eventType=my.custom.event'
```

The `Deployment` is a standard Kubernetes Deployment, like you might have used before. However, the important part here is that it has the `app: wss`
label, which is needed by the above `SinkBinding` in order to _bind_ the two components together.

The `image` that is used by the `Deployment` is required to understands the semantics of the `K_SINK` environment variable, holding the endpoint to which to send cloud events. The `K_SINK` environment variable is part of the `SinkBinding`'s runtime contract of the [referenced container image](https://knative.dev/docs/reference/eventing/#sources.knative.dev/v1alpha2.SinkBinding).

Running the above example will give a log like:

```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: my.custom.event
  source: wss://api.usb.urbanobservatory.ac.uk/stream
  id: 3029a2f2-3ce1-48c0-9ed3-37d7ad88d0ef
  time: 2020-03-05T13:46:15.329595422Z
Data,
  {"signal":2,"data":{"brokerage":{"broker":{"id":"BMS-USB-5-JACE","meta":{"protocol":"BACNET","building":"Urban Sciences Building","buildingFloor":"5"}},"id":"Drivers.L6_C3_Electric_Meters.C3_Mechcanical_Plant.points.C3_HP_Current_L1","meta":{}},"entity":{"name":"Urban Sciences Building: Floor 5","meta":{"building":"Urban Sciences Building","buildingFloor":"5"}},"feed":{"metric":"C3 HP Current L1","meta":{}},"timeseries":{"unit":"no units","value":{"time":"2020-03-05T13:45:51.468Z","timeAccuracy":8.754,"data":0.47110211849212646,"type":"Real"}}},"recipients":0}
```
