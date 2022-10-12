<!-- Snippet used in the following topics:
- /docs/concepts/eventing-resources/brokers.md
-->
After you have installed Knative Functions, you can create a function project by using the `func` CLI or the `kn func` plugin:

=== "`func` CLI"

    ```bash
    func create -l go hello
    ```

=== "`kn func` plugin"

    ```bash
    kn func create -l go hello
    ```

!!! Success "Expected output"

    ```{ .bash .no-copy }
    Created go function in hello
    ```
