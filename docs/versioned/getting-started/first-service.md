---
audience: developer
components:
  - serving
function: tutorial
---

# Deploying a Knative Service

**Start here after [installing Quickstart](quickstart-install.md).** Use the `kn` CLI throughout this tutorial; `kubectl` is used to inspect Kubernetes pods. Keep the same cluster and the `default` namespace for every lesson. There should not already be a Service named `hello` in that namespace.

You will deploy a "Hello world" Knative Service that accepts the environment variable `TARGET` and prints `Hello ${TARGET}!`.

## Deploy the Service

```bash
kn service create hello \
  --image ghcr.io/knative/helloworld-go:latest \
  --port 8080 \
  --env TARGET=World
```

!!! success "Expected result"
    `kn` reports that `hello` is available and prints its URL. On the kind Quickstart cluster, the URL resembles `http://hello.default.127.0.0.1.sslip.io`. Generated Revision names and addresses can vary; use the values from your output.

## Send your first request

```bash
curl "$(kn service describe hello -o url)"
```

!!! success "Expected output"
    ```{ .text .no-copy }
    Hello World!
    ```

You now have an HTTP endpoint managed by Knative Serving. The next lesson uses this same Service to observe scale-to-zero.

If the request fails to resolve the hostname, see the [DNS check in Autoscaling](first-autoscale.md#access-your-knative-service). If the Service is not Ready, start with [debugging application issues](../serving/troubleshooting/debugging-application-issues.md).

??? info "YAML equivalent (not needed for this route)"
    The [Quickstart YAML examples](yaml-examples.md#deploy-hello) show the same resource. Do not create it a second time; continue with `kn` for the remaining lessons.

**Previous:** [Install Quickstart](quickstart-install.md) · **Next:** [Observe autoscaling](first-autoscale.md)
