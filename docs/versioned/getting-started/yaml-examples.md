---
audience: developer
components:
  - serving
  - eventing
function: reference
---

# Quickstart YAML examples

These are declarative equivalents of the resources used in the [Quickstart tutorial](README.md). The tutorial's chosen route uses `kn`; these examples help you inspect the corresponding API objects. Do not apply both forms as separate exercises. Use the same cluster and `default` namespace.

## Deploy hello

Save as `hello.yaml` and apply with `kubectl apply -f hello.yaml`:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    spec:
      containers:
        - image: ghcr.io/knative/helloworld-go:latest
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "World"
```

`kubectl get ksvc hello` reports readiness and the URL. Without `kn`, obtain the URL with `kubectl get ksvc hello -o jsonpath='{.status.url}'`.

## Update hello and split traffic

To create the second Revision, change `TARGET` to `Knative` in `hello.yaml` and apply it again. Before updating, note the original Revision name from `kubectl get ksvc hello -o jsonpath='{.status.latestReadyRevisionName}'`.

To split traffic, add this field under `spec`, alongside `template`, and apply the file again. Replace `ORIGINAL_REVISION_NAME` with the name you recorded:

```yaml
traffic:
  - latestRevision: true
    percent: 50
  - revisionName: ORIGINAL_REVISION_NAME
    percent: 50
```

Inspect the result with `kubectl get ksvc hello -o yaml` and `kubectl get revisions`.

## Create the CloudEvents Player

Save as `cloudevents-player.yaml` and apply with `kubectl apply -f cloudevents-player.yaml`:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: cloudevents-player
spec:
  template:
    spec:
      containers:
        - image: quay.io/ruben/cloudevents-player:latest
```

The original YAML example used a minimum scale of one, unlike its CLI counterpart. If you want to keep a pod running for experimentation, add the following under `spec.template` (this is **not** required by the chosen CLI route):

```yaml
metadata:
  annotations:
    autoscaling.knative.dev/min-scale: "1"
```

## Bind the Player to the Broker

Save as `cloudevents-player-binding.yaml` and apply with `kubectl apply -f cloudevents-player-binding.yaml`:

```yaml
apiVersion: sources.knative.dev/v1
kind: SinkBinding
metadata:
  name: ce-player-binding
spec:
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: example-broker
  subject:
    apiVersion: serving.knative.dev/v1
    kind: Service
    name: cloudevents-player
```

Inspect with `kubectl get sinkbinding ce-player-binding`.

## Route Broker events back to the Player

Save as `ce-trigger.yaml` and apply with `kubectl apply -f ce-trigger.yaml`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: cloudevents-trigger
spec:
  broker: example-broker
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: cloudevents-player
```

Inspect with `kubectl get trigger cloudevents-trigger`. No filter is specified, so the Trigger matches all events entering `example-broker`.

**Return to the tutorial:** [Deploy a Service](first-service.md) · [Send an event](first-source.md) · [Receive an event](first-trigger.md)
