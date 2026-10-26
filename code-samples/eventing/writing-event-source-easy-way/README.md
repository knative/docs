# Writing an event source using JavaScript

This tutorial builds an event source in JavaScript and implements it with a
ContainerSource or SinkBinding. Both inject environment variables into an
application, including the URL of a sink that receives events.

## Prerequisites

For the cluster procedures, install Knative Eventing and Knative Serving and
configure `kubectl` to use that cluster. Use a container registry the cluster can
pull from. For SinkBinding in inclusion mode, label your namespace with
`bindings.knative.dev/include=true` before creating the Deployment.

## Get the sample

Use the checked-in files rather than recreating the application from this guide:

```bash
git clone https://github.com/knative/docs.git
cd docs/code-samples/eventing/writing-event-source-easy-way
```

- [index.js](index.js) is the complete event source. It uses the SDK version in
  [package.json](package.json) to emit a new CloudEvent every second, with type
  `heartbeat.example`, source `urn:event:from:heartbeat/example`, a unique ID,
  and data such as `{"hello":"World # 1"}`.
- [Dockerfile](Dockerfile) builds the source image and starts Node directly so it
  can handle termination signals.

`K_SINK` is required; an unset or empty value exits with status 1. This minimal
source does not implement `K_CE_OVERRIDES` and does not retry failed deliveries.

## Using ContainerSource

A ContainerSource creates and manages a container for your event source image.
It makes the sink URL available through `K_SINK`.

### Procedure

1. Build the application image and push it to a registry your cluster can access:

    ```bash
    export REGISTRY=docker.io/myregistry
    docker buildx build --platform linux/arm64,linux/amd64 -t "$REGISTRY/node-heartbeat-source:v1" --push .
    ```

    Use the image you published in the ContainerSource and Deployment manifests
    below.

1. Create the event-display Service, which logs any CloudEvents posted to it:

    ```bash
    kubectl apply -f - <<'EOF'
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
    kubectl wait --for=condition=Ready service.serving.knative.dev/event-display --timeout=180s
    ```

1. Create the ContainerSource:

    ```bash
    kubectl apply -f - <<'EOF'
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
    EOF
    kubectl wait --for=condition=Ready containersource/heartbeat-source --timeout=180s
    ```

1. Check the logs of the `event-display` Service:

    ```bash
    kubectl logs -l serving.knative.dev/service=event-display -c user-container --tail=100
    ```

    A new event arrives every second, for example:

    ```text
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
        "hello": "World # 1"
      }
    ```

1. Optional: inspect the generated Deployment's source logs to see `K_SINK`:

    ```bash
    kubectl get deployments
    # Replace <source-deployment> with the Deployment owned by heartbeat-source.
    kubectl logs deployment/<source-deployment>
    ```

    ```text
    Sink URL is http://event-display.default.svc.cluster.local
    Emitting event # 1
    Emitting event # 2
    ```

## Using SinkBinding

SinkBinding does not create containers. It injects sink information into an
existing Kubernetes PodSpecable resource, such as a Deployment, Job, or Knative
Service.

### Procedure

1. If the event-display Service does not already exist, run its creation and
   readiness commands from the [ContainerSource procedure](#using-containersource).

1. Create the two-replica Deployment, using your published source image:

    ```bash
    kubectl apply -f - <<'EOF'
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
    EOF
    ```

1. Before creating the binding, the Pods exit because `K_SINK` is not injected:

    ```bash
    kubectl logs -l app=node-heartbeats --tail=20
    ```

    ```text
    Error: K_SINK Environment variable is not defined
    ```

1. Create the SinkBinding, which selects the Deployment by its
   `app: node-heartbeats` label:

    ```bash
    kubectl apply -f - <<'EOF'
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
    EOF
    kubectl wait --for=condition=Ready sinkbinding/bind-node-heartbeat --timeout=180s
    kubectl rollout status deployment/node-heartbeats-deployment --timeout=180s
    ```

    The Pods are recreated with `K_SINK` injected. Both replicas post events to
    the sink; the display logs contain two independent heartbeat sequences with
    distinct event IDs:

    ```bash
    kubectl logs -l serving.knative.dev/service=event-display -c user-container --tail=100
    ```

### Cleanup

Delete only the resources you created for this tutorial:

```bash
kubectl delete containersource heartbeat-source --ignore-not-found
kubectl delete sinkbinding bind-node-heartbeat --ignore-not-found
kubectl delete deployment node-heartbeats-deployment --ignore-not-found
kubectl delete kservice event-display --ignore-not-found
```
