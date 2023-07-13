# Configure resource requests and limits

You can configure resource limits and requests, specifically for CPU and memory, for individual Knative services.

The following example shows how you can set the `requests` and `limits` fields for a service:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: example-service
  namespace: default
spec:
  template:
    spec:
      containers:
        - image: docker.io/user/example-app
          resources:
            requests:
              cpu: 100m
              memory: 640M
            limits:
              cpu: 1
```

## Configure Queue Proxy resources

In order to set the Queue Proxy resource requests and limits you can either
set them globally in the [deployment config map](../configuration/deployment.md) or you can set them at the service level using the corresponding annotations targeting cpu, memory and ephemeral-storage resource types. The above example becomes:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: example-service
  namespace: default
  annotations:
    queue.sidecar.serving.knative.dev/cpu-resource-request: "1"
    queue.sidecar.serving.knative.dev/cpu-resource-limit: "2"
    queue.sidecar.serving.knative.dev/memory-resource-request: "1Gi"
    queue.sidecar.serving.knative.dev/memory-resource-limit: "2Gi"
    queue.sidecar.serving.knative.dev/ephemeral-storage-resource-request: "400Mi"
    queue.sidecar.serving.knative.dev/ephemeral-storage-resource-limit: "450Mi"
spec:
  template:
    spec:
...
```

Alternatively, you could use a special annotation `queue.sidecar.serving.knative.dev/resource-percentage` that calculates the Queue Proxy resources as a percentage of the application's container.
In this case there are min, max boundaries applied to the cpu and memory resource requirements:


| Resource Requirements                               | Min     | Max     |
|-------------------------------------------|---------|---------|
| Cpu  Request   |  25m    |   100m  |
| Cpu Limit |  40m    |   500m  |
| Memory  Request   |  50Mi    |   200Mi  |
| Memory Limit |  200Mi    |   500Mi  |


!!! note
    If the user simultaneously sets a percentage annotation and a specific resource value via the corresponding resource annotation then the latter takes precedence.

!!! warning
    The `queue.sidecar.serving.knative.dev/resource-percentage` annotation is now deprecated and will be removed in future versions.

### Additional resources

* For more information requests and limits for Kubernetes resources, see [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).
