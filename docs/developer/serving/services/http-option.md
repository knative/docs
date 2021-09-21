# Configuring HTTP(S) Redirect

Operators can disable HTTP traffic by modifying the value of `httpProtocol` in the `config-network` ConfigMap. This is located in the `knative-serving` namespace and is part of Knative Serving's installation. 

The available values are:

- `Enabled` - Services will accept HTTP traffic
- `Redirected` - Services will send a 301 redirect for all HTTP connections, asking the clients to use HTTPS


The value set by the operator will be the default for all Knative Services.

### Overriding the default HTTP behaviour

Developers can override this default behavior for each Service by specifying the `networking.knative.dev/httpOption` annotation.

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
