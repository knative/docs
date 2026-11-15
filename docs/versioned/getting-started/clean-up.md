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
Delete it only when you have finished experimenting.

## Delete the cluster

The shared setup guide creates a kind cluster named `knative`. Deleting it removes
**all applications and data in that cluster**, including work from every tutorial.
This command does not delete the other clusters on your machine:

```bash
kind delete cluster --name knative
```

Only run this for your disposable learning cluster, not a cluster you use for
other work. If you used a different name, substitute that name. After deletion,
switch back to your usual Kubernetes context before doing other cluster work.

??? note "Used the older minikube Quickstart?"

    If you created the disposable `knative` minikube profile instead of a kind
    cluster, delete that profile with:

    ```bash
    minikube delete -p knative
    ```

## Stop a local function

If `func run` is still running, press **Ctrl+C** in its terminal. Your function's
source files stay on your machine. Keep them if you want to continue developing.
The local container image also remains until you remove it from Docker.

If you completed the optional deployment lesson, the image you pushed remains
in your registry even after deleting the cluster. Remove that tutorial image
using your registry's interface if you no longer need it.

You can return to [Get Started](../README.md) at any time. To repeat a cluster-based
tutorial after deleting the cluster, [create a new learning environment](quickstart-install.md).
