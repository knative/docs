# Building a Knative Function

Before a function can be deployed, it must be built. The `func build` command
creates an OCI container image that can be run locally on your computer or on
a Kubernetes cluster with Knative. Knative functions use multiple strategies to
build container images, including S2I and Cloud Native Buildpacks, both locally
and on the cluster. In this tutorial, you will use the `func build` command to
build a function locally using Cloud Native Buildpacks.

Building locally requires you to have a Docker daemon running on your local
machine. Additionally, you must have a Docker registry that you can push to.
You can use any registry that you want. Specify the registry by using the
`--registry` flag. Typically the registry is specified as
`<registry>/<username>/`, for example `docker.io/exampleuser`.

This command uses the function project name and the image registry name to construct a fully qualified image name for your function.

=== "func"

    Build the function by running the command from within the function project directory:

    ```bash
    func build --registry <registry>
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
           🙌 Function image built: <registry>/hello:latest
        ```
