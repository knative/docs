---
audience: developer
components:
  - serving
function: tutorial
---

# Traffic splitting

**Starting state:** You have completed [Autoscaling](first-autoscale.md), and `hello` still returns `Hello World!`. Stay in the same cluster and `default` namespace.

You will create a second Revision, then route half the traffic to each Revision. A [Revision](../serving/revisions/README.md) is a snapshot of a Service's application code and configuration. Traffic splitting can support [blue/green deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html) and [canary deployments](https://martinfowler.com/bliki/CanaryRelease.html).

## Creating a new Revision

Before updating the Service, save the name of the current Revision. This avoids assuming a generated name such as `hello-00001`.

```bash
ORIGINAL_REVISION=$(kubectl get ksvc hello -o jsonpath='{.status.latestReadyRevisionName}')
printf 'Original Revision: %s\n' "$ORIGINAL_REVISION"
kn service update hello --env TARGET=Knative
```

Run the following commands in this same terminal so that `ORIGINAL_REVISION` remains available.

!!! success "Expected result"
    The update completes and reports a new Revision. The Service URL stays the same.

## Accessing the new Revision

```bash
curl "$(kn service describe hello -o url)"
```

!!! success "Expected output"
    ```{ .text .no-copy }
    Hello Knative!
    ```

## View existing Revisions

```bash
kn revision list
```

Find the two Revisions for `hello`. The `TRAFFIC` column shows that the new Revision receives 100% of traffic and the original receives none. In this exercise, no traffic configuration was specified before the update, so traffic follows the latest Revision.

## Splitting traffic between Revisions

```bash
kn service update hello \
  --traffic "$ORIGINAL_REVISION=50" \
  --traffic @latest=50
```

`@latest` points to the latest Revision, which in this exercise is the one greeting `Knative`.

??? info "YAML equivalent (not needed for this route)"
    See [update hello and split traffic](yaml-examples.md#update-hello-and-split-traffic) for the declarative form. Continue using the CLI in this lesson.

## Verify the traffic split

```bash
kn revision list
```

!!! success "Expected result"
    Both Revisions for `hello` show `50%` in the `TRAFFIC` column.

Send several requests:

```bash
SERVICE_URL=$(kn service describe hello -o url)
for i in $(seq 1 10); do
  curl "$SERVICE_URL"
done
```

You should see both `Hello World!` and `Hello Knative!`. A 50/50 configuration does not promise strict alternation or exactly five responses of each kind in ten requests. The Revision listing verifies the configured split.

You have deployed, scaled, and updated a Service. Next, use another Service to send and receive events.

**Previous:** [Observe autoscaling](first-autoscale.md) · **Next:** [Try Eventing](getting-started-eventing.md)
