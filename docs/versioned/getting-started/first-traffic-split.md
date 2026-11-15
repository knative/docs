---
audience: developer
components:
  - serving
function: tutorial
hide_next: true
---

<span id="traffic-splitting"></span>

# Update your service and split traffic

Use the `hello` Service from the previous lessons. Change its response, then
send traffic to both the old and new versions.

A **Revision** is an immutable snapshot of a Service's application configuration.
Changing the container's environment creates a new Revision. We will record the
original Revision's name so that you do not need to guess it.

## Creating a new Revision

First, save the current Revision's name in your terminal:

```bash
ORIGINAL_REVISION=$(kubectl get kservice hello -o jsonpath='{.status.latestReadyRevisionName}')
echo "$ORIGINAL_REVISION"
```

Keep using this terminal for the rest of the lesson.

Now change the `TARGET` environment variable and send all traffic to the new Revision:

```bash
kn service update hello --env TARGET=Knative --traffic @latest=100
```

Wait for the update to finish.

## Accessing the new Revision

```bash
curl "$(kn service describe hello -o url)"
```

The response is now:

```text
Hello Knative!
```

The Service URL has not changed. Its latest Revision now runs with the updated
configuration.

## View existing Revisions

```bash
kn revision list --service hello
```

You should see the original and updated Revisions. Their names are generated;
`ORIGINAL_REVISION` holds the earlier one's name.

## Splitting traffic between Revisions

Send half the traffic to the saved original Revision and half to the latest:

```bash
kn service update hello --traffic "$ORIGINAL_REVISION=50" --traffic @latest=50
```

## Verify the traffic split

Inspect the configuration:

```bash
kn service describe hello
```

The traffic section should show 50% for each Revision. Send several requests:

```bash
SERVICE_URL=$(kn service describe hello -o url)
for i in 1 2 3 4 5 6 7 8 9 10; do
  curl "$SERVICE_URL"
done
```

You should see both `Hello World!` and `Hello Knative!`. Routing is probabilistic,
so the responses need not alternate or appear in equal numbers. If you see only
one response, run the loop again and check the configured traffic split.

## Finish the track

You have deployed a container, observed autoscaling, and routed traffic between
Revisions. [Continue learning](next-steps.md) to choose another track or use the
Serving guides for your own application. Keep the cluster if you want to try
Eventing or deploy a function; [clean it up](clean-up.md) only when you are done.
