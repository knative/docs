# Supported Autoscaler types

Knative Serving supports the implementation of Knative Pod Autoscaler (KPA) and Kubernetes' Horizontal Pod Autoscaler (HPA). This topic lists the features and limitations of each of these Autoscalers, as well as how to configure them.

!!! important
    If you want to use Kubernetes Horizontal Pod Autoscaler (HPA), you must install it after you install Knative Serving.
For how to install HPA, see [Install optional Serving extensions](../../install/yaml-install/serving/install-serving-with-yaml.md#install-optional-serving-extensions).

## Knative Pod Autoscaler (KPA)

* Part of the Knative Serving core and enabled by default once Knative Serving is installed.
* Supports scale to zero functionality.
* Does not support CPU-based autoscaling.

## Horizontal Pod Autoscaler (HPA)

* Not part of the Knative Serving core, and you must install Knative Serving first.
* Does not support scale to zero functionality.
* Supports CPU-based autoscaling.

## Configuring the Autoscaler implementation

The type of Autoscaler implementation (KPA or HPA) can be configured by using the `class` annotation.

* **Global settings key:** `pod-autoscaler-class`
* **Per-revision annotation key:** `autoscaling.knative.dev/class`
* **Possible values:** `"kpa.autoscaling.knative.dev"` or `"hpa.autoscaling.knative.dev"`
* **Default:** `"kpa.autoscaling.knative.dev"`

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
            autoscaling.knative.dev/class: "kpa.autoscaling.knative.dev"
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
     pod-autoscaler-class: "kpa.autoscaling.knative.dev"
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
          pod-autoscaler-class: "kpa.autoscaling.knative.dev"
    ```

### Global versus per-revision settings

Configuring for autoscaling in Knative can be set using either global or per-revision settings.

1. If no per-revision autoscaling settings are specified, the global settings will be used.
1. If per-revision settings are specified, these will override the global settings when both types of settings exist.

#### Global settings

Global settings for autoscaling are configured using the `config-autoscaler` ConfigMap. If you installed Knative Serving using the Operator, you can set global configuration settings in the `spec.config.autoscaler` ConfigMap, located in the `KnativeServing` custom resource (CR).

##### Example of the default autoscaling ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-autoscaler
 namespace: knative-serving
data:
 container-concurrency-target-default: "100"
 container-concurrency-target-percentage: "0.7"
 enable-scale-to-zero: "true"
 max-scale-up-rate: "1000"
 max-scale-down-rate: "2"
 panic-window-percentage: "10"
 panic-threshold-percentage: "200"
 scale-to-zero-grace-period: "30s"
 scale-to-zero-pod-retention-period: "0s"
 stable-window: "60s"
 target-burst-capacity: "200"
 requests-per-second-target-default: "200"
```

#### Per-revision settings

Per-revision settings for autoscaling are configured by adding _annotations_ to a revision.

**Example:**

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
        autoscaling.knative.dev/target: "70"
```

!!! important
    If you are creating revisions by using a service or configuration, you must set the annotations in the _revision template_ so that any modifications will be applied to each revision as they are created. Setting annotations in the top level metadata of a single revision will not propagate the changes to other revisions and will not apply changes to the autoscaling configuration for your application.
