# Deploying a Knative Function

Deploy your function using the `func deploy` command. When deploying, your
function source code is built into an OCI container image, pushed to a
container registry and then deployed to your cluster as a Knative Service.

If you followed the [Quickstart](./quickstart-install.md) section of the tutorial,
you should already have a Docker daemon on your local machine.
Deploying from a local build requires that you have this available.
Additionally, you must have a Docker registry that you
can push to. In the commands shown below, you will indicate the registry using the `--registry` flag. Typically the
registry is specified as `<registry>/<username>`, for example
`docker.io/exampleuser`.

This command uses the function project name and the image registry name to
construct a fully qualified image name for your function.

Deploy the function by running the command from within the project directory:

=== "func"

    ```{ .console}
    func deploy --registry <registry>
    ```

=== "kn func"

    ```{ .console }
    kn func deploy --registry <registry>
    ```

!!! Success "Expected output"
    ```{ .console .no-copy }
        🙌 Function image built: <registry>/hello:latest
        ✅ Function deployed in namespace "default" and exposed at URL:
        http://hello.default.127.0.0.1.sslip.io
    ```

You can use the `func invoke` CLI command to ensure that your function has been
successfully deployed.

=== "func"

    ```{ .console}
    func invoke
    ```

=== "kn func"

    ```{ .console }
    kn func invoke
    ```

!!! Success "Expected output"
    ```{ .console .no-copy }
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

Next, you will learn how to integrate a function with Knative event sources.
