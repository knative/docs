---
audience: developer
components:
  - serving
function: tutorial
hide_prev: true
hide_next: true
---

<span id="deploying-a-knative-service"></span>

# Try Serving

Deploy a sample HTTP container as a Knative Service, watch it scale to zero,
and split traffic between two Revisions.

<span id="before-you-begin"></span>

## Prepare

[Set up a cluster](quickstart-install.md) if you have not already done so, then
return here with the `kind-knative` context and `default` namespace selected.
Start with no Service named `hello` in that namespace.

<span id="deploy-the-container"></span><span id="send-a-request"></span>

## Deploy and call

A Knative **Service** manages deployment, autoscaling, and HTTP routing for your
container, giving it a stable URL.

1. Create the `hello` Service:

    ```bash
    kn service create hello \
      --image ghcr.io/knative/helloworld-go:latest \
      --port 8080 \
      --env TARGET=World
    ```

1. Call its URL:

    ```bash
    SERVICE_URL=$(kn service describe hello -o url)
    curl "$SERVICE_URL"
    ```

    Expected response: `Hello World!`

??? help "If the request fails"

    Check your [learning context](quickstart-install.md#create-and-verify), then
    run `kn service list`. If `hello` is not ready, inspect `kn service describe hello`.
    If the Service is ready, a DNS error means the `sslip.io` hostname could not
    be resolved, while a connection error means the cluster gateway on port 80 is
    unreachable. See the
    [Serving troubleshooting guide](../serving/troubleshooting/debugging-application-issues.md)
    or [get help](next-steps.md#get-help).

<span id="autoscaling"></span><span id="observe-autoscaling"></span><span id="scale-up-your-knative-service"></span>

## Watch autoscaling

Idle Knative Services scale to zero pods and wake up when the next request arrives.

1. Watch the Service's pods in your first terminal:

    ```bash
    kubectl get pods --selector serving.knative.dev/service=hello --watch
    ```

    Stop sending requests. After an idle period (up to a couple of minutes), the pod
    terminates and disappears. The Service and URL remain.

1. Keep the watch running. In a **second terminal**, send another request:

    ```bash
    curl "$(kn service describe hello -o url)"
    ```

    The request pauses briefly while a new pod starts, then returns `Hello World!`.
    Press ++ctrl+c++ in the first terminal to stop watching.

<span id="creating-a-new-revision"></span><span id="save-the-original-revision"></span><span id="accessing-the-new-revision"></span>

## Create a revision

A **Revision** is an immutable snapshot of a Service's configuration. Changing
`TARGET` creates a new Revision.

1. Save the current Revision's name in your terminal so you can reference it later:

    ```bash
    ORIGINAL_REVISION=$(
      kubectl get kservice hello \
        -o jsonpath='{.status.latestReadyRevisionName}'
    )
    echo "$ORIGINAL_REVISION"
    ```

1. Update `TARGET` and send all traffic to the new Revision:

    ```bash
    kn service update hello --env TARGET=Knative --traffic @latest=100
    curl "$(kn service describe hello -o url)"
    ```

    The URL stays the same, and the response is now `Hello Knative!`.

??? note "If you lose the saved Revision name"

    Run `kn revision list --service hello`, check `kn revision describe <name>`
    for `TARGET=World`, and set `ORIGINAL_REVISION=<name>`.

<span id="traffic-splitting"></span><span id="splitting-traffic-between-revisions"></span><span id="verify-the-traffic-split"></span>

## Split traffic

Send 50% of traffic to the original Revision and 50% to the latest:

```bash
kn service update hello --traffic "$ORIGINAL_REVISION=50" --traffic @latest=50
kn service describe hello
```

The traffic section should show 50% for each Revision. Send several requests to
observe both versions:

```bash
SERVICE_URL=$(kn service describe hello -o url)
for i in 1 2 3 4 5 6 7 8 9 10; do
  curl "$SERVICE_URL"
done
```

You should see both `Hello World!` and `Hello Knative!` (routing is probabilistic,
so responses need not alternate). If ten requests show only one response, run the
loop again and verify the 50/50 split in `kn service describe hello`.

## Next steps

Keep your cluster if you want to try another track. Continue with
[Try Eventing](getting-started-eventing.md), [Try Functions](about-knative-functions.md),
or [Next steps and cleanup](next-steps.md).
