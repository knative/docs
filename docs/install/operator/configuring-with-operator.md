# Configuring Knative by using the Operator

The Operator manages the configuration of a Knative installation, including propagating values from the `KnativeServing` and `KnativeEventing` custom resources to system [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/).

Any updates to ConfigMaps which are applied manually are overwritten by the Operator. However, modifying the Knative custom resources allows you to set values for these ConfigMaps.

Knative has multiple ConfigMaps that are named with the prefix `config-`.


All Knative ConfigMaps are created in the same namespace as the custom resource that they apply to. For example, if the `KnativeServing` custom resource is created in the `knative-serving` namespace, all Knative Serving ConfigMaps are also created in this namespace.

The `spec.config` in the Knative custom resources have one `<name>` entry for each ConfigMap, named `config-<name>`, with a value which is be used for the ConfigMap `data`.

## Examples

You can specify that the `KnativeServing` custom resource uses the `config-domain` ConfigMap  as follows:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  config:
    domain:
      example.org: |
        selector:
          app: prod
      example.com: ""
```

You can apply values to multiple ConfigMaps. This example sets `stable-window` to 60s in the `config-autoscaler` ConfigMap, as well as specifying the `config-domain` ConfigMap:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  config:
    domain:
      example.org: |
        selector:
          app: prod
      example.com: ""
    autoscaler:
      stable-window: "60s"
```
