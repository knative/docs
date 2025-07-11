---
audience: administrator
components:
  - serving
function: reference
---

# Configuring the Defaults ConfigMap

The `config-defaults` ConfigMap, known as the Defaults ConfigMap, contains settings that determine how Knative sets default values for resources.

This ConfigMap is located in the `knative-serving` namespace.

You can view the current `config-defaults` ConfigMap by running the following command:

```yaml
kubectl get configmap -n knative-serving config-defaults -oyaml
```
## Example config-defaults ConfigMap

```yaml
apiVersion:  v1
kind:  ConfigMap
metadata:
  name:  config-defaults
  namespace:  knative-serving
data:
  revision-timeout-seconds: "300"
  max-revision-timeout-seconds: "600"
  revision-response-start-timeout-seconds: "300"
  revision-idle-timeout-seconds: "0"  # infinite
  revision-cpu-request: "400m"
  revision-memory-request: "100M"
  revision-ephemeral-storage-request: "500M"
  revision-cpu-limit: "1000m"
  revision-memory-limit: "200M"
  revision-ephemeral-storage-limit: "750M"
  container-name-template: "user-container"
  container-concurrency: "0"
  container-concurrency-max-limit: "1000"
  allow-container-concurrency-zero: "true"
  enable-service-links: "false"
```

See below for a description of each property.

## Properties

### Revision timeout seconds
{% raw %}
The revision timeout value determines the default number of seconds to use for the revision's per-request timeout if none is specified.
{% endraw %}

* **Global key:** `revision-timeout-seconds`
* **Per-revision spec key:** `timeoutSeconds`
* **Possible values:** integer
* **Default:** `"300"` (5 minutes)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-timeout-seconds: "300"
    ```

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
            timeoutSeconds: 300
            containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```

### Max revision timeout seconds
{% raw %}
The `max-revision-timeout-seconds` value determines the maximum number of seconds that can be used for `revision-timeout-seconds`. This value must be greater than or equal to `revision-timeout-seconds`. If omitted, the system default is used (600 seconds).

If this value is increased, the activator's `terminationGracePeriodSeconds` should also be increased to prevent in-flight requests from being disrupted.
{% endraw %}

