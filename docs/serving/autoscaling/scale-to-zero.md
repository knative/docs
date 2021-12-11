# Configuring scale to zero

!!! warning
    Scale to zero can only be enabled if you are using the KnativePodAutoscaler (KPA), and can only be configured globally. For more information about using KPA or global configuration, see the documentation on [Supported Autoscaler types](autoscaler-types.md).

## Enable scale to zero

The scale to zero value controls whether Knative allows replicas to scale down to zero (if set to `true`), or stop at 1 replica if set to `false`.

!!! note
    For more information about scale bounds configuration per Revision, see the documentation on [Configuring scale bounds](scale-bounds.md).

* **Global key:** `enable-scale-to-zero`
* **Per-revision annotation key:** No per-revision setting.
* **Possible values:** boolean
* **Default:** `true`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     enable-scale-to-zero: "false"
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
          enable-scale-to-zero: "false"
    ```




## Scale to zero grace period

This setting specifies an upper bound time limit that the system will wait internally for scale-from-zero machinery to be in place before the last replica is removed.

!!! warning
    This is a value that controls how long internal network programming is allowed to take, and should only be adjusted if you experience issues with requests being dropped while a Revision is scaling to zero Replicas.

This setting does not adjust how long the last replica will be kept after traffic ends, and it does not guarantee that the replica will actually be kept for this entire duration.

* **Global key:** `scale-to-zero-grace-period`
* **Per-revision annotation key:** n/a
* **Possible values:** Duration
* **Default:** `30s`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     scale-to-zero-grace-period: "40s"
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
          scale-to-zero-grace-period: "40s"
    ```





## Scale to zero last pod retention period

The `scale-to-zero-pod-retention-period` flag determines the minimum amount of time that the last pod will remain active after the Autoscaler decides to scale pods to zero.

This contrasts with the `scale-to-zero-grace-period` flag, which determines the maximum amount of time that the last pod will remain active after the Autoscaler decides to scale pods to zero.

* **Global key:** `scale-to-zero-pod-retention-period`
* **Per-revision annotation key:** `autoscaling.knative.dev/scale-to-zero-pod-retention-period`
* **Possible values:** Non-negative duration string
* **Default:** `0s`

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
            autoscaling.knative.dev/scale-to-zero-pod-retention-period: "1m5s"
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
     scale-to-zero-pod-retention-period: "42s"
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
          scale-to-zero-pod-retention-period: "42s"
    ```
