---
audience: developer
components:
  - functions
  - serving
  - eventing
function: tutorial
hide_prev: true
hide_next: true
---

<span id="clean-up"></span>

# Clean up your environment

Keep your learning environment if you want to [try another track](next-steps.md).
When you have finished experimenting, clean up only the resources you created.
If you followed only the local Functions lessons, there is no cluster to delete.

## Stop a local function

If `func run` is still running, press **Ctrl+C** in its terminal. Your function's
source files stay on your machine. Keep them if you want to continue developing.
The local container image also remains until you remove it from Docker.

If you did not run a function locally, skip this step.

## Delete the cluster

Do this only if you created a disposable cluster and no longer need it.
The shared setup guide creates a kind cluster named `knative`. Deleting it removes
**all applications and data in that cluster**, including work from every tutorial.
This command does not delete the other clusters on your machine:

```bash
kind delete cluster --name knative
```

If you used a different name, substitute that name. Do not delete a cluster you
use for other work. After deletion, switch back to your usual Kubernetes context
before doing other cluster work.

??? note "Used the older minikube Quickstart?"

    If you created the disposable `knative` minikube profile instead of a kind
    cluster, delete that profile with:

    ```bash
    minikube delete -p knative
    ```

## Remove a published image

If you completed the optional Functions deployment lesson, the image you pushed
remains in your registry even after deleting the cluster. Remove that tutorial
image using your registry's interface if you no longer need it.

You can return to [Get Started](../README.md) at any time. To repeat a cluster-based
tutorial after deleting the cluster, [create a new learning environment](quickstart-install.md).
