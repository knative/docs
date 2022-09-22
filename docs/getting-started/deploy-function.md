# Deploying a Knative Function

Once your function has been built, you can deploy it to your cluster. The
command `func deploy` creates a Knative Service that runs your function.
Since the function has already been built, and you have not made any changes
to the code, you will set the `--build` flag to `false` to skip the build
process.

=== "func"

    Deploy the function by running the command from within the function project directory:

    ```bash
    func deploy --build=false
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
            ✅ Function deployed in namespace "default" and exposed at URL:
            http://viewer.default.127.0.0.1.sslip.io
        ```
