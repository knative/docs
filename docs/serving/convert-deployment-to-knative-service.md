# Converting a Kubernetes Deployment to a Knative Service

This topic shows how to convert a Kubernetes Deployment to a Knative Service.

## Benefits

Converting to a Knative Service has the following benefits:

- Reduces the footprint of the service instance because the instance scales to 0 when it becomes idle.
- Improves performance due to built-in autoscaling for the Knative Service.

## Determine if your workload is a good fit for Knative

In general, if your Kubernetes workload is a good fit for Knative, you can remove a lot of your manifest to create a Knative Service.

There are three aspects you need to consider:

- All work done is triggered by HTTP.
- The container is stateless. All state is stored elsewhere or can be re-created.
- Your workload uses only Secret and ConfigMap volumes.

## Example conversion

The following example shows a [Kubernetes Nginx Deployment and Service](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/), and shows how it converts to a Knative Service.

### Kubernetes Nginx Deployment and Service

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx

```

### Knative Service

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-nginx
spec:
  template:
    spec:
      containers:
      - image: nginx
        ports:
        - containerPort: 80
```
