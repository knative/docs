---
audience: developer
components:
  - serving
function: tutorial
---

# Autoscaling

**Starting state:** You have [deployed `hello`](first-service.md) and received `Hello World!`. Keep the same cluster and `default` namespace.

Knative Serving provides automatic scaling, also known as **autoscaling**. This means that a Knative Service by default scales down to zero running pods when it is not in use.

## List your Knative Service

Use the Knative (`kn`) CLI to view the URL where your Knative Service is hosted:

```bash
kn service list
```

!!! success "Expected result"
    `hello` is listed with `READY` set to `True` and a URL. Use the reported URL rather than copying an example address.

??? info "Inspecting with kubectl instead"
    `kubectl get ksvc` also lists the Service. This tutorial still uses `kn` for requests and updates; the [YAML examples](yaml-examples.md) are supporting reference, not a separate CLI-free route.

## Access your Knative Service

Access your Knative Service by opening the previous URL in your browser or by running the command:

```bash
echo "Accessing URL $(kn service describe hello -o url)"
curl "$(kn service describe hello -o url)"
```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    Hello World!
    ```

??? question "Are you seeing `curl: (6) Could not resolve host: hello.default.${LOADBALANCER_IP}.sslip.io`?"

    In some cases your DNS server may be set up not to resolve `*.sslip.io` addresses. If you encounter this problem, it can be fixed by using a different nameserver to resolve these addresses.

    The exact steps will differ according to your distribution. For example, with Ubuntu derived systems which use `systemd-resolved`, you can add the following entry to the `/etc/systemd/resolved.conf`:

    ```ini
    [Resolve]
    DNS=8.8.8.8
    Domains=~sslip.io.
    ```

    Then simply restart the service with `sudo service systemd-resolved restart`.

    For MacOS users, you can add the DNS and domain using the network settings as explained [here](https://support.apple.com/en-gb/guide/mac-help/mh14127/mac).

## Observe autoscaling

Watch the pods and see how they scale to zero after traffic stops going to the URL:

```bash
kubectl get pod -l serving.knative.dev/service=hello -w
```

!!! note
    It may take up to 2 minutes for your pods to scale down. Pinging your service again resets this timer.

!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME                                     READY   STATUS
    hello-world                              2/2     Running
    hello-world                              2/2     Terminating
    hello-world                              1/2     Terminating
    hello-world                              0/2     Terminating
    ```

## Scale up your Knative Service

Leave the watch running. In a **second terminal** using the same cluster and namespace, request the Service again:

```bash
curl "$(kn service describe hello -o url)"
```

You should receive `Hello World!`. In the first terminal, you can see a new pod running again:

!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME                                     READY   STATUS
    hello-world                              0/2     Pending
    hello-world                              0/2     ContainerCreating
    hello-world                              1/2     Running
    hello-world                              2/2     Running
    ```

Pod names and intermediate status lines vary; the important observations are that no `hello` pod remains after idle time and a new pod appears when you request the Service again.

Exit the watch with `Ctrl+C`.

Continue to traffic splitting below to finish the chosen tutorial route. After the exercise, use these direct handoffs for your own Service:

- **Task:** [Set a concurrency target](../serving/autoscaling/configure-concurrency.md).
- **Explanation:** [How concurrency affects autoscaling](../serving/autoscaling/concurrency-behavior.md).
- **Reference:** [Concurrency settings](../serving/autoscaling/concurrency.md) and [scale bounds](../serving/autoscaling/scale-bounds.md).

The [Serving autoscaling overview](../serving/autoscaling/README.md) routes to other scaling topics.

**Previous:** [Deploy a Service](first-service.md) · **Next:** [Split traffic between Revisions](first-traffic-split.md)
