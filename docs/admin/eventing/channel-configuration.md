# Configure Channel defaults

Knative Eventing provides a `default-ch-webhook` ConfigMap that contains the configuration settings that govern default Channel creation.

The default `default-ch-webhook` ConfigMap is as follows:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
    app.kubernetes.io/version: devel
    app.kubernetes.io/part-of: knative-eventing
data:
  # Configuration for defaulting channels that do not specify CRD implementations.
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1
      kind: InMemoryChannel
    namespaceDefaults:
      some-namespace:
        apiVersion: messaging.knative.dev/v1
        kind: InMemoryChannel
```

This configuration is going to be used by default, if no channel implementation is specified.
