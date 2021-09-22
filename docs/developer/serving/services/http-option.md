# HTTPS redirection

Operators can force HTTPS redirection for all Services. See the `httpProtocol` mentioned in the [Turn on AutoTLS](../../../serving/using-auto-tls.md) page for more details.

### Overriding the default HTTP behaviour

You can override the default behavior for each Service by configuring the `networking.knative.dev/httpOption` annotation:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: example
  namespace: default
  annotations:
    networking.knative.dev/httpOption: "enabled"
spec:
...
```

The possible values are:

 - `enabled` - Services will accept HTTP traffic
 - `redirected` - Services send a 301 redirect for all HTTP connections and ask clients to use HTTPS instead
