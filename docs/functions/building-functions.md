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

### Prerequisites

- The function must exist in a Git repository.
- You must configure your cluster to use Tekton Pipelines. See the [on-cluster build](https://github.com/knative/func/blob/main/docs/reference/on_cluster_build.md){target=_blank} documentation.

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
