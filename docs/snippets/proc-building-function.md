<!-- Snippet used in the following topics:
- /docs/getting-started/build-run-deploy-func.md
- /docs/functions/build-run-deploy-func.md
-->
The `build` command uses the image name and the image registry to build a container image for your function.

The `func.yaml` file is read to determine the image name and registry. If the function project has not previously been built, either the registry or the image name must be provided, and the image name is stored in the configuration `func.yaml` file.

=== "func"

    If you are rebuilding a function by using a previously supplied image from a local `func.yaml` file, run the following command:

    ```bash
    func build
    ```

    If you ned to specify the registry or image for a new function build, run one of the following commands inside the project directory:

    ```bash
    func build --registry <registry>
    ```

    ```bash
    func build --image <image-name>
    ```

=== "kn func"

    If you are rebuilding a function by using a previously supplied image from a local `func.yaml` file, run the following command:

    ```bash
    kn func build
    ```

    If you ned to specify the registry or image for a new function build, run one of the following commands inside the project directory:

    ```bash
    kn func build --registry <registry>
    ```

    ```bash
    kn func build --image <image-name>
    ```
