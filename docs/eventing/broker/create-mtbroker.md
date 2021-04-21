---
title: "Creating a broker"
weight: 03
type: "docs"
showlandingtoc: "false"
---

Once you have installed Knative Eventing, you can create an instance of the multi-tenant (MT) channel-based broker that is provided by default.

You can create a broker by using the `kn` CLI or by applying YAML files using `kubectl`.

{{< tabs name="Create a broker" default="kn" >}}
    {{% tab name="kn" %}}

1. You can create a broker in current namespace by entering the following command:

    ```shell
    kn broker create <broker-name>
    ```

1. Optional: You can also specify an existing namespace in which to create the broker by entering the following command:

    ```shell
    kn broker create <broker-name> -n <namespace>
    ```

1. Optional: Verify that the broker was created by listing existing brokers. Enter the following command:

    ```shell
    kn broker list
    ```

1. Optional: You can also verify the broker exists by describing the broker you have created. Enter the following command:

    ```shell
    kn broker describe <broker-name>
    ```

    {{< /tab >}}
    {{% tab name="kubectl" %}}

The YAML in the following example creates a broker named `default` in the current namespace. For more information about configuring broker options using YAML, see the full [broker configuration example](./example-mtbroker).

```yaml
kubectl apply -f <filename> - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
 name: default
EOF
```

Where
- `<filename>` is the name that you want to give to the YAML file that will contain your broker. For example, `broker.yaml`.

    {{< /tab >}}
{{< /tabs >}}
