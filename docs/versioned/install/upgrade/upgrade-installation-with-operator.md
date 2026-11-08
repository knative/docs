---
audience: administrator
components:
  - serving
  - eventing
function: how-to
---

# Upgrading using the Knative Operator

This topic describes how to upgrade Knative if you installed using the Operator.
If you installed using YAML, see [Upgrading with kubectl](upgrade-installation.md).

Change `spec.version` in the existing component custom resource; preserve its other settings. For bundled manifests, `major.minor` selects the latest patch available to that Operator for the selected minor release. An exact `major.minor.patch` selects that bundled release. These rules are implemented by the [v1.23 version-resolution code](https://github.com/knative/operator/blob/knative-v1.23.0/pkg/reconciler/common/releases.go). Custom manifests need their own version/compatibility checks; do not assume the same patch resolution or discard those customizations.

## Before changing versions

- You have an Operator-managed installation and permission to read and update the component custom resource and inspect its workloads.
- Your installed Operator supports the selected component release. Check the [supported-bundle reference](../operator/supported-versions.md) for the documented Operator, or the installed Operator release's information. Do not infer compatibility from a fixed count of releases.
- Check the [current component version](check-install-version.md), [installation requirements](../requirements.md), and release notes for the intended change. Upgrade one minor release at a time; availability in the bundle does not make a multi-minor jump supported.
- Retain the authoritative custom resource manifest and its previous values. If GitOps manages it, change and synchronize that source rather than competing with it through live updates. Preserve ingress, registry, ConfigMap values, workload overrides, and custom manifest settings.

These examples use `operator.knative.dev/v1beta1`, matching the [documented configuration API](../operator/configuration-reference.md). Confirm that your installed CRD serves this API before proceeding. For remote deployments, use the [multi-cluster operational guidance](../operator/multi-cluster-deployment.md) to establish hub/spoke inspection scope instead of assuming all resources are on one cluster.

Select the context and one component explicitly; these example names are not instructions to use your default cluster:

```bash
CONTEXT=my-cluster-context
RESOURCE=knativeserving.operator.knative.dev
NAME=knative-serving
NAMESPACE=knative-serving
TARGET_VERSION=1.23
EXPECTED_VERSION=1.23.0
```

Replace the context, name, namespace, and versions with your planned values. For Eventing, use `RESOURCE=knativeeventing.operator.knative.dev` and its actual name/namespace. `EXPECTED_VERSION` is the resolved patch release from the installed Operator's bundle, not merely the minor-version prefix. Check the current context details with `kubectl config get-contexts "$CONTEXT"`; the commands below explicitly target it without changing the default context.

## Performing the upgrade

1. Inspect the selected resource and retain a live snapshot as a diagnostic record:

    ```bash
    kubectl --context "$CONTEXT" get "$RESOURCE" "$NAME" -n "$NAMESPACE" -o yaml > component-before-upgrade.yaml
    ```

    Confirm its identity, current `status.version`, and status conditions. If an upgrade is already incomplete, inspect it before applying another version change. Do not apply the saved live resource wholesale as a recovery manifest.

1. In the existing authoritative manifest, change only `spec.version` for the selected component. The following Serving example illustrates the field; it is not a complete replacement for your installation:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      version: "<new-version>"
    ```

    Replace `<new-version>` with `TARGET_VERSION`. Keep the existing resource identity and all other spec fields. For Eventing, edit the existing `KnativeEventing` manifest in the same way.

1. Validate and apply that complete, updated manifest through its authoritative workflow:

    ```bash
    kubectl --context "$CONTEXT" apply --dry-run=server -n "$NAMESPACE" -f <filename>.yaml
    kubectl --context "$CONTEXT" apply -n "$NAMESPACE" -f <filename>.yaml
    ```

    Replace `<filename>` with the manifest path and ensure its namespace matches the selected namespace. For GitOps, update and synchronize the source instead. Server validation does not prove successful reconciliation, application compatibility, or a safe rollback.

## Verifying an upgrade by viewing pods

Inspect the selected component's pods for failed or pending workloads. Pod readiness and age alone do not prove that the requested version is installed; also perform the custom resource and application checks below.

!!! note
    Workloads can be replaced or restarted during an upgrade. The sample pod names below are illustrative, not an expected list for every release or networking implementation.

=== "Knative Serving"
    With the variables set for Serving, inspect pods in its selected namespace:

    ```bash
    kubectl --context "$CONTEXT" get pods -n "$NAMESPACE"
    ```

    The command returns an output similar to the following:

    ```{ .bash .no-copy }
    NAME                                                     READY   STATUS      RESTARTS   AGE
    activator-6875896748-gdjgs                               1/1     Running     0          58s
    autoscaler-6bbc885cfd-vkrgg                              1/1     Running     0          57s
    autoscaler-hpa-5cdd7c6b69-hxzv4                          1/1     Running     0          55s
    controller-64dd4bd56-wzb2k                               1/1     Running     0          57s
    net-istio-webhook-75cc84fbd4-dkcgt                       1/1     Running     0          50s
    net-istio-controller-6dcbd4b5f4-mxm8q                    1/1     Running     0          51s
    storage-version-migration-serving-serving-0.20.0-82hjt   0/1     Completed   0          50s
    webhook-75f5d4845d-zkrdt                                 1/1     Running     0          56s
    ```

=== "Knative Eventing"
    With the variables set for Eventing, inspect pods in its selected namespace:

    ```bash
    kubectl --context "$CONTEXT" get pods -n "$NAMESPACE"
    ```

    The command returns an output similar to the following:

    ```{ .bash .no-copy }
    NAME                                              READY   STATUS      RESTARTS   AGE
    eventing-controller-6bc59c9fd7-6svbm              1/1     Running     0          38s
    eventing-webhook-85cd479f87-4dwxh                 1/1     Running     0          38s
    imc-controller-97c4fd87c-t9mnm                    1/1     Running     0          33s
    imc-dispatcher-c6db95ffd-ln4mc                    1/1     Running     0          33s
    mt-broker-controller-5f87fbd5d9-m69cd             1/1     Running     0          32s
    mt-broker-filter-5b9c64cbd5-d27p4                 1/1     Running     0          32s
    mt-broker-ingress-55c66fdfdf-gn56g                1/1     Running     0          32s
    storage-version-migration-eventing-0.20.0-fvgqf   0/1     Completed   0          31s
    sugar-controller-684d5cfdbb-67vsv                 1/1     Running     0          31s
    ```

## Verifying an upgrade by viewing custom resources

After reconciliation, inspect the selected custom resource and compare its desired and installed versions:

```bash
kubectl --context "$CONTEXT" get "$RESOURCE" "$NAME" -n "$NAMESPACE"
kubectl --context "$CONTEXT" get "$RESOURCE" "$NAME" -n "$NAMESPACE" -o jsonpath='desired={.spec.version}{"\n"}installed={.status.version}{"\n"}ready={.status.conditions[?(@.type=="Ready")].status}{"\n"}'
```

For the example target, expected fields are:

```text
desired=1.23
installed=1.23.0
ready=True
```

Confirm `spec.version` matches `TARGET_VERSION`, `status.version` matches the resolved `EXPECTED_VERSION`, and `READY` is `True`. A Ready resource still reporting the old version is not confirmation of this upgrade. The status field records the [installed release](https://github.com/knative/operator/blob/knative-v1.23.0/pkg/apis/operator/v1beta1/knativeserving_types.go).

If the target version or readiness does not match, inspect the resource's status conditions with the same context/name/namespace and use [installation troubleshooting](../troubleshooting.md) before making another change. Then test the existing application request or event paths affected by the upgrade. Matching version and readiness do not establish application compatibility.

## Rollback to an earlier version

A previous version may be a recovery option, but changing `spec.version` does not guarantee recovery from a failed or partially applied upgrade.

!!! warning
    Before attempting a rollback, confirm that the previous release is available to the installed Operator, the version transition is supported, and your resources and applications do not depend on features or data formats unavailable in that release. Review release-specific downgrade guidance. The Operator's [v1.23 migration check](https://github.com/knative/operator/blob/knative-v1.23.0/pkg/reconciler/common/releases.go) limits ordinary transitions to the same major version and at most one minor version; passing that check does not establish workload compatibility or undo every effect of an upgrade.

If rollback compatibility is uncertain, stop and collect status conditions and diagnostics through [installation troubleshooting](../troubleshooting.md) rather than applying an unsupported target or deleting component resources.

If the checks permit rollback, use the recorded previous configuration to change `spec.version` in the authoritative existing manifest. Retain its other customizations and its installed `v1beta1` API; do not replace it with the illustrative fragments below or apply the live snapshot wholesale.

=== "Knative Serving"

    This illustrates the version field to restore in the existing Serving manifest:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      version: "<previous-version>"
    ```

=== "Knative Eventing"

    This illustrates the version field to restore in the existing Eventing manifest:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeEventing
    metadata:
      name: knative-eventing
      namespace: knative-eventing
    spec:
      version: "<previous-version>"
    ```

Replace `<previous-version>` with the validated recovery target. Reconfirm the context and selected component, and set `TARGET_VERSION` and `EXPECTED_VERSION` to that target and its resolved bundled patch before applying:

```bash
kubectl --context "$CONTEXT" apply --dry-run=server -n "$NAMESPACE" -f <filename>.yaml
kubectl --context "$CONTEXT" apply -n "$NAMESPACE" -f <filename>.yaml
```

For GitOps, restore the intended values in its source and synchronize through that workflow. Repeat the version/readiness, pod, and application checks above. If recovery remains incomplete, collect diagnostics; do not assume another version change will resolve it.
