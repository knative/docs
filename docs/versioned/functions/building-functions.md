---
audience: developer
components:
  - functions
function: how-to
---

# Building functions

--8<-- "build-func-intro.md"

## Local builds

You can build a container image for your function locally without deploying it to a cluster, by using the `build` command.

### Prerequisites

- You have [installed the CLI](install-func.md) and [created a function project](creating-functions.md). Run the commands from that project directory, which contains `func.yaml`.
- You have the tools required by the selected builder:

    | Builder | Local requirement |
    | --- | --- |
    | `pack` or `s2i` | A running Docker-compatible daemon and access to the builder images and application dependencies. |
    | `host` | A supported Go or Python project and its local language toolchain/dependencies. This builder assembles an OCI image without a Docker daemon. |

    The `host` path is experimental in Functions from Knative v1.23.0 and does not support every older Python project layout. Check the matching upstream language guide before using it. Choose a builder explicitly with `--builder` when the project's configuration does not match your environment.
- You have a registry prefix or an explicit image name for the resulting image. Naming the image does not itself require publishing it. Registry credentials may still be needed to fetch private builder or base images.

### Procedure

--8<-- "proc-building-function.md"

### Verify the local build

Check that the command succeeds and reports the intended image name. Confirm the image and builder settings in `func.yaml`; a successful build does not verify that the handler works. Next, [run and invoke the function locally](running-functions.md).

If the build fails, check the selected builder's daemon or language-toolchain requirement, dependency downloads, and builder/base-image access. Use `--verbose` for diagnostics, but redact credentials and sensitive application data before sharing output.

## Publish without deploying

To build and push an image without creating a Knative Service, add `--push` to `build`. From the initialized project directory, replace the registry prefix below with a destination you can publish to:

=== "func"

    ```bash
    func build --registry ghcr.io/your-username --push
    ```

=== "kn func"

    ```bash
    kn func build --registry ghcr.io/your-username --push
    ```

This command can rebuild the image; it is not a push-only operation. It requires registry write access in addition to the selected builder's prerequisites. Check the push result and the image tag/digest in your registry. A pushed image is not a deployed function. Continue with [Deploying functions](deploying-functions.md) when you want a Knative Service.

## On-cluster Builds

If you do not have a local Docker daemon running, or you are using a CI/CD pipeline, you might want to build your function on the cluster instead of using a local build. `func deploy --remote` builds, publishes, and deploys the function; it is not a build-only command. The source can be uploaded from your local project or fetched from a Git repository.

### Prerequisites

For either source route:

- You have an initialized [function project](creating-functions.md) available locally, including its `func.yaml`. The CLI needs the local project even when the pipeline fetches source from Git.
- You have installed the `func` CLI or `kn func` plugin and `kubectl`, and have a trusted kubeconfig for the intended Knative Serving cluster. Complete the effective kubeconfig/current-context guard below; explicit `--context` checks by other tools do not select a cluster for `func`.
- The cluster is configured with Tekton Pipelines and the namespace permissions needed to build and deploy functions. Follow the upstream [on-cluster setup guide for Functions from Knative v1.23.0](https://github.com/knative/func/blob/knative-v1.23.0/docs/building-functions/on_cluster_build.md){target=_blank} for administrator setup and registry authentication. Check the corresponding release documentation for another CLI version.
- You can publish the image to your chosen registry, and the cluster can pull it.

**Local-source upload:** Your source is in the local function project. It does not need to be committed to a Git repository.

**Git-backed build:** Your source is committed and pushed to a repository accessible to the build pipeline. The local project metadata must correspond to the function you intend to build. Local uncommitted changes are not the source for this route.

### Procedure

Select and guard the cluster in the same shell that will submit the remote deployment:

--8<-- "func-cluster-context.md"

Set the project path and registry prefix for the examples:

```bash
FUNCTION_PATH=hello
REGISTRY=ghcr.io/your-username
```

Replace these values with your initialized project directory and registry prefix. Choose one source route below; both use the guarded current context and explicitly pass `NAMESPACE` from the guard setup.

#### Upload local source

Explicitly clear the Git URL to select local-source upload, including when the project remembers an earlier Git-backed deployment:

=== "func"

    ```bash
    check_func_context && func deploy --remote --deployer=knative \
      --namespace "$NAMESPACE" --registry "$REGISTRY" --git-url="" -p "$FUNCTION_PATH"
    ```

=== "kn func"

    ```bash
    check_func_context && kn func deploy --remote --deployer=knative \
      --namespace "$NAMESPACE" --registry "$REGISTRY" --git-url="" -p "$FUNCTION_PATH"
    ```

No Git URL is required for a first local-source deployment. The empty flag also clears a previously saved Git URL for the project.

#### Fetch source from Git

Set the repository URL before the first Git-backed deployment:

```bash
GIT_URL=https://github.com/your-org/your-function.git
```

Replace the example URL with your repository. Commit and push the intended source before running:

=== "func"

    ```bash
    check_func_context && func deploy --remote --deployer=knative \
      --namespace "$NAMESPACE" --registry "$REGISTRY" --git-url "$GIT_URL" -p "$FUNCTION_PATH"
    ```

=== "kn func"

    ```bash
    check_func_context && kn func deploy --remote --deployer=knative \
      --namespace "$NAMESPACE" --registry "$REGISTRY" --git-url "$GIT_URL" -p "$FUNCTION_PATH"
    ```

Once the project has saved the Git URL, you can omit `--git-url` on later Git-backed remote deployments. Commit and push each source update first. For selecting a Git revision or a function in a repository subdirectory, consult the `deploy` options in the [upstream command reference]({{ funcdocs() }}){target=_blank}; do not assume the pipeline builds your current local branch.

### Verify the deployment

A successful remote deployment reports the function URL. Confirm the corresponding Knative Service is Ready in the intended namespace, then [invoke the deployed function](invoking-functions.md) to check its response. A successful build alone does not verify application behavior.

The distinction between uploaded local source and Git-backed source is documented in the [deploy reference for Functions from Knative v1.23.0](https://github.com/knative/func/blob/knative-v1.23.0/docs/reference/func_deploy.md){target=_blank}. The command options remain maintained upstream rather than duplicated here.
