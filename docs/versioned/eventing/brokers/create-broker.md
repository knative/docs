---
audience: developer
components:
  - eventing
function: how-to
---

# Creating a Broker

Once you have installed Knative Eventing and a Broker implementation, you can create an instance of a Broker.

!!! note
    Knative Eventing provides by default the [MTChannelBasedBroker](./broker-types/channel-based-broker/README.md). Its default backing channel is the [`InMemoryChannel`](https://github.com/knative/eventing/blob/main/config/channels/in-memory-channel/README.md). `InMemoryChannel` should not be used in production. Other Broker types and their configuration options can be found under [Available Broker types](./broker-types/README.md).

You can create a Broker by using the `kn` CLI or by applying YAML files using `kubectl`.

=== "kn"

    1. You can create a Broker by entering the following command:

        ```bash
        kn broker create <broker-name> -n <namespace>
        ```
 
        This will create a new Broker of your default Broker class and default Broker configuration (both defined in the `config-br-defaults` ConfigMap).
 
        !!! note
            If you omit the namespace, the Broker is created in the current namespace.
            Omit the namespace flag in both verification commands too, or explicitly
            use that same namespace.
 
        !!! note
            If you have multiple Broker classes installed in your cluster, you can specify the Broker class via the `--class` parameter, e.g.:
 
            ```bash
            kn broker create <broker-name> -n <namespace> --class MTChannelBasedBroker
            ```

    1. Verify the Broker in the same namespace used for creation:

        ```bash
        kn broker list -n <namespace>
        ```

        Find `<broker-name>` and check that `READY` is `True`. If it is `False`,
        wait and repeat the check, or inspect its condition messages below.

    1. Optional: You can also verify the Broker exists by describing the Broker you have created:

        ```bash
        kn broker describe <broker-name> -n <namespace>
        ```

=== "kubectl"

    Supply the Broker name and namespace in this YAML template, then use those
    same values in the verification command.

    1. Create a Broker by creating a YAML file using the following template:

        ```yaml
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        metadata:
          name: <broker-name>
          namespace: <namespace>
        ```
 
        This creates a new Broker using the default Broker class and default Broker configuration, both of which are defined in the `config-br-defaults` ConfigMap.

    1. Apply the YAML file:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

    1. Optional: Verify that the Broker is working correctly:

        ```bash
        kubectl -n <namespace> get broker <broker-name>
        ```
 
        This shows information about your Broker. If the Broker is working correctly, it shows a `READY` status of `True`:
 
        ```bash
        NAME      READY   REASON   URL                                                                        AGE
        default   True             http://broker-ingress.knative-eventing.svc.cluster.local/default/default   1m
        ```
 
        If the `READY` status is `False`, wait a few moments and then run the command again.
