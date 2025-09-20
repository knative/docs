<!-- Snippet used in the following topics:
- versioned/getting-started/build-run-deploy-func.md
- versioned/functions/building-functions.md
-->
The `build` command uses the project name and the image registry name to construct a fully qualified container image name for the function. If the function project has not previously been built, you are prompted to provide an **image registry**.

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
