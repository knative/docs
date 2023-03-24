# Creating a broker

Once you have installed Knative Eventing and a Broker implementation, you can create an instance of a Broker.

!!! note
    Knative Eventing provides by default the [multi-tenant (MT) channel-based broker](./broker-types/mt-channel-based-broker/README.md). Its default backing channel is the `InMemoryChannel`. Other broker types and their configuration options can be found under [broker types](./broker-types/README.md).

You can create a broker by using the `kn` CLI or by applying YAML files using `kubectl`.

=== "kn"

    1. You can create a broker by entering the following command:

        ```bash
        kn broker create <broker-name> -n <namespace>
        ```
 
        This will create a new Broker of your default broker class and default broker configuration (both defined in the `config-br-defaults` ConfigMap).
 
        !!! note
            If you choose not to specify a namespace, the broker will be created in the current namespace.
 
        !!! note
            If you have multiple Broker classes installed in your cluster, you can specify the broker class via the `--class` parameter, e.g.:
 
            ```bash
            kn broker create <broker-name> -n <namespace> --class MTChannelBasedBroker
            ```

    1. Optional: Verify that the broker was created by listing existing brokers:

        ```bash
        kn broker list
        ```

    1. Optional: You can also verify the broker exists by describing the broker you have created:

        ```bash
        kn broker describe <broker-name>
        ```

=== "kubectl"

    The YAML in the following example creates a broker named `default`.

    1. Create a Broker by creating a YAML file using the following template:

        ```yaml
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        metadata:
          name: <broker-name>
          namespace: <namespace>
        ```
 
        This will create a new Broker of your default broker class and default broker configuration (both defined in the `config-br-defaults` ConfigMap).

    1. Apply the YAML file:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

    1. Optional: Verify that the broker is working correctly:

        ```bash
        kubectl -n <namespace> get broker <broker-name>
        ```
 
        This shows information about your broker. If the broker is working correctly, it shows a `READY` status of `True`:
 
        ```bash
        NAME      READY   REASON   URL                                                                        AGE
        default   True             http://broker-ingress.knative-eventing.svc.cluster.local/default/default   1m
        ```
 
        If the `READY` status is `False`, wait a few moments and then run the command again.

## Broker class options

When a Broker is created without a specified `eventing.knative.dev/broker.class` annotation, the default `MTChannelBasedBroker` Broker class is used, as specified by default in the `config-br-defaults` ConfigMap. 

In case you have multiple Broker classes installed in your cluster and want to use a non-default Broker class for a Broker, you can modify the `eventing.knative.dev/broker.class` annotation and `spec.config` for the Broker object.

1. Modify the `eventing.knative.dev/broker.class` annotation. Replace `MTChannelBasedBroker` with the class type you want to use:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      annotations:
        eventing.knative.dev/broker.class: MTChannelBasedBroker
      name: default
      namespace: default
    ```

1. Configure the `spec.config` with the details of the ConfigMap that defines the required configuration for the Broker class (e.g. with some Channel configurations in case of the `MTChannelBasedBroker`):

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      annotations:
        eventing.knative.dev/broker.class: MTChannelBasedBroker
      name: default
      namespace: default
    spec:
      config:
        apiVersion: v1
        kind: ConfigMap
        name: config-br-default-channel
        namespace: knative-eventing
    ```

For further information about configuring a default broker class cluster wide or on a per namespace basis, check the [Administrator configuration options](./broker-admin-config-options.md#configuring-the-broker-class).
