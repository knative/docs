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

    The `host` path is experimental in Functions from Knative v1.24.0 and does not support every older Python project layout. Check the matching upstream language guide before using it. Choose a builder explicitly with `--builder` when the project's configuration does not match your environment.
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

This command can rebuild the image; it is not a push-only operation. It requires registry write access in addition to the selected builder's prerequisites. When changing from a local-only naming prefix to a publication destination, inspect any saved `image` override and `FUNC_IMAGE`: an explicit image takes precedence over the registry prefix. Select the intended destination with `--image` **instead of** `--registry` when an override is needed; supplying both flags is rejected. Check the reported full image name rather than assuming a new registry variable renamed it. Check the push result and the image tag/digest in your registry. A pushed image is not a deployed function. Continue with [Deploying functions](deploying-functions.md) when you want a Knative Service.

## On-cluster Builds

If you do not have a local Docker daemon running, or you are using a CI/CD pipeline, you might want to build your function on the cluster instead of using a local build. `func deploy --remote` builds, publishes, and deploys the function; it is not a build-only command. The source can be uploaded from your local project or fetched from a Git repository.

### Prerequisites

For either source route:

- You have installed Functions from Knative v1.24.0 and `kubectl`, and have a trusted kubeconfig for the intended Knative Serving cluster. Complete the effective kubeconfig/current-context guard below; explicit `--context` checks by other tools do not select a cluster for `func`.
- The cluster is configured with Tekton Pipelines and the namespace permissions needed to build and deploy functions. Follow the upstream [on-cluster setup guide for Functions from Knative v1.24.0](https://github.com/knative/func/blob/knative-v1.24.0/docs/building-functions/on_cluster_build.md){target=_blank} for administrator setup and registry authentication. The release uses `ghcr.io/knative/func-utils:1.24` for cluster-side tooling; administrators who mirror images must make that version available. If using func-operator, this release requires v0.4.0 or later; see the [release notes](https://github.com/knative/func/releases/tag/knative-v1.24.0){target=_blank}.
- The build pipeline can publish to the chosen registry, and the cluster can pull the result. The v1.24 Tekton provider accepts `pack` or `s2i` and rejects `host`; the examples below select `pack` explicitly. Its `pack` path also rejects additional entries in `build.buildpacks`. Meet the selected template/builder's cluster-side requirements rather than assuming local build support transfers to Tekton.

**Local-source upload:** You have an initialized [function project](creating-functions.md) locally, including `func.yaml`. Its source need not be committed to Git. Check its name, deployer, and saved deployment namespace before proceeding; stop if it belongs to another application or namespace.

**Git-backed build with explicit `--source`:** The repository contains a committed initialized project and `func.yaml`, and is accessible to both the CLI and build pipeline. Unlike the v1.23 workflow, this route needs **no local project**: configuration is read from the committed `func.yaml`. Review that file's project name, handler, build settings, deployer, and namespace before deploying. This guide expects `deployer: knative`. Local uncommitted changes are not built.

### Procedure

Select and guard the cluster in the same shell that will submit the remote deployment:

--8<-- "func-cluster-context.md"

Set the project path and registry prefix for the examples:

```bash
FUNCTION_PATH=hello
REGISTRY=ghcr.io/your-username
```

Replace the registry prefix with your publication destination. `FUNCTION_PATH` is used only for local-source upload. Choose one source route below; both use the guarded current context and explicitly pass `NAMESPACE` from the guard setup.

#### Upload local source

Explicitly clear the source URL to select local-source upload, including when the project remembers an earlier Git-backed deployment:

=== "func"

    ```bash
    check_func_context && func deploy --remote --builder=pack --deployer=knative \
      --namespace "$NAMESPACE" --registry "$REGISTRY" --source="" -p "$FUNCTION_PATH"
    ```

=== "kn func"

    ```bash
    check_func_context && kn func deploy --remote --builder=pack --deployer=knative \
      --namespace "$NAMESPACE" --registry "$REGISTRY" --source="" -p "$FUNCTION_PATH"
    ```

No repository URL is required for a first local-source deployment. The empty flag clears the project's saved `build.source.url` when the deployment succeeds.

#### Fetch source from Git

Set the repository URL for deployment by reference:

```bash
GIT_URL=https://github.com/your-org/your-function.git
```

Replace the example URL with your repository. Commit and push the intended source/configuration first.

**Before running**, inspect any explicit `image` in the committed `func.yaml` at the revision and repository directory you intend to deploy. It must name an authorized publication destination: `--registry` does **not** rename a committed explicit image, because the [v1.24 pipeline selects that image before deriving one from the registry](https://github.com/knative/func/blob/knative-v1.24.0/pkg/pipelines/tekton/pipelines_provider.go#L150-L159){target=_blank}. Stop if the destination is not authorized. Changing or removing the override requires the project owner's committed-configuration workflow; review, commit, and push that change before deployment. Do **not** add `--image` to this explicit Git-reference route—it is rejected.

From any directory, run:

=== "func"

    ```bash
    check_func_context && func deploy --remote --builder=pack --source "$GIT_URL" \
      --namespace "$NAMESPACE" --registry "$REGISTRY"
    ```

=== "kn func"

    ```bash
    check_func_context && kn func deploy --remote --builder=pack --source "$GIT_URL" \
      --namespace "$NAMESPACE" --registry "$REGISTRY"
    ```

This path reads the repository's configuration and does not save project or deployment state in your current directory. Supply `--source` again on subsequent deployments. To select a branch, tag, or full commit hash, add `--revision`; use `--source-dir` for a project below the repository root. With no revision, the repository's default branch is selected—not your local branch.

Only limited configuration overrides are accepted with an explicit non-empty `--source`: builder, registry, registry TLS setting, and namespace, plus supported authentication/control flags. **Do not add `--deployer`, `--path`, or `--image`** from the local-project examples; these are rejected. Equivalent unsupported `FUNC_*` environment settings can also cause rejection. Configure the deployer in the committed file instead. An explicit namespace conflicting with a namespace recorded in that file is rejected; stop and consult the project owner rather than treating `--namespace` as an unconditional override.

If a local project's `func.yaml` instead contains `build.source` and you omit `--source`, the pipeline fetches repository source using the **local project's configuration**. That distinct route still requires the local project. Consult the [upstream command reference]({{ funcdocs() }}){target=_blank} before choosing between these metadata sources.

Historically, Functions from Knative v1.23 used `--git-url`, `--git-branch`, `--git-dir`, and `build.git`. In v1.24 the flags are `--source`, `--revision`, and `--source-dir`; old `build.git` metadata is migrated on load to `build.source` (`contextDir` becomes `dir`). Do not use the historical flags with the current CLI.

### Verify the deployment

A successful remote deployment reports the function URL. Confirm the corresponding Knative Service is Ready in the intended namespace, then check the handler using its documented HTTP/CloudEvents request at that URL. A successful build alone does not verify application behavior.

After a deployment by repository reference there is no updated local project state. `func invoke`, even with a URL target, still requires an initialized local project; do not assume `--target=remote` can discover this deployment from an unrelated directory. Use an appropriate HTTP/CloudEvents client, or a corresponding local project with an explicit URL target as described in [Invoking functions](invoking-functions.md). The [deploy reference for Functions from Knative v1.24.0](https://github.com/knative/func/blob/knative-v1.24.0/docs/reference/func_deploy.md){target=_blank} remains authoritative for command options.
