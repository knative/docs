---
audience: developer
components:
  - serving
  - eventing
function: tutorial
hide_next: true
---

# Clean Up

Delete the disposable cluster when you have finished experimenting. This removes **all workloads and data in that cluster**, including any Bookstore resources you added. Check `kubectl config current-context` first; do not delete a cluster you need to keep.

The chosen Quickstart route uses **kind**. The minikube instructions are retained for readers who selected that installation alternative.

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

If you used minikube, stop the `minikube tunnel` process with `Ctrl+C` as well.

**Previous:** [Next steps](next-steps.md) · **Return to:** [Tutorials](tutorial.md)
