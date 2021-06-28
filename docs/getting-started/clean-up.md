## Clean Up

=== "kn"
    Delete the Service
    ```bash
    kn service delete cloudevents-player
    ```

    Delete the Trigger
    ```bash
    kn trigger delete cloudevents-trigger
    ```

=== "kubectl"
    Delete the Service
    ```bash
    kubectl delete -f cloudevents.yaml
    ```

    Delete the Trigger
    ```bash
    kubectl delete -f ce-trigger.yaml
    ```

Delete the Cluster
!!! info Delete your `konk` Cluster"
    ```bash
    kind delete clusters knative
    ```
!!! success "Verify Output"
    ```{ .bash .no-copy }
    Deleted clusters: ["knative"]
    ```
