---
title: "Configuring the Serving Operator Custom Resource"
weight: 10
type: "docs"
aliases:
- /docs/operator/configuring-serving-cr/
---

The Knative Serving operator can be configured with these options:

- [All the ConfigMaps](#all-the-configmaps)

__NOTE:__ Kubernetes spec level policies cannot be configured using the Knative operators.

## All the ConfigMaps

All the ConfigMaps can be configured in Knative Serving with the custom resource. The values in the custom resource will
overwrite the existing values in ConfigMaps. In the latest release of Knative Serving, there are multiple ConfigMaps,
e.g. `config-autoscaler`, `config-default`, `config-deployment`, etc. All the ConfigMaps are named with the prefix
`config-`. and in the format of `config-<name>`. A field named `config` is defined under the section `spec` to specify
all the ConfigMaps. Under the section `spec.config`, use the name after the hyphen(`-`) sign, `<name>`, as the field to
specify all the key-value pairs, which are exactly the same as we have in the section `data` for each ConfigMap.

As in the example of how to [setup a custom domain](https://knative.dev/development/serving/using-a-custom-domain/), you can see the content of the ConfigMap
`config-domain` is:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
data:
  example.org: |
    selector:
      app: prod
  example.com: ""
```

To specify the ConfigMap `config-domain`, you can change the content of the operator CR into:

```
apiVersion: operator.knative.dev/v1alpha1
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

Next, save the CR into a file named `operator-cr.yaml`, and run the command:

```
kubectl apply -f operator-cr.yaml
```

If you want to change another ConfigMap, e.g. `config-autoscaler`, by specifying `stable-window` to `60s`. Continue to
change your operator CR into:

```
apiVersion: operator.knative.dev/v1alpha1
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

Then, save the content in a file named `operator-cr.yaml`, and run the command:

```
kubectl apply -f operator-cr.yaml
```

All the ConfigMaps should be defined under the same namespace as the operator CR. You can use the operator CR as the
unique entry point to edit all of them.
