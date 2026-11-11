<!-- Snippet used in the following topics:
- versioned/getting-started/build-run-deploy-func.md
- versioned/functions/running-functions.md
-->
For a containerized local test, explicitly select the `pack` builder. It builds the image if needed and runs it locally; it does not publish the image or deploy a Service.

1. Open a terminal in the function project directory, for example `hello`:

    ```bash
    cd hello
    ```

1. Start the function. Replace the registry prefix with your image-naming prefix. If the project already has a registry or image configured, you can omit `--registry`.

    === "func"

        ```bash
        func run --builder=pack --registry ghcr.io/your-username
        ```

    === "kn func"

        ```bash
        kn func run --builder=pack --registry ghcr.io/your-username
        ```

    `FUNC_REGISTRY` can also provide the registry prefix. This is an image name, not a request to push it. Access to private builder images and dependencies is separate from publishing credentials.

    For containerized runs, add `--build` to force a rebuild, or `--build=false` to skip building only when a usable image already exists.

1. Wait for the command to report the local listening address. Leave this terminal running. In a **second terminal**, open the same project directory and explicitly invoke the local instance:

    === "func"

        ```bash
        func invoke --target=local
        ```

    === "kn func"

        ```bash
        kn func invoke --target=local
        ```

    Check the response and the running function's logs against your handler's expected behavior. Response bodies differ by language, template, and application code; cluster proxy headers are not expected for this local check.

1. When you finish testing, press **Ctrl+C** in the terminal running the function. This stops the local process; it does not delete a deployed Service.

For request formats, test payloads, and alternate targets, consult the `invoke` section of the [upstream command reference](https://github.com/knative/func/blob/main/docs/reference/func.md){target=_blank}.
