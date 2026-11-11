<!-- Snippet used in the following topics:
- versioned/getting-started/build-run-deploy-func.md
- versioned/functions/deploying-functions.md
-->
The `deploy` command uses the function project name as the Knative Service name. When the function is built, the project name and the image registry name are used to construct a fully qualified image name for the function.

Replace `<registry>` with your registry prefix. Complete the [Functions cluster-selection guard](../functions/deploying-functions.md#select-and-check-the-cluster) in this shell first; it defines `check_func_context` and `NAMESPACE`. The commands explicitly build locally (`--remote=false`) and select the Knative deployer, overriding remembered workflow choices. Those flags do not select a cluster.

=== "func"

    Deploy the function by running the command inside the project directory:

    ```bash
    check_func_context && func deploy --remote=false --deployer=knative \
      --registry <registry> --namespace "$NAMESPACE"
    ```

=== "kn func"

    Deploy the function by running the command inside the project directory:

    ```bash
    check_func_context && kn func deploy --remote=false --deployer=knative \
      --registry <registry> --namespace "$NAMESPACE"
    ```

!!! note
    The [raw Kubernetes alternative](../functions/deploying-functions.md#raw-kubernetes-alternative) creates different resources and requires Kubernetes Deployment/Service verification. It is separate from the Knative checks below.

!!! Success "Example deployment output"
    ```{ .bash .no-copy }
    🙌 Function image built: <registry>/hello:latest
    ✅ Function deployed in namespace "default" and exposed at URL:
    http://hello.default.127.0.0.1.sslip.io
    ```

    The namespace, URL, and build messages depend on your environment and whether a rebuild was needed. Use the URL reported by your deployment, not this example URL.

!!! tip "Private Registry Authentication"
    For private registries that require authentication, you can set credentials using environment variables:
    
    - `FUNC_USERNAME`: The username for registry authentication
    - `FUNC_PASSWORD`: The password for registry authentication
    
    These credentials are used for publishing the function image; cluster image-pull access is configured separately. See the `deploy` options in the [upstream command reference](https://github.com/knative/func/blob/main/docs/reference/func.md){target=_blank} for other authentication methods.

    Avoid putting passwords in command-line arguments, which may be visible in process listings or shell history. Environment variables also require care; do not include secrets in diagnostic output.

From the same project directory, explicitly invoke the **remote** instance. Without `--target=remote`, the CLI prefers a locally running instance, which would not verify this deployment:

=== "func"

    ```bash
    check_func_context && func invoke --target=remote
    ```

=== "kn func"

    ```bash
    check_func_context && kn func invoke --target=remote
    ```

!!! Success "Example response"
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

    Headers and response bodies depend on your environment and handler. Confirm your application's expected response, not just that the CLI received a response.
