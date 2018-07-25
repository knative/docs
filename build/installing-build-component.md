# Installing the Knative build component

Before you can run a Knative build, you must install the Knative build
component in your Kubernetes cluster.

You have the option to install and use only the components of Knative that you
want, for example Knative serving is not required to create and run builds.

For details about installing a new instance of Knative in your Kubernetes
cluster, see [Installing Knative](../install/README.md).

To install only the Knative build component:

1. Run the `kubectl apply` command to install
   [Knative Build](https://github.com/knative/build) and its dependencies:
    ```bash
    kubectl apply -f https://storage.googleapis.com/knative-releases/build/latest/release.yaml
    ```
1. Monitor the Knative build components until all of the components show a
   `STATUS` of `Running`:
    ```bash
    kubectl get pods -n knative-build
    ```

    Tip: Instead of the `kubectl get` command multiple times, you can add
    `--watch` to view the component's status updates in real time.
    Use CTRL + C to exit watch mode.

You are now ready to create and run Knative builds, see
(Creating a simple Knative build)[../build/creating-builds.md] to get started.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
