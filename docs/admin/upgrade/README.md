# Upgrading Knative

Knative supports upgrading by a single [minor](https://semver.org/) version number. For example, if you have v0.21.0 installed, you must upgrade to v0.22.0 before attempting to upgrade to v0.23.0.

To verify the version of your current Knative installation:

- Check the installed **Knative Serving** version by entering the following command:

    ```bash
    kubectl get KnativeServing knative-serving --namespace knative-serving
    ```

    Example output:

    ```bash
    NAME              VERSION         READY   REASON
    knative-serving   0.23.0          True
    ```

- Check the installed **Knative Eventing** version by entering the following command:

    ```bash
    kubectl get KnativeEventing knative-eventing --namespace knative-eventing
    ```

    Example output:

    ```bash
    NAME               VERSION         READY   REASON
    knative-eventing   0.23.0          True
    ```
