# Upgrading using the Knative Operator

This topic describes how to upgrade Knative if you installed using the Operator.
If you installed using YAML, see [Upgrading with kubectl](upgrade-installation.md).

The attribute `spec.version` is the only field you need to change in the
Serving or Eventing custom resource to perform an upgrade. You do not need to specify the version for the `patch` number, because the Knative Operator matches the latest available `patch` number, as long as you specify `major.minor` for the version. For example, you only need to specify `"1.1"` to upgrade to the 1.1 release, you do not need to specify the exact `patch` number.

The Knative Operator supports up to the last three major releases. For example, if the current version of the Operator is 1.5, it bundles and supports the installation of Knative versions 1.5, 1.4, 1.3 and 1.2.

!!! note
    In the following examples, Knative Serving custom resources are installed in the `knative-serving` namespace, and  Knative Eventing custom resources are installed in the `knative-eventing` namespace.

## Performing the upgrade

To upgrade, apply the Operator custom resources, adding the `spec.version` for the Knative version that you want to upgrade to:

1. Create a YAML file containing the following:

    ```yaml
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      version: "<new-version>"
    ```
    Where `<new-version>` is the Knative version that you want to upgrade to.

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

## Verifying an upgrade by viewing pods

You can confirm that your Knative components have upgraded successfully, by viewing the status of the pods for the components in the relevant namespace.

!!! note
    All pods will restart during the upgrade and their age will reset.

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
## Verifying an upgrade by viewing custom resources

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

## Rollback to an earlier version

If the upgrade fails, you can rollback to restore your Knative to the previous version. For example, if something goes wrong with an upgrade to 1.2, and your previous version is 1.1, you can apply the following custom resources to restore Knative Serving and Knative Eventing to version 1.1.

=== "Knative Serving"

    To rollback to a previous version of Knative Serving:

    1. Create a YAML file containing the following:

        ```yaml
        apiVersion: operator.knative.dev/v1alpha1
        kind: KnativeServing
        metadata:
          name: knative-serving
          namespace: knative-serving
        spec:
          version: "<previous-version>"
        ```
        Where `<previous-version>` is the Knative version that you want to downgrade to.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

=== "Knative Eventing"

    To rollback to a previous version of Knative Eventing:

    1. Create a YAML file containing the following:

        ```yaml
        apiVersion: operator.knative.dev/v1alpha1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          version: "<previous-version>"
        ```
        Where `<previous-version>` is the Knative version that you want to downgrade to.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.
