<!-- Snippet used in the following topics:
- /docs/getting-started/build-run-deploy-func.md
- /docs/functions/deploying-functions.md
-->
The `deploy` command uses the function project name as the Knative Service name. When the function is built, the project name and the image registry name are used to construct a fully qualified image name for the function.

=== "func"

    Deploy the function by running the command inside the project directory:

    ```bash
    func deploy --registry <registry>
    ```

=== "kn func"

    Deploy the function by running the command inside the project directory:

    ```bash
    kn func deploy --registry <registry>
    ```

!!! Success "Expected output"
    ```{ .bash .no-copy }
        🙌 Function image built: <registry>/hello:latest
        ✅ Function deployed in namespace "default" and exposed at URL:
        http://hello.default.127.0.0.1.sslip.io
    ```

You can verify that your function has been successfully deployed by using the `invoke` command and observing the output:

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
