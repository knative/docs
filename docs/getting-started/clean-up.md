---
hide_next: true
---
# Clean Up

We recommend that you delete the cluster used for this tutorial to free up resources
on your local machine.

If you want to continue experimenting with Knative after deleting the cluster,
you can reinstall Knative on a new cluster using the [`quickstart` plugin](quickstart-install.md#run-the-knative-quickstart-plugin) again.

## Delete the Cluster

=== "kind"

    Delete your `kind` cluster by running the command:

    ```bash
    kind delete clusters knative
    ```
    !!! success "Example output"
        ```{ .bash .no-copy }
        Deleted clusters: ["knative"]
        ```

=== "minikube"

    Delete your `minikube` cluster by running the command:

    ```bash
    minikube delete -p knative
    ```
    !!! success "Example output"
        ```{ .bash .no-copy }
        🔥  Deleting "knative" in hyperkit ...
        💀  Removed all traces of the "knative" cluster.
        ```