* **Global key:** `max-revision-timeout-seconds`
* **Per-revision annotation key:** N/A
* **Possible values:** integer
* **Default:** `"600"` (10 minutes)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      max-revision-timeout-seconds: "600"
    ```

### Revision response start timeout seconds
{% raw %}
The revision response start timeout value determines the maximum duration in seconds that the request routing layer will wait for a request delivered to a container to begin sending any network traffic. If omitted, the system default is used (300 seconds).
{% endraw %}

* **Global key:** `revision-response-start-timeout-seconds`
* **Per-revision spec key:** `responseStartTimeoutSeconds`
* **Possible values:** integer
* **Default:** `"300"` (5 minutes)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-response-start-timeout-seconds: "300"
    ```

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
            responseStartTimeoutSeconds: 300
            containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```


### Revision idle timeout seconds
{% raw %}
The revision idle timeout value determines the maximum duration in seconds a request will be allowed to stay open while not receiving any bytes from the user's application. If omitted, the system default is used (infinite).
{% endraw %}

* **Global key:** `revision-idle-timeout-seconds`
* **Per-revision spec key:** `idleTimeoutSeconds`
* **Possible values:** integer
* **Default:** `"0"` (infinite)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-idle-timeout-seconds: "0"
    ```

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
            idleTimeoutSeconds: 0
            containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```

### Revision CPU request
{% raw %}
The `revision-cpu-request` value determines the CPU allocation assigned to revisions by default. If this value is omitted, the system default is used. This key is not enabled by default for Knative.
{% endraw %}

* **Global key:** `revision-cpu-request`
* **Per-revision annotation key:** `cpu`
* **Possible values:** integer
* **Default:** `"400m"` (0.4 of a CPU, or 400 milli-CPU)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-cpu-request: "400m"
    ```

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
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
              resources:
                requests:
                  cpu: "400m"
    ```

### Revision memory request
{% raw %}
The `revision-memory-request` value determines the memory allocation assigned
to revisions by default. If this value is omitted, the system default is used. This key is not enabled by default for Knative.
{% endraw %}

* **Global key:** `revision-memory-request`
* **Per-revision annotation key:** `memory`
* **Possible values:** integer
* **Default:** `"100M"` (100 megabytes of memory)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-memory-request: "100M"
    ```

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
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
              resources:
                requests:
                  memory: "100M"
    ```

### Revision Ephemeral Storage Request
{% raw %}
The `revision-ephemeral-storage-request` value determines the ephemeral storage
allocation assigned to revisions by default. If this value is omitted, the system default is used. This key is not enabled by default for Knative.
{% endraw %}

* **Global key:** `revision-ephemeral-storage-request`
* **Per-revision annotation key:** `ephemeral-storage`
* **Possible values:** integer
* **Default:** `"500M"` (500 megabytes of storage)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-ephemeral-storage-request: "500M"
    ```

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
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
              resources:
                requests:
                  ephemeral-storage: "500M"
    ```

### Revision CPU limit
{% raw %}
The `revision-cpu-limit` value determines the default CPU allocation limit for revisions. If this value is omitted, the system default is used. This key is not enabled by default for Knative.
{% endraw %}

* **Global key:** `revision-cpu-limit`
* **Per-revision annotation key:** `cpu`
* **Possible values:** integer
* **Default:** `"1000m"` (1 CPU, or 1000 milli-CPU)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-cpu-limit: "1000m"
    ```

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
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
              resources:
                requests:
                  cpu: "1000m"
    ```

### Revision memory limit
{% raw %}
The `revision-memory-limit` value determines the default memory allocation limit for revisions. If this value is omitted, the system default is used. This key is not enabled by default for Knative.
{% endraw %}

* **Global key:** `revision-memory-limit`
* **Per-revision annotation key:** `memory`
* **Possible values:** integer
* **Default:** `"200M"` (200 megabytes of memory)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-memory-limit: "200M"
    ```

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
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
              resources:
                requests:
                  memory: "200M"
    ```

### Revision Ephemeral Storage Limit
{% raw %}
The `revision-ephemeral-storage-limit` value determines the default ephemeral storage limit allocated to revisions. If this value is omitted, the system default is used. This key is not enabled by default for Knative.
{% endraw %}

* **Global key:** `revision-ephemeral-storage-limit`
* **Per-revision annotation key:** `ephemeral-storage`
* **Possible values:** integer
* **Default:** `"750M"` (750 megabytes of storage)

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-ephemeral-storage-limit: "750M"
    ```

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
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
              resources:
                requests:
                  ephemeral-storage: "750M"
    ```

### Container name template
{% raw %}
The `container-name-template` value provides a template for the default
container name if no container name is specified. This field supports Go templating and is supplied by the `ObjectMeta` of the enclosing Service or Configuration, so values such as `{{.Name}}` are also valid.
{% endraw %}

* **Global key:** `container-name-template`
* **Per-revision annotation key:** `name`
* **Possible values:** string
* **Default:** `"user-container"`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      container-name-template: "user-container"
    ```

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
          containers:
            - name: user-container
              image: ghcr.io/knative/helloworld-go:latest
    ```

### Container concurrency
{% raw %}
The `container-concurrency` value specifies the maximum number of requests the container can handle at once. Requests above this threshold are queued. Setting a value of zero disables this throttling and lets through as many requests as
the pod receives.
{% endraw %}

* **Global key:** `container-concurrency`
* **Per-revision spec key:** `containerConcurrency`
* **Possible values:** integer
* **Default:** `"0"`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      container-concurrency: "0"
    ```

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
          containerConcurrency: 0
    ```

### Container concurrency max limit

{% raw %}

The `container-concurrency-max-limit` setting disables arbitrary large concurrency values, or autoscaling targets, for individual revisions. The `container-concurrency` default setting must be at or below this value. The value of the `container-concurrency-max-limit` setting must be greater than 1.

!!! note
    Even with this set, a user can choose a `containerConcurrency` value of zero (unbounded), unless `allow-container-concurrency-zero` is set to `"false"`.

{% endraw %}

* **Global key:** `container-concurrency-max-limit`
* **Per-revision annotation key:** N/A
* **Possible values:** integer
* **Default:** `"1000"`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      container-concurrency-max-limit: "1000"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      config:
        defaults:
          container-concurrency-max-limit: "1000"
    ```

### Allow container concurrency zero
{% raw %}
The `allow-container-concurrency-zero` value determines whether users can
specify `0` (unbounded) for `containerConcurrency`.
{% endraw %}

* **Global key:** `allow-container-concurrency-zero`
* **Per-revision annotation key:** N/A
* **Possible values:** boolean
* **Default:** `"true"`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      allow-container-concurrency-zero: "true"
    ```

### Enable Service links

{% raw %}

The `enable-service-links` value specifies the default value used for the `enableServiceLinks` field of the `PodSpec` when it is omitted by the user. See [the Kubernetes documentation about the `enableServiceLinks` feature](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/#accessing-the-service).

This is a tri-state flag with possible values of (true|false|default).

In environments with large number of Services, it is suggested to set this value to `false`. See [serving#8498](https://github.com/knative/serving/issues/8498).

{% endraw %}

* **Global key:** `enable-service-links`
* **Per-revision annotation key:** N/A
* **Possible values:** `true|false|default`
* **Default:** `"false"`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      enable-service-links: "false"
    ```
