<!-- Snippet used in the following topics:
- /docs/getting-started/build-run-deploy-func.md
- /docs/functions/running-functions.md
-->
The `run` command builds an image for your function if required, and runs this image locally, instead of deploying it on a cluster.

=== "func"

    Run the function locally by running the command inside the project directory. If you have not yet built the function you will need to provide the `--registry` flag:

    ```bash
    cd hello
    ```

    ```bash
    func run [--registry <registry>]
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
    cd hello
    ```

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

You can verify that your function has been successfully run by using the `invoke` command and observing the output:

=== "func"

    ```bash
    func invoke
    ```

=== "kn func"

    ```bash
    kn func invoke
    ```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    Received response
    POST / HTTP/1.1 hello.default.127.0.0.1.sslip.io
      User-Agent: Go-http-client/1.1
      Content-Length: 25
      Accept-Encoding: gzip
      Content-Type: application/json
      K-Proxy-Request: activator
      X-Request-Id: 9e351834-0542-4f32-9928-3a5d6aece30c
      Forwarded: for=10.244.0.15;proto=http
      X-Forwarded-For: 10.244.0.15, 10.244.0.9
      X-Forwarded-Proto: http
    Body:
    ```
