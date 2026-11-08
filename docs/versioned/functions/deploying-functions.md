---
audience: developer
components:
  - functions
function: how-to
---

# Deploying functions

--8<-- "deploy-func-intro.md"

## Prerequisites

For every **Knative Service** deployment route on this page:

- You have [installed the CLI](install-func.md). Project/source prerequisites depend on the route below; a local project is not required for every deployment.
- You have `kubectl` and a trusted kubeconfig for a cluster with Knative Serving installed, an existing target namespace, and permission to create or update the function's Knative Service. Complete the [cluster-selection guard](#select-and-check-the-cluster) before deployment.
- The cluster can pull the intended image. Private images do not need to be made public: configure [private registry access](../serving/deploying-from-private-registry.md) for the cluster. Publishing credentials on your machine do not automatically grant the cluster pull access.

Choose the additional prerequisites for your route:

- **Build and publish locally (procedure below):** [create/open an initialized local function project](creating-functions.md) and run commands from its directory containing `func.yaml`. Meet the [selected builder's prerequisites](building-functions.md#local-builds) and have write access to the chosen registry. A Docker-compatible daemon is needed for `pack`/`s2i`, not for every builder.
- **Use an already published image with local `--image`:** an initialized local project containing `func.yaml` is still required, but no local builder, Docker daemon, or registry write permission is required. Go directly to [Use an image that is already published](#use-an-image-that-is-already-published), after the cluster-selection guard.
- **Build on the cluster:** use the separate [on-cluster procedure](building-functions.md#on-cluster-builds) and its infrastructure/authentication prerequisites, not this local procedure. Local-source upload requires an initialized local project; explicit Git-reference `--source` uses a committed project/configuration in the repository and requires no local copy. Its manifest/deployer/namespace rules differ from the local routes.

The [raw Kubernetes alternative](#raw-kubernetes-alternative) has a different resource and verification scope; it is not a Knative Service deployment.

Deployment creates or updates the Service named by the project. Check the project's name and existing resources in the target namespace before deploying; do not use a Service owned by another application. If `func.yaml` records a different `deploy.namespace` or `deploy.deployer`, stop: a namespace change can remove the previous deployment, and v1.24 refuses in-place deployer changes. Migration between namespaces/deployers is outside this task.

## Select and check the cluster

--8<-- "func-cluster-context.md"

## Procedure

This route builds/publishes locally and explicitly selects the Knative deployer.

--8<-- "proc-deploying-function.md"

## Verify readiness and diagnose failures

Use the namespace reported by deployment and the project name in `func.yaml` for this read-only check:

```bash
FUNCTION_NAME=hello
check_func_context && kubectl --context "$EXPECTED_CONTEXT" get kservice "$FUNCTION_NAME" --namespace "$NAMESPACE"
check_func_context && kubectl --context "$EXPECTED_CONTEXT" describe kservice "$FUNCTION_NAME" --namespace "$NAMESPACE"
```

Replace `hello` with your project name. Keep the guarded kubeconfig/context and the namespace you selected for deployment; confirm that it matches the namespace reported by the command. Check the Service's Ready condition and URL, then use the remote invocation check above. Ready is not proof that the handler returns the intended result or that a Broker can deliver events.

- **Build failed:** return to the [build guide](building-functions.md) and check builder/toolchain requirements and dependency access.
- **Push failed:** check the image destination and your registry write credentials. A local build does not prove a push succeeded.
- **Service not Ready:** inspect its conditions, especially image pull and startup failures. Follow [Serving application diagnostics](../serving/troubleshooting/debugging-application-issues.md) or consult the cluster operator rather than repeatedly rebuilding an unchanged handler.
- **Service Ready, invocation failed:** check the reported URL, network/DNS access from your machine, and handler logs. Direct invocation does not verify the event-delivery route.

To receive events through a Broker, continue with [Subscribe functions to CloudEvents](subscribing-functions.md).

## Use an image that is already published

If this initialized project's intended image is already in a registry and pullable by the cluster, you can deploy it without local build/push tools or registry write access. In v1.24, local `func deploy --image` still requires an initialized project; supplying an image alone does not replace `func.yaml`. The manifest supplies the Service name and configuration, while this route's `--namespace` selects the destination. Stop on a saved deployment-namespace mismatch as above. Complete the [cluster-selection guard](#select-and-check-the-cluster) in this shell first:

=== "func"

    ```bash
    check_func_context && func deploy --remote=false --deployer=knative \
      --image ghcr.io/your-username/hello:tested \
      --build=false --push=false --namespace "$NAMESPACE"
    ```

=== "kn func"

    ```bash
    check_func_context && kn func deploy --remote=false --deployer=knative \
      --image ghcr.io/your-username/hello:tested \
      --build=false --push=false --namespace "$NAMESPACE"
    ```

Replace the image with your published artifact; `NAMESPACE` is the intended namespace from the guard setup. This route does not include local source changes. Verify readiness and invoke remotely as above. For an arbitrary application container without a Functions project, use [Serving's service deployment guide](../serving/services/creating-services.md) instead.

## Raw Kubernetes alternative

The `raw` deployer creates a Kubernetes Deployment and Service, **not** a Knative Service. This alternative requires a Kubernetes cluster and permissions for those resources, but not Knative Serving. Local builder/push requirements still apply when building and publishing; complete the same kubeconfig/current-context guard and check resource ownership before proceeding.

The v1.24 raw deployer defaults to cluster-local exposure; this example explicitly uses `--expose=none` to avoid a remembered exposure choice. OpenShift Route exposure (`--expose=route`) has separate platform, DNS, and TLS requirements covered upstream. A returned Service URL is not proof of access from your machine.

From the initialized project directory, replace `<registry>` with your writable registry prefix:

=== "func"

    ```bash
    check_func_context && func deploy --remote=false --registry <registry> \
      --namespace "$NAMESPACE" --deployer raw --expose=none
    ```

=== "kn func"

    ```bash
    check_func_context && kn func deploy --remote=false --registry <registry> \
      --namespace "$NAMESPACE" --deployer raw --expose=none
    ```

Do **not** use this page's `kservice` Ready/Knative URL checks to verify these resources. Inspect the Kubernetes Deployment's rollout/readiness and the Kubernetes Service's endpoints/access path, then test the handler through that path. Consult [Kubernetes Deployment verification](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#checking-the-status-of-a-deployment){target=_blank} and the `deploy` options in the [upstream command reference]({{ funcdocs() }}){target=_blank}; a raw deployment does not establish Knative routing or autoscaling.
