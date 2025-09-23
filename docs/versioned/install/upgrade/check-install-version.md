# Checking your Knative version

To check the version of your Knative installation, use one of the following commands,
depending on whether you installed Knative with YAML or with the Operator.

## If you installed with YAML

To verify the version of the Knative component that you have running on your cluster, query for the
`app.kubernetes.io/version` label in corresponding component namespace.

=== "Knative Serving"
    Check the installed Knative Serving version by running the command:

    ```bash
    {% raw %}
    kubectl get namespace knative-serving -o 'go-template={{index .metadata.labels "app.kubernetes.io/version"}}'
    {% endraw %}
    ```

    Example output:

    ```{ .bash .no-copy }
    v0.23.0
    ```


=== "Knative Eventing"
    Check the installed Knative Eventing version by running the command:

    ```bash
    {% raw %}
    kubectl get namespace knative-eventing -o 'go-template={{index .metadata.labels "app.kubernetes.io/version"}}'
    {% endraw %}
    ```

    Example output:

    ```{ .bash .no-copy }
    v0.23.0
    ```

## If you installed with the Operator

To verify the version of your current Knative installation:

=== "Knative Serving"
    Check the installed Knative Serving version by running the command:

    ```bash
    kubectl get KnativeServing knative-serving --namespace knative-serving
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME              VERSION         READY   REASON
    knative-serving   0.23.0          True
    ```

=== "Knative Eventing"
    Check the installed Knative Eventing version by running the command:

    ```bash
    kubectl get KnativeEventing knative-eventing --namespace knative-eventing
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME               VERSION         READY   REASON
    knative-eventing   0.23.0          True
    ```
