<!-- Snippet used in the following topics:
- /docs/concepts/eventing-resources/brokers.md
-->
After you have installed Knative Functions, you can create a function project by using the `func` CLI or the `kn func` plugin:

=== "`func` CLI"

    ```bash
    func create -l <language> <function-name>
    ```

    Example:

    ```bash
    func create -l go hello
    ```

=== "`kn func` plugin"

    ```bash
    kn func create -l <language> <function-name>
    ```

    Example:

    ```bash
    kn func create -l go hello
    ```

!!! Success "Expected output"

    ```{ .bash .no-copy }
    Created go function in hello
    ```

For more information about options for function `create` commands, see the [func create](https://github.com/knative/func/blob/main/docs/reference/func_create.md){target=_blank} documentation.
