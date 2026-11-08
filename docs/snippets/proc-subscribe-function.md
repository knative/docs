<!-- Snippet used in the following topics:
- versioned/functions/subscribing-functions.md
-->
From the function project directory, use `subscribe` to save Broker subscriptions and exact-match CloudEvents attribute filters in `func.yaml`. Deploy afterward to create the corresponding Triggers. Here, `--source` is the **Broker name**, not the event's CloudEvents `source` attribute.

Choose **one Broker** for this procedure. Replace `my-broker` and the example filter values with your Broker and producer's event attributes. To use a Ready Broker named `default`, substitute `--source default` in the same command rather than running another subscription command. Both example filters must match. Repeating `subscribe` for the same Broker merges filter keys into that local subscription, replacing values for matching keys; it does not clear other keys. Inspect the saved configuration before deploying.

=== "func"

    To subscribe the function to events for a given broker, run the following command:

    ```bash
    func subscribe --filter type=com.example --filter extension=my-extension-value --source my-broker
    ```

=== "kn func"

    To subscribe the function to events for a given broker, run the following command:

    ```bash
    kn func subscribe --filter type=com.example --filter extension=my-extension-value --source my-broker
    ```
