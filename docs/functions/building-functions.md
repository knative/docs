# Building functions

--8<-- "build-func-intro.md"

## Local builds

You can build a container image for your function locally without deploying it to a cluster, by using the `build` command.

### Prerequisites

- You have a Docker daemon on your local machine. This is already provided if you have used the Quickstart installation.

### Procedure

--8<-- "proc-building-function.md"

## On-cluster Builds

If you do not have a local Docker daemon running, or you are using a CI/CD pipeline, you might want to build your function on the cluster instead of using a local build. You can create an on-cluster build by using the `func deploy --remote` command.

!!! note
    If you're doing a direct-upload deployment (i.e. the source code is on your local machine instead of a git repo), you can create an on-cluster build without the need of specifying the Git URL, but if you already specified a Git URL before, you'll need to specify the flag as empty, using the command `func deploy --remote --git-url=""`

### Prerequisites

- The function must exist in a Git repository.
- You must configure your cluster to use Tekton Pipelines. See the [on-cluster build](https://github.com/knative/func/blob/main/docs/building-functions/on_cluster_build.md){target=_blank} documentation.

### Procedure

When running the command for the first time, you must specify the Git URL for the function:

=== "func"

    ```{ .console }
    func deploy --remote --registry <registry> --git-url <git-url> -p hello
    ```

=== "kn func"

    ```{ .console }
    kn func deploy --remote --registry <registry> --git-url <git-url> -p hello
    ```

After you have specified the Git URL for your function once, you can omit it in subsequent commands.
