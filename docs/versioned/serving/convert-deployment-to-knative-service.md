---
audience: developer
components:
  - serving
function: reference
---

<span id="converting-a-kubernetes-deployment-to-a-knative-service"></span>

# Deployment-to-Service mapping

This reference illustrates how a simple Kubernetes Deployment and Service relate to a Knative Service manifest. It is not a migration or cutover procedure. Preparing or creating a Knative Service does not remove the original resources, preserve their endpoint, or redirect existing clients.

To deploy a prepared manifest as a separate application, follow [Deploy an HTTP container as a Knative Service](services/creating-services.md). That task supplies context/namespace selection, creation, readiness, URL, and request checks. Plan any production cutover, rollback, and retirement of the original workload separately.

## Benefits

A Knative Service delegates Revision creation, routing, and autoscaling to Serving. It can scale idle replicas to zero when the autoscaler and cluster settings allow it; see the [autoscaling overview](autoscaling/README.md). Autoscaling does not guarantee better latency or throughput for a particular workload.

## Determine if your workload is a good fit for Knative

The example assumes an HTTP request-driven container whose local state can be discarded when a replica is replaced. State that must persist is stored elsewhere or can be recreated.

Check the application's listening port, environment, dependencies, and shutdown behavior before adapting it. Not every Deployment field is supported in a Knative revision template; check the [Serving API](reference/serving-api.md) and [feature flags](configuration/feature-flags.md). If the workload mounts volumes, consult [volume support](services/storage.md) rather than assuming its existing PodSpec can be copied unchanged.

## Example conversion

The following example shows a [Kubernetes Nginx Deployment and Service](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/) and an illustrative Knative manifest for the same image and listening port.

| Original field | Knative destination or responsibility |
| --- | --- |
| Deployment `spec.template.spec.containers` | Service `spec.template.spec.containers`, subject to Serving's supported fields |
| Container image and `containerPort: 80` | Retained in the container specification; the port must match the application |
| Deployment `spec.replicas` | Not copied; use autoscaling [scale bounds](autoscaling/scale-bounds.md) for replica policy |
| Deployment selector and Kubernetes Service selector/port | Not copied as a user-managed Service; Serving manages routing and its networking resources |
| Original resource name and endpoint | Not automatically transferred; the illustration uses a distinct Knative Service name |

This mapping does not imply that omitted settings are unnecessary for your application. Review each existing field and dependency.

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

This separate resource uses the name `my-nginx-knative`, leaving the original Deployment and Kubernetes Service named `my-nginx` outside this example's scope. Choose an unused name and an explicit target namespace when following the deployment task.

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

Use [Deploy an HTTP container as a Knative Service](services/creating-services.md) to create and verify the separate resource with your chosen image and port. A successful request to its new URL does not prove that existing clients have moved to it. Do not delete or change the original workload based on this mapping alone.
