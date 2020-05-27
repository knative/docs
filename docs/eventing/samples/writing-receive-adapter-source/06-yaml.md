---
title: "Publishing to your Kubernetes cluster"
linkTitle: "Publishing to your cluster"
weight: 60
type: "docs"
---

## Run the sample source locally

Start a minikube cluster.

_If you already have a Kubernetes cluster running, you can skip this step. The
cluster must be 1.15+_

```sh
minikube start
```

Setup `ko` to use the minikube docker instance and local registry
```sh
eval $(minikube docker-env)
export KO_DOCKER_REPO=ko.local
```

Apply the CRD and configuration yaml
```sh
ko apply -f config
```

Once the `sample-source-controller-manager` is running in the `knative-samples` namespace, you can
apply the `example.yaml` to connect our `sample-source` every `10s` directly to a `ksvc`.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
  namespace: knative-samples
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display@sha256:526fdb25f5c26d25506e88e86f22b122b5d56be7de31091bcb1a46e5e8e50615
---
apiVersion: samples.knative.dev/v1alpha1
kind: SampleSource
metadata:
  name: sample-source
  namespace: knative-samples
spec:
  interval: "10s"
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
```
```sh
ko apply -f example.yaml
```

Once reconciled, you can confirm the `ksvc` is outputting valid cloudevents every `10s` to align with our specified interval.

```sh
% k logs -n knative-samples event-display-zrjgm-deployment-84f6bfdfc6-2jc67 user-container -f
```
```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.sample
  source: http://sample.knative.dev/heartbeat-source
  id: d4619592-363e-4a41-82d1-b1586c390e24
  time: 2019-12-17T01:31:10.795588888Z
  datacontenttype: application/json
Data,
  {
    "Sequence": 0,
    "Heartbeat": "10s"
  }
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.sample
  source: http://sample.knative.dev/heartbeat-source
  id: db2edad0-06bc-4234-b9e1-7ea3955841d6
  time: 2019-12-17T01:31:20.825969504Z
  datacontenttype: application/json
Data,
  {
    "Sequence": 1,
    "Heartbeat": "10s"
  }
```
