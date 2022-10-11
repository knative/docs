# Additional autoscaling configuration for Knative Pod Autoscaler

The following settings are specific to the Knative Pod Autoscaler (KPA).

## Modes

The KPA acts on [metrics](autoscaling-metrics.md) (`concurrency` or `rps`) aggregated over time-based windows.

These windows define the amount of historical data that the Autoscaler takes into account, and are used to smooth the data over the specified amount of time.
The shorter these windows are, the more quickly the Autoscaler will react.

The KPA's implementation has two modes: **stable** and **panic**. There are separate aggregate windows for each mode: `stable-window` and `panic-window`, respectively.

Stable mode is used for general operation, while panic mode by default has a much shorter window, and will be used to quickly scale a revision up if a burst of traffic arrives.

!!! note
    When using panic mode, the Revision will not scale down to avoid churn. The Autoscaler will leave panic mode if there has been no reason to react quickly during the stable window timeframe.

### Stable window

* **Global key:** `stable-window`
* **Per-revision annotation key:** `autoscaling.knative.dev/window`
* **Possible values:** Duration, `6s` <= value <= `1h`
* **Default:** `60s`

!!! note
    When scaling to zero Replicas, the last Replica will only be removed after there has not been any traffic to the Revision for the entire duration of the stable window.

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/window: "40s"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     stable-window: "40s"
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
          stable-window: "40s"
    ```




### Panic window

The panic window is defined as a percentage of the stable window to assure that both are relative to each other in a working way.

This value indicates how the window over which historical data is evaluated will shrink upon entering panic mode. For example, a value of `10.0` means that in panic mode the window will be 10% of the stable window size.

* **Global key:** `panic-window-percentage`
* **Per-revision annotation key:** `autoscaling.knative.dev/panic-window-percentage`
* **Possible values:** float, `1.0` <= value <= `100.0`
* **Default:** `10.0`

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/panic-window-percentage: "20.0"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     panic-window-percentage: "20.0"
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
          panic-window-percentage: "20.0"
    ```




### Panic mode threshold

This threshold defines when the Autoscaler will move from stable mode into panic mode.

This value is a percentage of the traffic that the current amount of replicas can handle.

!!! note
    A value of `100.0` (100 percent) means that the Autoscaler is always in panic mode, therefore the  minimum value should be higher than `100.0`.

The default setting of `200.0` means that panic mode will be started if traffic is twice as high as the current replica population can handle.

* **Global key:** `panic-threshold-percentage`
* **Per-revision annotation key:** `autoscaling.knative.dev/panic-threshold-percentage`
* **Possible values:** float, `110.0` <= value <= `1000.0`
* **Default:** `200.0`

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/panic-threshold-percentage: "150.0"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     panic-threshold-percentage: "150.0"
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
          panic-threshold-percentage: "150.0"
    ```




## Scale rates

These settings control by how much the replica population can scale up or down in a single evaluation cycle.

A minimal change of one replica in each direction is always permitted, so the Autoscaler can scale to +/- 1 replica at any time, regardless of the scale rates set.

### Scale up rate

This setting determines the maximum ratio of desired to existing pods. For example, with a value of `2.0`, the revision can only scale from `N` to `2*N` pods in one evaluation cycle.

* **Global key:** `max-scale-up-rate`
* **Per-revision annotation key:** n/a
* **Possible values:** float
* **Default:** `1000.0`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     max-scale-up-rate: "500.0"
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
          max-scale-up-rate: "500.0"
    ```




### Scale down rate

This setting determines the maximum ratio of existing to desired pods. For example, with a value of `2.0`, the revision can only scale from `N` to `N/2` pods in one evaluation cycle.

* **Global key:** `max-scale-down-rate`
* **Per-revision annotation key:** n/a
* **Possible values:** float
* **Default:** `2.0`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     max-scale-down-rate: "4.0"
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
          max-scale-down-rate: "4.0"
    ```
