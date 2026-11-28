---
audience: developer
components:
  - serving
function: how-to
---

# Converting a Kubernetes Deployment to a Knative Service

This topic shows how to convert a Kubernetes Deployment to a Knative Service.

## Benefits

Converting to a Knative Service has the following benefits:

- Reduces the footprint of the service instance because the instance scales to 0 when it becomes idle.
- Improves performance due to built-in autoscaling for the Knative Service.

## Workload fit { #determine-if-your-workload-is-a-good-fit-for-knative }

In general, if your Kubernetes workload is a good fit for Knative, you can remove a lot of your manifest to create a Knative Service.

There are three aspects you need to consider:

- All work is triggered by HTTP (or gRPC/WebSockets over HTTP).
- The container is stateless — persistent state lives outside the pod, or uses
  a [supported volume type](services/storage.md) (such as ConfigMaps, Secrets,
  EmptyDir, or enabled PersistentVolumeClaims).

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

To migrate safely without disturbing the existing Deployment, deploy the
Knative Service under a distinct name first (for example `my-nginx-knative`),
verify it responds as expected, and cut traffic over before deleting the old
Deployment and Service:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-nginx-knative
spec:
  template:
    spec:
      containers:
      - image: nginx
        ports:
        - containerPort: 80
```

Apply and verify:

```bash
kubectl apply -f my-nginx-knative.yaml
kubectl wait kservice/my-nginx-knative --for=condition=Ready --timeout=120s
curl "$(kubectl get kservice my-nginx-knative -o jsonpath='{.status.url}')"
```
