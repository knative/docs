# Covert Kubernetes Deployment to Knative Service

Learn how to covert Kubernetes Deployment to Knative Service.

## Determining if your workload is a good fit for Knative

In general, if your Kubernetes workload is a good fit for Knative, you should be able to remove a lot of your manifest to create a Knative Service.

There are three aspects you need to consider:

- All work done is triggered by HTTP
- The container is stateless (all state is stored elsewhere or can be re-created)
- Uses only Secret and ConfigMap volumes

## Example conversion

The following will use an Kubernetes Nginx Deployment and Service, and covert it to Knative Service.

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
