---
title: "Sequence terminal"
linkTitle: "Create additional events"
weight: 20
type: "docs"
markup: "mmark"
---

We are going to create the following logical configuration. We create a
CronJobSource, feeding events to a [`Sequence`](../../../sequence.md). Sequence
can then do either external work, or out of band create additional events.

![Logical Configuration](./sequence-terminal.png)

## Prerequisites

For this example, we'll assume you have set up an `InMemoryChannel` as well as
Knative Serving (for our functions). The examples use `default` namespace,
again, if you want to deploy to another Namespace, you will need to modify the
examples to reflect this.

If you want to use different type of `Channel`, you will have to modify the
`Sequence.Spec.ChannelTemplate` to create the appropriate Channel resources.

## Setup

### Create the Knative Services

First create the 3 steps that will be referenced in the Steps.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: first
spec:
  template:
    spec:
      containers:
        - image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:2656f39a7fcb6afd9fc79e7a4e215d14d651dc674f38020d1d18c6f04b220700
          env:
            - name: STEP
              value: "0"

---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: second
spec:
  template:
    spec:
      containers:
        - image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:2656f39a7fcb6afd9fc79e7a4e215d14d651dc674f38020d1d18c6f04b220700
          env:
            - name: STEP
              value: "1"
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: third
spec:
  template:
    spec:
      containers:
        - image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:2656f39a7fcb6afd9fc79e7a4e215d14d651dc674f38020d1d18c6f04b220700
          env:
            - name: STEP
              value: "2"
---

```

```shell
kubectl -n default create -f ./steps.yaml
```

### Create the Sequence

The `sequence.yaml` file contains the specifications for creating the Sequence.
If you are using a different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel.

```yaml
apiVersion: messaging.knative.dev/v1alpha1
kind: Sequence
metadata:
  name: sequence
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: InMemoryChannel
  steps:
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: first
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: second
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: third
```

Change `default` below to create the `Sequence` in the Namespace where you want
the resources to be created.

```shell
kubectl -n default create -f ./sequence.yaml
```

### Create the CronJobSource targeting the Sequence

This will create a CronJobSource which will send a CloudEvent with {"message":
"Hello world!"} as the data payload every 2 minutes.

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: cronjob-source
spec:
  schedule: "*/2 * * * *"
  data: '{"message": "Hello world!"}'
  sink:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: Sequence
    name: sequence
```

Here, if you are using different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel.

```shell
kubectl -n default create -f ./cron-source.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the event-display
pods. Note that since we set the `CronJobSource` to emit every 2 minutes, it
might take some time for the events to show up in the logs.

```shell
kubectl -n default get pods
```

Let's look at the logs for the first `Step` in the `Sequence`:

```shell
kubectl -n default logs -l serving.knative.dev/service=first -c user-container
Got Event Context: Context Attributes,
  specversion: 0.2
  type: dev.knative.cronjob.event
  source: /apis/v1/namespaces/default/cronjobsources/cronjob-source
  id: 2fdf69ec-0480-463a-92fb-8d1259550f32
  time: 2019-06-18T14:38:00.000379084Z
  contenttype: application/json
Extensions,
  knativehistory: sequence-kn-sequence-0-kn-channel.default.svc.cluster.local
2019/06/18 14:38:14 http: superfluous response.WriteHeader call from github.com/vaikas-google/transformer/vendor/github.com/cloudevents/sdk-go/pkg/cloudevents/transport/http.(*Transport).ServeHTTP (transport.go:446)

Got Data: &{Sequence:0 Message:Hello world!}
Got Transport Context: Transport Context,
  URI: /
  Host: first.default.svc.cluster.local
  Method: POST
  Header:
    X-Request-Id: 9b51bcaa-10bc-97a5-a288-dde9b97f6e1e
    Content-Length: 26
    K-Proxy-Request: activator
    X-Forwarded-For: 10.16.3.77, 127.0.0.1, 127.0.0.1
    X-Forwarded-Proto: http
    Ce-Knativehistory: sequence-kn-sequence-0-kn-channel.default.svc.cluster.local
    X-B3-Spanid: 42bcd58bd1ea8191
    X-B3-Parentspanid: c63efd989dcf5dc5
    X-B3-Sampled: 0
    X-B3-Traceid: 4a1da6622ecbbdea0c75ae32e065cfcb

----------------------------
```

Then we can look at the output of the second Step in the `Sequence`:

```shell
kubectl -n default logs -l serving.knative.dev/service=second -c user-container
Got Event Context: Context Attributes,
  cloudEventsVersion: 0.1
  eventType: samples.http.mod3
  source: /transformer/0
  eventID: 5a9ec173-5224-41a2-9c83-50786651bcd5
  eventTime: 2019-06-18T14:38:14.657008072Z
  contentType: application/json

Got Data: &{Sequence:0 Message:Hello world! - Handled by 0}
Got Transport Context: Transport Context,
  URI: /
  Host: second.default.svc.cluster.local
  Method: POST
  Header:
    X-Forwarded-For: 10.16.3.77, 127.0.0.1, 127.0.0.1
    X-Forwarded-Proto: http
    Content-Length: 48
    X-B3-Sampled: 0
    Ce-Knativehistory: sequence-kn-sequence-1-kn-channel.default.svc.cluster.local
    X-B3-Parentspanid: 4fba491a605b2391
    K-Proxy-Request: activator
    X-B3-Spanid: 56e4150c4e1d679b
    X-B3-Traceid: fb468aa8ec035a66153ce3f4929aa2fe
    X-Request-Id: d60e7109-3853-9ca1-83e2-c70f8cbfbb93

----------------------------
```

And you can see that the initial Cron Source message ("Hello World!") has now
been modified by the first step in the Sequence to include " - Handled by 0".
Exciting :)

Then we can look at the output of the last Step in the `Sequence`:

```shell
kubectl -n default logs -l serving.knative.dev/service=third -c user-container
Got Event Context: Context Attributes,
  cloudEventsVersion: 0.1
  eventType: samples.http.mod3
  source: /transformer/1
  eventID: 5747fb77-66a2-4e78-944b-43192aa879fb
  eventTime: 2019-06-18T14:38:32.688345694Z
  contentType: application/json

Got Data: &{Sequence:0 Message:Hello world! - Handled by 0 - Handled by 1}
Got Transport Context: Transport Context,
  URI: /
  Host: third.default.svc.cluster.local
  Method: POST
  Header:
    X-B3-Sampled: 0
    X-B3-Traceid: 64a9c48c219375476ffcdd5eb14ec6e0
    X-Forwarded-For: 10.16.3.77, 127.0.0.1, 127.0.0.1
    X-Forwarded-Proto: http
    Ce-Knativehistory: sequence-kn-sequence-2-kn-channel.default.svc.cluster.local
    K-Proxy-Request: activator
    X-Request-Id: 505ff620-2822-9e7d-8855-53d02a2e36e2
    Content-Length: 63
    X-B3-Parentspanid: 9e822f378ead293c
    X-B3-Spanid: a56ee81909c767e6

----------------------------
```

And as expected it's now been handled by both the first and second Step as
reflected by the Message being now: "Hello world! - Handled by 0 - Handled by 1"
