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

### Revision Timeout Seconds
{% raw %}
revision-timeout-seconds contains the default number of
seconds to use for the revision's per-request timeout, if
none is specified.
{% endraw %}

* **Global key:** `revision-timeout-seconds`
* **Per-revision annotation key:** `serving.knative.dev/revision-timeout-seconds`
* **Possible values:** integer
* **Default:** `"300"` (5 minutes)

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
            serving.knative.dev/revision-timeout-seconds: "300"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion:  v1
    kind:  ConfigMap
    metadata:
      name:  config-defaults
      namespace:  knative-serving
    data:
      revision-timeout-seconds: "300" # 5 minutes
    ```

### Max Revision Timeout Seconds
{% raw %}
max-revision-timeout-seconds contains the maximum number of
seconds that can be used for revision-timeout-seconds.
This value must be greater than or equal to revision-timeout-seconds.
If omitted, the system default is used (600 seconds).

If this value is increased, the activator's terminationGraceTimeSeconds
should also be increased to prevent in-flight requests being disrupted.
{% endraw %}

* **Global key:** `max-revision-timeout-seconds`
* **Per-revision annotation key:** `serving.knative.dev/max-revision-timeout-seconds`
* **Possible values:** integer
* **Default:** `"600"` (10 minutes)

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
            serving.knative.dev/max-revision-timeout-seconds: "600"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Revision CPU Request
{% raw %}
revision-cpu-request contains the cpu allocation to assign
to revisions by default.  If omitted, no value is specified
and the system default is used.
Below is an example of setting revision-cpu-request.
By default, it is not set by Knative.
{% endraw %}

* **Global key:** `revision-cpu-request`
* **Per-revision annotation key:** `serving.knative.dev/revision-cpu-request`
* **Possible values:** integer
* **Default:** `"400m"` (0.4 of a CPU, or 400 milli-CPU)

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
            serving.knative.dev/revision-cpu-request: "400m"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Revision Memory Request
{% raw %}
revision-memory-request contains the memory allocation to assign
to revisions by default.  If omitted, no value is specified
and the system default is used.
Below is an example of setting revision-memory-request.
By default, it is not set by Knative.
{% endraw %}

* **Global key:** `revision-memory-request`
* **Per-revision annotation key:** `serving.knative.dev/revision-memory-request`
* **Possible values:** integer
* **Default:** `"100M"` (100 megabytes of memory)

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
            serving.knative.dev/revision-memory-request: "400m"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Revision Ephemeral Storage Request
{% raw %}
revision-ephemeral-storage-request contains the ephemeral storage
allocation to assign to revisions by default.  If omitted, no value is
specified and the system default is used.
{% endraw %}

* **Global key:** `revision-ephemeral-storage-request`
* **Per-revision annotation key:** `serving.knative.dev/revision-ephemeral-storage-request`
* **Possible values:** integer
* **Default:** `"500M"` (500 megabytes of storage)

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
            serving.knative.dev/revision-ephemeral-storage-request: "500M"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Revision CPU Limit
{% raw %}
`revision-cpu-limit` contains the CPU allocation to limit
revisions to by default.  If omitted, no value is specified
and the system default is used.
Below is an example of setting `revision-cpu-limit`.
By default, it is not set by Knative.
{% endraw %}

* **Global key:** `revision-cpu-limit`
* **Per-revision annotation key:** `serving.knative.dev/revision-cpu-limit`
* **Possible values:** integer
* **Default:** `"1000m"` (1 CPU, or 1000 milli-CPU)

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
            serving.knative.dev/revision-cpu-limit: "1000m"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Revision Memory Limit
{% raw %}
revision-memory-limit contains the memory allocation to limit
revisions to by default.  If omitted, no value is specified
and the system default is used.
Below is an example of setting revision-memory-limit.
By default, it is not set by Knative.
{% endraw %}

* **Global key:** `revision-memory-limit`
* **Per-revision annotation key:** `serving.knative.dev/revision-memory-limit`
* **Possible values:** integer
* **Default:** `"200M"` (200 megabytes of memory)

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
            serving.knative.dev/revision-memory-limit: "200M"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Revision Ephemeral Storage Limit
{% raw %}
revision-ephemeral-storage-limit contains the ephemeral storage
allocation to limit revisions to by default.  If omitted, no value is
specified and the system default is used.
{% endraw %}

* **Global key:** `revision-ephemeral-storage-limit`
* **Per-revision annotation key:** `serving.knative.dev/revision-ephemeral-storage-limit`
* **Possible values:** integer
* **Default:** `"750M"` (750 megabytes of storage)

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
            serving.knative.dev/revision-ephemeral-storage-limit: "750M"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Container Name Template
{% raw %}
container-name-template contains a template for the default
container name, if none is specified.  This field supports
Go templating and is supplied with the ObjectMeta of the
enclosing Service or Configuration, so values such as
{{.Name}} are also valid.
{% endraw %}

* **Global key:** `container-name-template`
* **Per-revision annotation key:** `serving.knative.dev/container-name-template`
* **Possible values:** string
* **Default:** `"user-container"`

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
            serving.knative.dev/container-name-template: "user-container"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Container Concurrency
{% raw %}
container-concurrency specifies the maximum number
of requests the Container can handle at once, and requests
above this threshold are queued.  Setting a value of zero
disables this throttling and lets through as many requests as
the pod receives.
{% endraw %}

* **Global key:** `container-concurrency`
* **Per-revision annotation key:** `serving.knative.dev/container-concurrency`
* **Possible values:** integer
* **Default:** `"0"`

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
            serving.knative.dev/container-name-template: "0"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Container Concurrency Max Limit

{% raw %}

The container concurrency max limit is an operator setting ensuring that
the individual revisions cannot have arbitrary large concurrency
values, or autoscaling targets. `container-concurrency` default setting
must be at or below this value.

Must be greater than 1.

!!! note
    Even with this set, a user can choose a `containerConcurrency` value of 0 (unbounded) unless `allow-container-concurrency-zero` is set to "false".

{% endraw %}

* **Global key:** `container-concurrency-max-limit`
* **Per-revision annotation key:** `serving.knative.dev/container-concurrency-max-limit`
* **Possible values:** integer
* **Default:** `"1000"`

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
            serving.knative.dev/container-concurrency-max-limit: "1000"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```

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

### Allow Container Concurrency Zero
{% raw %}
allow-container-concurrency-zero controls whether users can
specify 0 (i.e. unbounded) for containerConcurrency.
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

### Enable Service Links

{% raw %}

enable-service-links specifies the default value used for the enableServiceLinks field of the PodSpec, when it is omitted by the user. See [the Kubernetes Documentation for the enableServiceLinks Feature](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/#accessing-the-service).

This is a tri-state flag with possible values of (true|false|default).

In environments with large number of services it is suggested to set this value to `false`. See [serving#8498](https://github.com/knative/serving/issues/8498).

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
