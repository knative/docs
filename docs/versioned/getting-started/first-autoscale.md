---
audience: developer
components:
  - serving
function: tutorial
---

<span id="autoscaling"></span><span id="list-your-knative-service"></span><span id="access-your-knative-service"></span>

# Watch your service scale to zero

Use the `hello` Service from the previous lesson. When it stops receiving
requests, Knative can remove its application pods. A new request causes the
application to start again.

## Observe autoscaling

In your first terminal, watch only the pods belonging to this Service:

```bash
kubectl get pods --selector serving.knative.dev/service=hello --watch
```

Stop sending requests, including refreshing the Service in a browser. After
an idle period, the pod changes from `Running` to `Terminating` and disappears.
This can take a couple of minutes. If no pod is listed when you start watching,
it may already have scaled down.

The Service and its URL still exist; you do not need to deploy it again.

<span id="scale-up-your-knative-service"></span>

## Send a request to wake it up

Keep the watch running. In a **second terminal**, send another request:

```bash
curl "$(kn service describe hello -o url)"
```

The request may take longer while the application starts. It still returns:

```text
Hello World!
```

In the first terminal, a new pod appears and becomes ready. Its generated name
may differ from the earlier pod's name. You have observed scale-to-zero and
scale-from-zero.

Press **Ctrl+C** in the first terminal to stop watching pods. This stops only the
watch, not the Service. Keep the environment for the next lesson:
[update the Service and split traffic](first-traffic-split.md).
