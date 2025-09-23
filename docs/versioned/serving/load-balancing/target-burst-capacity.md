# Configuring target burst capacity

_Target burst capacity_ is a [global and per-revision](../autoscaling/autoscaler-types.md#global-versus-per-revision-settings) integer setting that determines the size of traffic burst a Knative application can handle without buffering.
If a traffic burst is too large for the application to handle, the _Activator_ service will be placed in the request path to protect the revision and optimize request load balancing.

The Activator service is responsible for receiving and buffering requests for inactive revisions, or for revisions where a traffic burst is larger than the limits of what can be handled without buffering for that revision. It can also quickly spin up additional pods for capacity, and throttle how quickly requests are sent to pods.

Target burst capacity can be configured using a combination of the following parameters:

- Setting the targeted concurrency limits for the revision. See [concurrency](../autoscaling/concurrency.md).
- Setting the target utilization parameters. See [target utilization](../autoscaling/concurrency.md#target-utilization).
- Setting the target burst capacity. You can configure target burst capacity using the `target-burst-capacity` annotation key in the `config-autoscaler` ConfigMap. See [Setting the target burst capacity](#setting-the-target-burst-capacity).

## Setting the target burst capacity

- **Global key:** `target-burst-capacity`
- **Per-revision annotation key:** `autoscaling.knative.dev/target-burst-capacity`
- **Possible values:** float (`0` means the Activator is only in path when scaled to 0, `-1` means the Activator is always in path)
- **Default:** `200`

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      annotations:
      name: <service_name>
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/target-burst-capacity: "200"
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-autoscaler
      namespace: knative-serving
    data:
      target-burst-capacity: "200"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          target-burst-capacity: "200"
    ```

!!! note

    Ingress gateway load balancing requires additional configuration. For more information about load balancing using an ingress
    gateway, see the [Serving API](../../serving/reference/serving-api.md) documentation.


- If `autoscaling.knative.dev/target-burst-capacity` is set to `0`, the Activator is only added to the request path during scale from zero scenarios, and ingress load balancing will be applied.

- If `autoscaling.knative.dev/target-burst-capacity` is set to `-1`, the Activator is always in the request path, regardless of the revision size.

- If `autoscaling.knative.dev/target-burst-capacity` is set to another integer, the Activator may be in the path, depending on the revision scale and load.
