# Install with the Knative Operator

--8<-- "prerequisites.md"

## Install the Knative Operator

1. Install the latest stable Operator release:

    ```bash
    kubectl apply -f {{artifact(org="knative",repo="operator",file="operator.yaml" )}}
    ```

1. Verify the Operator installation:

    - Because the Operator is installed to the `default` namespace, set the current namespace to `default` by running the command:

        ```bash
        kubectl config set-context --current --namespace=default
        ```

    - Check the Operator deployment status by running the command:

        ```bash
        kubectl get deployment knative-operator
        ```

        If the Operator is installed correctly, the deployment shows a `Ready` status:

        ```{.bash .no-copy}
        NAME               READY   UP-TO-DATE   AVAILABLE   AGE
        knative-operator   1/1     1            1           19h
        ```

## Install Knative Serving

After you have installed the Knative Operator, you can install Knative Serving.

1. Create the `KnativeServing` custom resource as a YAML file:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-serving
    ---
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

1. Verify the Knative Serving deployment.

    1. Monitor the Knative deployments:

        ```bash
        kubectl get deployment -n knative-serving
        ```

        If Knative Serving has been successfully deployed, all Knative Serving deployments will show a `READY` status:

        ```{ .bash .no-copy }
        NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
        activator              1/1     1            1           18s
        autoscaler             1/1     1            1           18s
        autoscaler-hpa         1/1     1            1           14s
        controller             1/1     1            1           18s
        domain-mapping         1/1     1            1           12s
        domainmapping-webhook  1/1     1            1           12s
        webhook                1/1     1            1           17s
        ```

    1. Verify the status of the `KnativeServing` custom resource:

        ```bash
        kubectl get KnativeServing knative-serving -n knative-serving
        ```

        If Knative Serving is successfully installed, you should see:

        ```{ .bash .no-copy }
        NAME              VERSION             READY   REASON
        knative-serving   <version number>    True
        ```

## Install Knative Eventing

After you have installed the Knative Operator, you can install Knative Eventing.

1. Create the `KnativeEventing` custom resource as a YAML file:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-eventing
    ---
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeEventing
    metadata:
      name: knative-eventing
      namespace: knative-eventing
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

1. Verify the Knative Eventing deployment.

    1. Monitor the Knative deployments:

        ```bash
        kubectl get deployment -n knative-eventing
        ```

        If Knative Eventing has been successfully deployed, all Knative Eventing deployments will show a `READY` status:

        ```{.bash .no-copy}
        NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
        eventing-controller     1/1     1            1           43s
        eventing-webhook        1/1     1            1           42s
        imc-controller          1/1     1            1           39s
        imc-dispatcher          1/1     1            1           38s
        mt-broker-controller    1/1     1            1           36s
        mt-broker-filter        1/1     1            1           37s
        mt-broker-ingress       1/1     1            1           37s
        pingsource-mt-adapter   1/1     1            1           43s
        ```

    1. Check the status of the `KnativeEventing` custom resource:

        ```bash
        kubectl get KnativeEventing knative-eventing -n knative-eventing
        ```

        If Knative Eventing is successfully installed, you should see:

        ```{.bash .no-copy}
        NAME               VERSION             READY   REASON
        knative-eventing   <version number>    True
        ```

## Uninstall

1. Remove the `KnativeServing` custom resource:

    ```bash
    kubectl delete KnativeServing knative-serving -n knative-serving
    ```

1. Remove the `KnativeEventing` custom resource:

    ```bash
    kubectl delete KnativeEventing knative-eventing -n knative-eventing
    ```

1. Remove the Knative Operator:

    ```bash
    kubectl delete -f {{artifact(org="knative",repo="operator",file="operator.yaml")}}
    ```
