---
audience: administrator
components:
  - serving
function: how-to
---

# Configuring HTTP

## HTTPS redirection

Operators can force HTTPS redirection for all Services. See the `http-protocol` mentioned in
[Configure external domain encryption](../encryption/external-domain-tls.md) page for more details.

### Overriding the default HTTP behavior

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

## HTTP/1 Full Duplex support per workload

Knative services can turn on the support for [HTTP/1 full duplex](https://pkg.go.dev/net/http#ResponseController.EnableFullDuplex) end-to-end on the data path.
This should be used in scenarios where the [related Golang issue](https://github.com/golang/go/issues/40747) is hit eg. the application server writes back to QP's reverse proxy before the latter has consumed the whole request.
For more details on why the issue appears see [here](https://github.com/golang/go/issues/40747#issuecomment-1382404132).

### Configure HTTP/1 Full Duplex support

In order to enable the HTTP/1 full duplex support you can set the corresponding annotation at the revision spec level as follows:

!!! warning

    Test with your http clients before enabling, as older clients may not provide support for HTTP/1 full duplex.


```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: example-service
  namespace: default
spec:
  template:
    metadata:
      annotations:
        features.knative.dev/http-full-duplex: "Enabled"
...
```

