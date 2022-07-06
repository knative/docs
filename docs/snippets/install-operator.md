<!-- Snippet used in the following topics:
- docs/serving/install/README.md
- docs/eventing/install/README.md
-->
### Install the Knative Operator

Before you install the Serving or Eventing components, you must install the Knative Operator.

<h4>Procedure</h4>

1. To install the latest stable Knative Operator release, run the command:

    ```bash
    kubectl apply -f {{artifact(org="knative",repo="operator",file="operator.yaml" )}}
    ```

    !!! tip
        You can find information about the released versions of the Knative Operator on the [releases page](https://github.com/knative/operator/releases).

1. The Operator is installed in the `default` namespace. Set the current namespace to `default` by running the command:

    ```bash
    kubectl config set-context --current --namespace=default
    ```

1. Check the Operator deployment status by running the command:

    ```bash
    kubectl get deployment knative-operator
    ```

    If the Operator is installed correctly, the deployment shows a `Ready` status:

    ```{.bash .no-copy}
    NAME               READY   UP-TO-DATE   AVAILABLE   AGE
    knative-operator   1/1     1            1           19h
    ```

1. Optional. To track the log of the Operator, run the command:

    ```bash
    kubectl logs -f deploy/knative-operator
    ```
