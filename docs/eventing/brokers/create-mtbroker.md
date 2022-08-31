# Creating a broker

Once you have installed Knative Eventing, you can create an instance of the multi-tenant (MT) channel-based broker that is provided by default. The default backing channel type for an MT channel-based broker is InMemoryChannel.

You can create a broker by using the `kn` CLI or by applying YAML files using `kubectl`.

=== "kn"

    1. You can create a broker in current namespace by entering the following command:

        ```bash
        kn broker create <broker-name> -n <namespace>
        ```

        !!! note
            If you choose not to specify a namespace, the broker will be created in the current namespace.

    1. Optional: Verify that the broker was created by listing existing brokers. Enter the following command:

        ```bash
        kn broker list
        ```

    1. Optional: You can also verify the broker exists by describing the broker you have created. Enter the following command:

        ```bash
        kn broker describe <broker-name>
        ```


=== "kubectl"

    The YAML in the following example creates a broker named `default` in the current namespace.

    1. Create a broker in the current namespace by creating a YAML file using the
    following template:

        ```yaml
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        metadata:
         name: <broker-name>
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

    1. Optional: Verify that the broker is working correctly, by entering the following command:

        ```bash
        kubectl -n <namespace> get broker <broker-name>
        ```

        This shows information about your broker. If the broker is working correctly, it shows a `READY` status of `True`:

        ```{ .bash .no-copy }
        NAME      READY   REASON   URL                                                                                 AGE
        default   True             http://broker-ingress.knative-eventing.svc.cluster.local/event-example/default      1m
        ```

        If the `READY` status is `False`, wait a few moments and then run the command again.
