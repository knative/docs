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

Check which Kubernetes context you will use before creating application resources:

```bash
kubectl config current-context
kubectl config set-context --current --namespace=default
kubectl get pods -n knative-serving
kubectl get pods -n knative-eventing
```

The context should be the newly created kind Quickstart cluster, normally `kind-knative`. If it points to another cluster, switch to the Quickstart context before continuing. Wait for the Serving and Eventing pods to become Ready; pod names vary by release.

**Previous:** [Quickstart route](README.md) · **Next:** [Deploy your first Service](first-service.md)
