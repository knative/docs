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

## Additional resources

* For more information requests and limits for Kubernetes resources, see [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).
