## Clean Up 2

=== "kn"
    Delete the Service by running the command:

    ```bash
    kn service delete cloudevents-player
    ```

    Delete the Trigger by running the command:

    ```bash
    kn trigger delete cloudevents-trigger
    ```

=== "kubectl"
    Delete the Service by running the command

    ```bash
    kubectl delete -f cloudevents.yaml
    ```

    Delete the Trigger by running the command:

    ```bash
    kubectl delete -f ce-trigger.yaml
    ```

Delete the Cluster

Delete your `konk` Cluster" by running the command:
    ```bash
    kind delete clusters knative
    ```
!!! success "Verify Output"
    ```{ .bash .no-copy }
    Deleted clusters: ["knative"]
    ```
