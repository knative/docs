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

**Chosen route for Knative v1.24:** Start Docker, install `kind` and `kubectl`, then use the **Using a binary** instructions below to install the [`kn` v1.24 release](https://github.com/knative/client/releases/tag/knative-v1.24.0) and [`quickstart` v1.24 release](https://github.com/knative-extensions/kn-plugin-quickstart/releases/tag/knative-v1.24.0) for your operating system and architecture. Do not assume an existing v1.23 binary matches this lesson. Homebrew and source-build instructions remain as alternatives, not additional steps.

The selected Quickstart source recommends **kind 0.30 or newer** and **kubectl 1.35 or newer**, and defaults to `kindest/node:v1.35.0`. For this route, use a **kubectl 1.35.x client** to match that default cluster version. The plugin warns and offers a not-recommended continuation with an older client; this tutorial does not choose that override. These are the selected plugin's source-checked prerequisites, not a general Knative compatibility matrix. See the [version checks](https://github.com/knative-extensions/kn-plugin-quickstart/blob/knative-v1.24.0/pkg/install/install.go) and [kind defaults](https://github.com/knative-extensions/kn-plugin-quickstart/blob/knative-v1.24.0/pkg/kind/kind.go).

When you reach **Run the Knative quickstart plugin**, use **Using kind** (`kn quickstart kind`). Do not run both cluster options. Port 80 must be available, and the plugin needs access to your Docker daemon as described below. Use a disposable environment; this is not an installation procedure for an existing shared cluster.

--8<-- "quickstart-prereqs.md"
--8<-- "install-kn.md"
--8<-- "quickstart-install.md"

## Next steps

Check the versions of the tools used for this installation:

```bash
kn version
kn quickstart version
kubectl version --client -o json
kind version
```

The selected `kn` and Quickstart release versions are `1.24.0`; check the kubectl client's `gitVersion` for `v1.35.x` and the kind version against the prerequisites above. Also check the installer's reported Serving, Kourier, and Eventing versions: a plugin's version label alone is not proof of which components were installed. Historical v1.23 runtime results do not validate this new installation.

Next, **inspect** the selected Kubernetes context. This block does not change it:

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
