# Clean Up

We recommend that you delete the cluster used for this tutorial to free up resources
on your local machine.

If you want to continue experimenting with Knative after deleting the cluster,
you can reinstall Knative on a new cluster using the [Quickstart plugin](quickstart-install.md) again.

## Delete the Cluster

=== "kind"

    Delete your `kind` Cluster by running the command:

    ```bash
    kind delete clusters knative
    ```
    !!! success "Verify Output"
        ```{ .bash .no-copy }
        Deleted clusters: ["knative"]
        ```

=== "minikube"

    Delete your `minikube` Cluster by running the command:

    ```bash
    minikube delete -p knative
    ```
    !!! success "Verify Output"
        ```{ .bash .no-copy }

        ```
