---
title: "SinkBinding alternative to ContainerSource"
weight: 20
type: "docs"
aliases:
   - /docs/eventing/sinkbinding.md
---

`ContainerSource` can be seen as the combination of
`SinkBinding`+`Deployment`. In fact, that
is exactly how it's implemented!

In YAML, these two options are equivalent:

1. `ContainerSource` that emits events to a `Knative Service`:

    ```yaml
    apiVersion: sources.knative.dev/v1alpha2
    kind: ContainerSource
    metadata:
      name: urbanobservatory-event-source
    spec:
      template:
        spec:
          containers:
          - image: quay.io/openshift-knative/knative-eventing-sources-websocketsource:latest
            args:
            - '--source=wss://api.usb.urbanobservatory.ac.uk/stream'
            - '--eventType=my.custom.event'
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: wss-event-display
    ```

2. `SinkBinding` + `Deployment`. Something like the following:

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

    Here the `SinkBinding`'s `subject` references to a Kubernetes
    `Deployment`, that is labeled with `app: wss`. This is done with
    the `subject.selector` field, which is a standard Kubernetes
    Label Selector object. Note that you could explicitly set a
    `Deployment` name and namespace in `subject` (i.e., `subject.name`
    and `subject.namespace`) instead of using `subject.selector`.
    The YAML for the `Deployment` looks like:

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

    The `Deployment` is a standard Kubernetes Deployment, like you might have used before. However, the important part
    here is that it has the `app: wss` label, which is needed by the above `SinkBinding` in order to _bind_ the
    two components together.

In both cases, the `image` is required to understand
the semantics of the `K_SINK` environment variable, which holds
the destination endpoint for sending CloudEvents.

Running any of the above examples will give a log similar to:

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

## When to use SinkBinding?

From the above options, `ContainerSource` is probably the less
verbose.
However, the true power of `SinkBinding` comes from the fact that
it can work not just with `Deployments`
but with **any** PodSpecable (e.g., `StatefulSet`, `ReplicateSet`,
`DaemonSet`, `Knative Service`, etc.).
If you do need that flexibility, we highly recommend you to use `SinkBinding`.
