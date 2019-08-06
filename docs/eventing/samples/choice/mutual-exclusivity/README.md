In this example, we are going to see how we can create a Choice with mutually
exclusive cases.

This example is the same as the
[multiple cases example](../multiple-cases/README.md) except that we are now
going to rely on the Knative
[switcher](https://github.com/lionelvillard/knative-functions#switcher) function
to provide a soft mutual exclusivity guarantee.

NOTE: this example has to be deployed in the default namespace.

## Prerequisites

Please refer to the sample overview for the [prerequisites](../README.md).

### Create the Knative Services

Let's first create the switcher and transformer services that we will use in our
Choice.

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: me-even-odd-switcher
spec:
  template:
    spec:
      containers:
      - image: villardl/switcher-nodejs:0.1
        env:
        - name: EXPRESSION
          value: Math.round(Date.parse(event.time) / 60000) % 2
        - name: CASES
          value: '[0, 1]'
---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: even-transformer
spec:
  template:
    spec:
      containers:
      - image: villardl/transformer-nodejs
        env:
        - name: TRANSFORMER
          value: |
            ({"message": "we are even!"})

---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: odd-transformer
spec:
  template:
    spec:
      containers:
      - image: villardl/transformer-nodejs
        env:
        - name: TRANSFORMER
          value: |
            ({"message": "this is odd!"})
.
```

```shell
kubectl create -f ./switcher.yaml -f ./transformers.yaml
```

### Create the Choice

The `choice.yaml` file contains the specifications for creating the Choice.

```yaml
apiVersion: messaging.knative.dev/v1alpha1
kind: Choice
metadata:
  name: me-odd-even-choice
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: InMemoryChannel
  cases:
    - filter:
        uri: "http://me-even-odd-switcher.default.svc.cluster.local/0"
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1alpha1
          kind: Service
          name: me-even-transformer
    - filter:
        uri: "http://me-even-odd-switcher.default.svc.cluster.local/1"
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1alpha1
          kind: Service
          name: me-odd-transformer
  reply:
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    name: me-event-display
```

```shell
kubectl create -f ./choice.yaml
```

### Create the CronJobSource targeting the Choice

This will create a CronJobSource which will send a CloudEvent with {"message":
"Even or odd?"} as the data payload every minute.

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: me-cronjob-source
spec:
  schedule: "*/1 * * * *"
  data: '{"message": "Even or odd?"}'
  sink:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: Choice
    name: me-odd-even-choice
```

```shell
kubectl create -f ./cron-source.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the
`me-event-display` pods. Note that since we set the `CronJobSource` to emit
every minute, it might take some time for the events to show up in the logs.

Let's look at the `me-event-display` log:

```shell
kubectl logs -l serving.knative.dev/service=me-event-display --tail=30 -c user-container

☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.3
  type: dev.knative.cronjob.event
  source: /apis/v1/namespaces/default/cronjobsources/me-cronjob-source
  id: 48eea348-8cfd-4aba-9ead-cb024ce16a48
  time: 2019-07-31T20:56:00.000477587Z
  datacontenttype: application/json; charset=utf-8
Extensions,
  knativehistory: me-odd-even-choice-kn-choice-kn-channel.default.svc.cluster.local, me-odd-even-choice-kn-choice-0-kn-channel.default.svc.cluster.local
Data,
  {
    "message": "we are even!"
  }
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.3
  type: dev.knative.cronjob.event
  source: /apis/v1/namespaces/default/cronjobsources/me-cronjob-source
  id: 42717dcf-b194-4b36-a094-3ea20e565ad5
  time: 2019-07-31T20:57:00.000312243Z
  datacontenttype: application/json; charset=utf-8
Extensions,
  knativehistory: me-odd-even-choice-kn-choice-1-kn-channel.default.svc.cluster.local, me-odd-even-choice-kn-choice-kn-channel.default.svc.cluster.local
Data,
  {
    "message": "this is odd!"
  }
```
