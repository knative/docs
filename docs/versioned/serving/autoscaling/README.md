---
audience: developer
components:
  - serving
function: explanation
---

# Autoscaling

Knative Serving automatically scales application pods to match incoming demand,
including scaling down to zero when idle. Autoscaling works out of the box with
the default **Knative Pod Autoscaler (KPA)** — you do not need to configure
concurrency or scale bounds unless you want to override the defaults.

## Choose a tuning goal

- **Cap concurrent requests per pod (protect a database or single-threaded app):**
  set a soft or hard [concurrency](concurrency.md) limit.
- **Avoid cold starts or cap maximum cost:** set `min-scale` and `max-scale` in
  [Scale bounds](scale-bounds.md).
- **Keep the last pod warm longer before scaling to zero:** adjust
  [Scale to zero](scale-to-zero.md) retention settings.
- **Scale on requests per second (RPS) or CPU/memory:** choose a
  [metric](autoscaling-metrics.md) and [target](autoscaling-targets.md), or
  switch to the Kubernetes HPA in [Autoscaler types](autoscaler-types.md).
- **Buffer traffic bursts through the Activator:** tune
  [Request buffering](../load-balancing/README.md).

## Tune a Service

Most autoscaling settings can be applied per Revision on `spec.template.metadata.annotations`
(cluster administrators can also set global defaults in `config-autoscaler`).
For example, to keep at least 1 replica warm, cap scale at 5, and target 50
concurrent requests per pod:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-service
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/min-scale: "1"
        autoscaling.knative.dev/max-scale: "5"
        autoscaling.knative.dev/target: "50"
    spec:
      containers:
        - image: ghcr.io/knative/helloworld-go:latest
```

Apply the manifest and verify the updated Revision is ready and has the
expected pods:

```bash
kubectl apply -f service.yaml
kubectl wait kservice/my-service --for=condition=Ready --timeout=120s
kubectl get pods -l serving.knative.dev/service=my-service
```

## Additional resources

- Try the [Autoscale sample app](autoscale-go/README.md) to watch KPA scale
  under load.
- Install the optional HPA autoscaler via
  [Install optional Serving extensions](../../install/yaml-install/serving/install-serving-with-yaml.md#install-optional-serving-extensions).
