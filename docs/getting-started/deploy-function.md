# Deploying a Knative Function

Deploy your function using the `func deploy` command. When deploying, your
function source code is built into an OCI container image and pushed to a
container registry and then deployed to your cluster as a Knative Service.

Deploying from a local build requires that you have a Docker daemon running
on your local computer. Additionally, you must have a Docker registry that you
can push to. Specify the registry using the `--registry` flag. Typically the
registry is specified as `<registry>/<username>`, for example
`docker.io/exampleuser`.

This command uses the function project name and the image registry name to
construct a fully qualified image name for your function.

=== "func"

    Deploy the function by running the command from within the function project directory:

    ```bash
    func deploy --registry <registry>
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
            🙌 Function image built: <registry>/hello:latest
            ✅ Function deployed in namespace "default" and exposed at URL:
            http://hello.default.127.0.0.1.sslip.io
        ```

    You can use the `func invoke` CLI command to ensure that your function has been
    successfully deployed.

    ```bash
    func invoke
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

That's it! You have now created and deployed your first Knative Function. To learn
more about local development with Knative Functions, see
[Next Steps with Knative Functions](../function-next-steps).
To learn how to integrate your function with Knative Eventing, see
[Function Triggers and Event Sources](../function-triggers).
Or view the [Command Line Reference](https://github.com/knative-sandbox/kn-plugin-func/blob/main/docs/reference/func.md)
for detailed descriptions of all CLI commands.
