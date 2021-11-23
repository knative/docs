# HTTPS redirection

Operators can force HTTPS redirection for all Services. See the `http-protocol` mentioned in the [Turn on AutoTLS](../using-auto-tls.md) page for more details.

## Overriding the default HTTP behavior

You can override the default behavior for each Service or global configuration.

* **Global key:** `http-protocol`
* **Per-revision annotation key:** `networking.knative.dev/http-protocol`
* **Possible values:**
    * `enabled` &mdash; Services accept HTTP traffic.
    * `redirected` &mdash; Services send a 301 redirect for all HTTP connections and ask clients to use HTTPS instead.
* **Default:** `enabled`

**Example:**

=== "Per Service"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: example
      namespace: default
      annotations:
        networking.knative.dev/http-protocol: "redirected"
    spec:
      ...
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-network
      namespace: knative-serving
    data:
      http-protocol: "redirected"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        network:
          http-protocol: "redirected"
    ```
