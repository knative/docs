<!-- Snippet used in the following topics:
- /docs/getting-started/build-run-deploy-func.md
- /docs/functions/build-run-deploy-func.md
-->
The `run` command builds an image for your function if required, and runs this image locally, instead of deploying it on a cluster.

=== "func"

    Run the function locally, by running the command inside the project directory:

    ```bash
    func run
    ```

    Using this command also builds the function if necessary.

    You can force a rebuild of the image by running the command:

    ```bash
    func run --build
    ```

    It is also possible to disable the build, by running the command:

    ```bash
    func run --build=false
    ```

=== "kn func"

    Run the function locally, by running the command inside the project directory:

    ```bash
    kn func run
    ```

    Using this command also builds the function if necessary.

    You can force a rebuild of the image by running the command:

    ```bash
    kn func run --build
    ```

    It is also possible to disable the build, by running the command:

    ```bash
    kn func run --build=false
    ```
