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

The attribute `spec.version` is the only field you need to change in the
Serving or Eventing custom resource to perform an upgrade. You do not need to specify the version for the `patch` number, because the Knative Operator matches the latest available `patch` number, as long as you specify `major.minor` for the version. For example, you only need to specify `"1.1"` to upgrade to the 1.1 release, you do not need to specify the exact `patch` number.

The Knative Operator bundles and supports the current release plus the three previous minor releases (four minor releases total). For example, Operator 1.15 bundles Knative versions 1.15, 1.14, 1.13, and 1.12.

!!! note
    In the following examples, Knative Serving custom resources are installed in the `knative-serving` namespace, and Knative Eventing custom resources are installed in the `knative-eventing` namespace.

## Performing the upgrade

Update `spec.version` in your existing `KnativeServing` or `KnativeEventing` custom resource manifest (or patch it in place) so you do not overwrite existing configuration such as ingress, ConfigMaps, or high-availability settings.

=== "Patch existing CR"
    ```bash
    kubectl patch KnativeServing knative-serving -n knative-serving \
      --type merge -p '{"spec":{"version":"<new-version>"}}'
    ```

    ```bash
    kubectl patch KnativeEventing knative-eventing -n knative-eventing \
      --type merge -p '{"spec":{"version":"<new-version>"}}'
    ```

=== "Update manifest"
    Update `spec.version` in your existing CR file (using `operator.knative.dev/v1beta1`) and apply it:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      version: "<new-version>"
      # Preserve your existing spec fields (config, ingress, high-availability, etc.)
    ```

    ```bash
    kubectl apply -f <filename>.yaml
    ```

## Verify the upgrade { #verifying-an-upgrade-by-viewing-pods }

Verify both the reported version and `READY=True` on the Operator custom resources, confirm pods are running, and test a real Service request or CloudEvent delivery:

=== "Knative Serving"
    Enter the following command to view information about pods in the `knative-serving` namespace:

    ```bash
    kubectl get pods -n knative-serving
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
    Enter the following command to view information about pods in the `knative-eventing` namespace:

    ```bash
    kubectl get pods -n knative-eventing
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

<!-- TODO: Make this a snippet for verifying all installations-->
## Check custom resources { #verifying-an-upgrade-by-viewing-custom-resources }

You can verify the status of a Knative component by checking that the custom resource `READY` status is `True`.

=== "Knative Serving"

    ```bash
    kubectl get KnativeServing knative-serving -n knative-serving
    ```

    This command returns an output similar to the following:

    ```{ .bash .no-copy }
    NAME              VERSION         READY   REASON
    knative-serving   1.1.0          True
    ```

=== "Knative Eventing"

    ```bash
    kubectl get KnativeEventing knative-eventing -n knative-eventing
    ```

    This command returns an output similar to the following:

    ```{ .bash .no-copy }
    NAME               VERSION        READY   REASON
    knative-eventing   1.1.0         True
    ```
    <!--- END snippet-->

## Roll back { #rollback-to-an-earlier-version }

If an upgrade fails, you can roll back by one minor version by restoring `spec.version` to `<previous-version>` in your existing custom resource (without removing your other `spec` settings):

=== "Knative Serving"
    ```bash
    kubectl patch KnativeServing knative-serving -n knative-serving \
      --type merge -p '{"spec":{"version":"<previous-version>"}}'
    ```

    Or update `spec.version` in your `operator.knative.dev/v1beta1` `KnativeServing` manifest and run `kubectl apply -f <filename>.yaml`.

=== "Knative Eventing"
    ```bash
    kubectl patch KnativeEventing knative-eventing -n knative-eventing \
      --type merge -p '{"spec":{"version":"<previous-version>"}}'
    ```

    Or update `spec.version` in your `operator.knative.dev/v1beta1` `KnativeEventing` manifest and run `kubectl apply -f <filename>.yaml`.
