---
audience: developer
components:
  - functions
  - serving
  - eventing
function: tutorial
---

# Installing Knative using quickstart

This lesson creates the local environment used by all the [Quickstart lessons](README.md).

**Chosen route:** Start Docker, install `kind` and `kubectl`, then install the `kn` and `quickstart` binaries for your operating system using the **Using a binary** instructions below. If you already have these tools installed, verify them rather than reinstalling. Homebrew and source-build instructions remain available as alternatives.

When you reach **Run the Knative quickstart plugin**, use **Using kind** (`kn quickstart kind`). Do not run both cluster options. Port 80 must be available, and the plugin needs access to your Docker daemon as described below. Use a disposable environment; this is not an installation procedure for an existing shared cluster.

--8<-- "quickstart-prereqs.md"
--8<-- "install-kn.md"
--8<-- "quickstart-install.md"

## Next steps

First, **inspect** the selected Kubernetes context. This block does not change it:

```bash
kubectl config current-context
kubectl config get-contexts
```

Confirm that the selected context is the **newly created disposable Quickstart cluster**, normally `kind-knative`, and that it is the cluster you intend to use for the lessons. If another context is selected, stop before running the next block. After identifying the correct context from your installation output, select it with `kubectl config use-context <quickstart-context>` and repeat the inspection. Do not select a shared or production cluster. See [CLI cluster-access guidance](../client/connect-to-cluster.md) if you cannot identify the intended context.

**Only after approving the context**, set its default namespace and inspect the installed components:

```bash
kubectl config set-context --current --namespace=default
kubectl get pods -n knative-serving
kubectl get pods -n knative-eventing
```

Wait for the Serving and Eventing pods to become Ready before continuing; pod names vary by release.

**Previous:** [Quickstart route](README.md) · **Next:** [Deploy your first Service](first-service.md)
