---
audience: developer
components:
  - serving
function: how-to
---

# Set a concurrency target for a service

Set a soft concurrency target on an existing Knative Service, then verify that the new Revision has the requested settings. This guide uses the Knative Pod Autoscaler (KPA). It does not change cluster defaults or add a hard concurrency limit.

## Prerequisites

- Knative Serving is installed and the Service is already Ready.
- The Service uses generated Revision names: `spec.template.metadata.name` is absent or empty. The preflight check below verifies this. Services with an explicitly named revision template are outside this guide's scope.
- `kubectl` is installed and connected to the correct cluster.
- You can update Services and read Revisions in the Service's namespace.
- You have chosen a target based on your application's workload. The value `50` below is an example, not a recommended value for every application. Read [How concurrency affects autoscaling](concurrency-behavior.md) if you need to decide between a target and a hard limit.

Updating the revision template creates a new Revision. Check the Service's traffic configuration before changing it: traffic directed to the latest Revision will follow the update, while traffic pinned to a named Revision will not. See [traffic management](../traffic-management.md).

If a GitOps controller or another deployment system manages this Service, make the equivalent change in its source manifest instead of applying a live patch that the controller could revert.

## Record the current configuration

1. Set the Service name and namespace:

    ```bash
    SERVICE=helloworld-go
    NAMESPACE=default
    ```

    Replace these example values with your existing Service and its namespace.

2. Save the current Service for comparison and rollback planning:

    ```bash
    kubectl get service.serving.knative.dev "$SERVICE" -n "$NAMESPACE" -o yaml > service-before-concurrency.yaml
    ```

    In the saved file, inspect `spec.template.metadata.annotations` for existing `class`, `metric`, and `target` autoscaling annotations, and `spec.template.spec.containerConcurrency` for a hard limit. Also inspect `spec.traffic`. If a nonzero hard limit is smaller than your chosen target, it caps the target used by the Autoscaler; this guide leaves that hard limit unchanged.

3. Check that the revision template does not specify an explicit name:

    ```bash
    kubectl get service.serving.knative.dev "$SERVICE" -n "$NAMESPACE" -o jsonpath='{.spec.template.metadata.name}{"\n"}'
    ```

    Expected output is a blank line. If a name is printed, **stop before applying the patch**: choose a Service with generated Revision names, or use your deployment workflow to supply a new, valid Revision name together with the template change. Do not retain the existing explicit name while changing the template. Serving's [`VerifyNameChange` validation](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/serving/v1/revision_validation.go#L80-L108){target=_blank} rejects that update.

    This check reads the template name, not `status.latestCreatedRevisionName`; generated Revisions still have names in status.

## Apply the target

Proceed only after the template-name check returns no explicit name. Patch the revision template, not the top-level Service annotations:

```bash
kubectl patch service.serving.knative.dev "$SERVICE" -n "$NAMESPACE" --type merge -p '
{"spec":{"template":{"metadata":{"annotations":{
  "autoscaling.knative.dev/class":"kpa.autoscaling.knative.dev",
  "autoscaling.knative.dev/metric":"concurrency",
  "autoscaling.knative.dev/target":"50"
}}}}}'
```

This explicitly selects KPA and the concurrency metric. If the Service previously used a different class or metric, this changes its scaling strategy as well as its target. Other template settings, including any target-utilization annotation and hard limit, are retained.

## Verify the new Revision

1. Wait for the Service to report Ready:

    ```bash
    kubectl wait service.serving.knative.dev/"$SERVICE" -n "$NAMESPACE" --for=condition=Ready --timeout=120s
    kubectl get service.serving.knative.dev "$SERVICE" -n "$NAMESPACE"
    ```

    Confirm `READY` is `True` and `LATESTCREATED` matches `LATESTREADY`. If readiness fails or the revisions differ, inspect the Service's conditions with `kubectl describe service.serving.knative.dev "$SERVICE" -n "$NAMESPACE"`; do not assume the change is serving traffic.

2. Read the settings from the latest created Revision:

    ```bash
    REVISION=$(kubectl get service.serving.knative.dev "$SERVICE" -n "$NAMESPACE" -o jsonpath='{.status.latestCreatedRevisionName}')
    kubectl get revision "$REVISION" -n "$NAMESPACE" -o jsonpath='class={.metadata.annotations.autoscaling\.knative\.dev/class}{"\n"}metric={.metadata.annotations.autoscaling\.knative\.dev/metric}{"\n"}target={.metadata.annotations.autoscaling\.knative\.dev/target}{"\n"}'
    ```

    Expected output for this example:

    ```text
    class=kpa.autoscaling.knative.dev
    metric=concurrency
    target=50
    ```

    Check `spec.traffic` and `status.traffic` in the Service output (`kubectl get service.serving.knative.dev "$SERVICE" -n "$NAMESPACE" -o yaml`) to confirm whether requests will reach this Revision. Creating a Ready Revision alone does not move traffic pinned to an older Revision.

These checks verify configuration and readiness, not a particular replica count or latency. The observed scaling response also depends on traffic, target utilization, a hard limit, and scale bounds. For a controlled load experiment, use the [Go autoscaling sample](autoscale-go/README.md) on a non-production service.

## Undo the change

Restore the previous values of the three annotations in the Service's revision template, using `service-before-concurrency.yaml` as a record. For an annotation that was previously absent, remove it with a merge patch whose value for that key is `null`. Do not delete unrelated annotations or apply the saved live resource wholesale. For a managed Service, revert the corresponding source-manifest change.

Restoring the template creates another Revision. Repeat the readiness and traffic checks above to confirm the restored configuration is the one you intend to use.

## Related settings

- [Concurrency settings reference](concurrency.md) — hard limits, utilization, and cluster-default fragments.
- [Scale bounds reference](scale-bounds.md) — minimum and maximum replica settings.
