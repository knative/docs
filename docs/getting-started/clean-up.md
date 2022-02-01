# Clean Up

You can delete your cluster to free up resources.
If you need to, it's really fast to install Knative again on a new cluster using Quickstart!

Alternatively, you can continue to use this cluster for [further experimentation](next-steps.md).

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
