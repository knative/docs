# Install Knative

Knative components can be used independently or together. You can install either Knative Serving, Knative Eventing, or both components on your cluster.

You can install Knative components either by applying the required YAML files, or by using the Knative Operator.

Before you can get started with Knative Serving or Knative Eventing, you must ensure that your Knative development environment is set up and configured properly.

--8<-- "prerequisites.md"

## Using the Knative Operator

<!-- TODO: what are the benefits of using the Operator? How is this different to YAML install atm except that it requires extra steps?-->

If you want to use the Knative Operator to manage your Knative custom resources (CRs), you must install the Operator before you install any other Knative components.

!!! warning
    The Knative Operator is still in Alpha phase. It has not been tested in a production environment, and should be used for development or test purposes only.

### Installing the Knative Operator

1. Install the latest stable Knative Operator release by running the command:

    ```bash
    kubectl apply -f https://storage.googleapis.com/knative-nightly/operator/latest/operator.yaml
    ```

1. Verify that the Knative Operator was successfully installed by running the command:

    ```bash
    kubectl get deployment knative-operator
    ```

    You will see the following output if the Operator was installed successfully:

    ```bash
    NAME               READY   UP-TO-DATE   AVAILABLE   AGE
    knative-operator   1/1     1            1           19h
    ```

Once you have installed the Knative Operator, you can install Knative Serving or Knative Eventing.

## Next steps

- [Install Knative Serving]()
- [Install Knative Eventing]()
- [Install the Knative `kn` CLI]()

## Additional resources

- [Knative Operator release information](https://github.com/knative/operator/releases).
- [Knative Serving release information](https://github.com/knative/serving/releases).
- [Knative Eventing release information](https://github.com/knative/eventing/releases).
- [Knative CLI release information](https://github.com/knative/client/releases).
