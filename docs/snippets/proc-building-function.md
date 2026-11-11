<!-- Snippet used in the following topics:
- versioned/getting-started/build-run-deploy-func.md
- versioned/functions/building-functions.md
-->
From the function project directory, `build` uses the project name and registry prefix to construct the image name, unless you supply an explicit `--image`. For the first build, provide `--registry` or `--image`, or answer the registry prompt when running interactively. Later builds can reuse the saved values.

=== "func"

    To build the function, run the following command:

    ```bash
    func build
    ```

=== "kn func"

    To build the function, run the following command:

    ```bash
    kn func build
    ```

!!! note
    The coordinates for the **image registry** can be configured through an environment variable (`FUNC_REGISTRY`) as well.

!!! tip "Private Registry Authentication"
    For private registries that require authentication, you can set credentials using environment variables:
    
    - `FUNC_USERNAME`: The username for registry authentication
    - `FUNC_PASSWORD`: The password for registry authentication
    
    These credentials apply to publishing the function image with `build --push`; an ordinary local build does not publish it. Authentication for fetching private builder/base images may use the selected builder's own configuration. Consult the `build` options in the [upstream command reference](https://github.com/knative/func/blob/main/docs/reference/func.md){target=_blank}.

    Avoid putting passwords in command-line arguments, which may be visible in process listings or shell history. Environment variables also require care; do not include secrets in diagnostic output.
