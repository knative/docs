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

- You have a Docker daemon on your local machine. This is already provided if you have used the Quickstart installation.

### Procedure

--8<-- "proc-building-function.md"

## On-cluster Builds

If you do not have a local Docker daemon running, or you are using a CI/CD pipeline, you might want to build your function on the cluster instead of using a local build. `func deploy --remote` builds, publishes, and deploys the function; it is not a build-only command. The source can be uploaded from your local project or fetched from a Git repository.

### Prerequisites

For either source route:

- You have an initialized [function project](creating-functions.md) available locally, including its `func.yaml`. The CLI needs the local project even when the pipeline fetches source from Git.
- You have installed the `func` CLI or `kn func` plugin and selected the intended Knative Serving cluster and namespace.
- The cluster is configured with Tekton Pipelines and the namespace permissions needed to build and deploy functions. Follow the upstream [on-cluster setup guide for v1.23.0](https://github.com/knative/func/blob/knative-v1.23.0/docs/building-functions/on_cluster_build.md){target=_blank} for administrator setup and registry authentication. Check the corresponding release documentation for another CLI version.
- You can publish the image to your chosen registry, and the cluster can pull it.

**Local-source upload:** Your source is in the local function project. It does not need to be committed to a Git repository.

**Git-backed build:** Your source is committed and pushed to a repository accessible to the build pipeline. The local project metadata must correspond to the function you intend to build. Local uncommitted changes are not the source for this route.

### Procedure

Set the project path and registry prefix for the examples:

```bash
FUNCTION_PATH=hello
REGISTRY=ghcr.io/your-username
```

Replace these values with your initialized project directory and registry prefix. Choose one source route below; both use the selected cluster and namespace.

#### Upload local source

Explicitly clear the Git URL to select local-source upload, including when the project remembers an earlier Git-backed deployment:

=== "func"

    ```bash
    func deploy --remote --registry "$REGISTRY" --git-url="" -p "$FUNCTION_PATH"
    ```

=== "kn func"

    ```bash
    kn func deploy --remote --registry "$REGISTRY" --git-url="" -p "$FUNCTION_PATH"
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
    func deploy --remote --registry "$REGISTRY" --git-url "$GIT_URL" -p "$FUNCTION_PATH"
    ```

=== "kn func"

    ```bash
    kn func deploy --remote --registry "$REGISTRY" --git-url "$GIT_URL" -p "$FUNCTION_PATH"
    ```

Once the project has saved the Git URL, you can omit `--git-url` on later Git-backed remote deployments. Commit and push each source update first. For selecting a Git revision or a function in a repository subdirectory, consult the `deploy` options in the [upstream command reference]({{ funcdocs() }}){target=_blank}; do not assume the pipeline builds your current local branch.

### Verify the deployment

A successful remote deployment reports the function URL. Confirm the corresponding Knative Service is Ready in the intended namespace, then [invoke the deployed function](invoking-functions.md) to check its response. A successful build alone does not verify application behavior.

The distinction between uploaded local source and Git-backed source is documented in the [v1.23.0 deploy reference](https://github.com/knative/func/blob/knative-v1.23.0/docs/reference/func_deploy.md){target=_blank}. The command options remain maintained upstream rather than duplicated here.
