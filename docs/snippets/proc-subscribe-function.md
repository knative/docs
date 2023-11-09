<!-- Snippet used in the following topics:
- /docs/functions/subscribing-functions.md
-->
The `subscribe` command will connect the function to a set of events, matching a series of filters for Cloud Event metadata
and a Knative Broker as the source of events, from where they are consumed.

=== "func"

    To subscribe the function to events for a given broker, run the following command:

    ```bash
    func subscribe --filter type=com.example --filter extension=my-extension-value --source my-broker
    ```

    To subscribe the function to events for the default broker, run the following command:

    ```bash
    func subscribe --filter type=com.example --filter extension=my-extension-value
    ```

=== "kn func"

    To subscribe the function to events for a given broker, run the following command:

    ```bash
    kn func subscribe --filter type=com.example --filter extension=my-extension-value --source my-broker
    ```

    To subscribe the function to events for the default broker, run the following command:

    ```bash
    kn func subscribe --filter type=com.example --filter extension=my-extension-value
    ```

!!! note
    When invoking `func deploy` the CLI will create Knative Triggers for the function.

!!! Success "Expected output"
    ```{ .bash .no-copy }
        🙌 Function image built: <registry>/hello:latest
        🎯 Creating Triggers on the cluster
        ✅ Function deployed in namespace "default" and exposed at URL:
        http://hello.default.127.0.0.1.sslip.io
    ```
