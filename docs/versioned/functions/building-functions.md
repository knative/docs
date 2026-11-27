---
audience: developer
components:
  - functions
function: how-to
---

# Building functions

Build a container image from an existing function project. The local procedure
builds only: it does not run, publish, or deploy the function. The optional
on-cluster workflow below builds **and deploys**, so choose it only when you want
that result.

## Local builds

### Prerequisites

- You have an initialized function project containing `func.yaml` and its source.
  [Create a project](creating-functions.md) if needed.
- Docker is running for the container-based buildpacks builder used here.
- Run these commands from that project directory, not its parent directory.

### Procedure

Set an explicit local image name so the build does not need a registry prompt:

=== "func"

    ```bash
    func build --builder pack \
      --image localhost/my-function:latest
    ```

=== "kn func"

    ```bash
    kn func build --builder pack \
      --image localhost/my-function:latest
    ```

`my-function` is an example image name; substitute yours consistently if desired.
`localhost` here is a local tag, not a registry server you must create. Wait for
building to complete, then check the image in Docker:

```bash
docker image ls localhost/my-function:latest
```

A row with the tag `latest` and an image ID identifies the built image. This does
not mean it was pushed or started. For publishing, see the
[deployment guide](deploying-functions.md#procedure), which explains registry
prefixes and full image destinations. [Try Functions](../getting-started/about-knative-functions.md#run-and-test)
shows how to run and test an image as a separate step. For other builders, image
naming options, and flags, see the [func build reference](https://github.com/knative/func/blob/main/docs/reference/func_build.md).

## On-cluster Builds

This alternative uses a remote pipeline and deploys the resulting function.
It avoids a local container build, but requires a configured cluster and registry
credentials. The source can come from Git **or** direct upload; Git is not required
for the direct-upload branch.

### Prerequisites

- Your kubeconfig selects a cluster with Knative Serving installed.
- Tekton Pipelines and the function build pipeline are configured according to the
  [on-cluster build setup guide](https://github.com/knative/func/blob/main/docs/building-functions/on_cluster_build.md).
- The pipeline can push to your chosen registry, and the cluster can pull the image.
  Complete the registry/credential setup in that guide rather than assuming local
  Docker login alone configures every remote pipeline.
- You have an initialized local function project and are in its directory.

### Procedure

Choose the source branch below. Replace `REGISTRY-USER` with your Docker Hub
account namespace in the image name. For Git, separately replace `GIT-OWNER` and
`GIT-REPO` with the repository owner and name; the Git owner need not match your
registry account. The explicit image destination avoids carrying over a local-only
tag from an earlier build.

#### Git-backed source

The function project must be committed in a Git repository the pipeline can read.
For a private repository, your platform administrator must provision pipeline
access before you use this branch; the linked function-build setup guide does
not provide a private-Git authentication recipe. The [Tekton authentication guide](https://tekton.dev/docs/pipelines/auth/)
is background for that platform setup. If you cannot arrange repository access,
use direct upload instead.

These commands assume the project is at the repository root. For a subdirectory,
set `build.source.dir` in your project's `func.yaml` to its relative path, following
the configuration example in the [on-cluster build guide](https://github.com/knative/func/blob/main/docs/building-functions/on_cluster_build.md).
For example, `dir: functions/my-function` selects that directory within the Git repository.

=== "func"

    ```bash
    func deploy --remote \
      --image docker.io/REGISTRY-USER/my-function:latest \
      --git-url https://github.com/GIT-OWNER/GIT-REPO
    ```

=== "kn func"

    ```bash
    kn func deploy --remote \
      --image docker.io/REGISTRY-USER/my-function:latest \
      --git-url https://github.com/GIT-OWNER/GIT-REPO
    ```

#### Direct-upload source

Use this branch to upload the current local project. No Git repository is required.
Passing an empty Git URL explicitly clears a previously configured Git source.
If you previously set `build.source.dir` for a Git subdirectory, remove that `dir`
entry from `build.source` too so the upload uses the current local project root:

=== "func"

    ```bash
    func deploy --remote \
      --image docker.io/REGISTRY-USER/my-function:latest \
      --git-url=""
    ```

=== "kn func"

    ```bash
    kn func deploy --remote \
      --image docker.io/REGISTRY-USER/my-function:latest \
      --git-url=""
    ```

Wait for the pipeline and deployment to finish. Verify the **deployed** function
using `func invoke --target remote` (or `kn func invoke --target remote`) and
check your function's expected response. A finished image build alone does not
prove deployment or invocation succeeded.
