# Configuring concurrency

Concurrency determines the number of simultaneous requests that can be processed by each replica of an application at any given time.
<!-- this is where including files would be useful. We could create a concurrency global config module and insert it here, in the docs for metrics, and in the docs for targets. Showing the correct information each time instead of having it in one place with the per revision config jumbled in with it makes it easier to understand IMHO, and would mean users don't need to visit different pages or hunt for the same information for similar user stories @abrennan89.-->
For per-revision concurrency, you must configure both `autoscaling.knative.dev/metric`and `autoscaling.knative.dev/target` for a [soft limit](#soft-limit), or `containerConcurrency` for a [hard limit](#hard-limit).

For global concurrency, you can set the `container-concurrency-target-default` value.

## Soft versus hard concurrency limits

It is possible to set either a _soft_ or _hard_ concurrency limit.

!!! note
    If both a soft and a hard limit are specified, the smaller of the two values will be used. This prevents the Autoscaler from having a target value that is not permitted by the hard limit value.

The soft limit is a targeted limit rather than a strictly enforced bound. In some situations, particularly if there is a sudden _burst_ of requests, this value can be exceeded.

The hard limit is an enforced upper bound.
If concurrency reaches the hard limit, surplus requests will be buffered and must wait until enough capacity is free to execute the requests.

!!! warning
    Using a hard limit configuration is only recommended if there is a clear use case for it with your application. Having a low hard limit specified may have a negative impact on the throughput and latency of an application, and may cause additional cold starts.

### Soft limit

* **Global key:** `container-concurrency-target-default`
* **Per-revision annotation key:** `autoscaling.knative.dev/target`
* **Possible values:** An integer.
* **Default:** `"100"`

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
            autoscaling.knative.dev/target: "200"
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     container-concurrency-target-default: "200"
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
          container-concurrency-target-default: "200"
    ```




### Hard limit

The hard limit is specified [per Revision](autoscaler-types.md#global-versus-per-revision-settings) using the `containerConcurrency` field on the Revision spec. This setting is not an annotation.

There is no global setting for the hard limit in the autoscaling ConfigMap, because `containerConcurrency` has implications outside of autoscaling, such as on buffering and queuing of requests. However, a default value can be set for the Revision's `containerConcurrency` field in `config-defaults.yaml`.

The default value is `0`, meaning that there is no limit on the number of requests that are allowed to flow into the revision.
A value greater than `0` specifies the exact number of requests that are allowed to flow to the replica at any one time.

* **Global key:** `container-concurrency` (in `config-defaults.yaml`)
* **Per-revision spec key:** `containerConcurrency`
* **Possible values:** integer
* **Default:** `0`, meaning no limit


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
        spec:
          containerConcurrency: 50
    ```

=== "Global (Defaults ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-defaults
     namespace: knative-serving
    data:
     container-concurrency: "50"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        defaults:
          container-concurrency: "50"
    ```




## Target utilization

In addition to the literal settings explained previously, concurrency values can be further adjusted by using a _target utilization value_.

This value specifies what percentage of the previously specified target should actually be targeted by the Autoscaler.
This is also known as specifying the _hotness_ at which a replica runs, which causes the Autoscaler to scale up before the defined hard limit is reached.

For example, if `containerConcurrency` is set to 10, and the target utilization value is set to 70 (percent), the Autoscaler will create a new replica when the average number of concurrent requests across all existing replicas reaches 7.
Requests numbered 7 to 10 will still be sent to the existing replicas, but this allows for additional replicas to be started in anticipation of being needed when the `containerConcurrency` limit is reached.

* **Global key:** `container-concurrency-target-percentage`
* **Per-revision annotation key:** `autoscaling.knative.dev/target-utilization-percentage`
* **Possible values:** float
* **Default:** `70`

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
            autoscaling.knative.dev/target-utilization-percentage: "80"
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
     container-concurrency-target-percentage: "80"
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
          container-concurrency-target-percentage: "80"
    ```
