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
            - image: ghcr.io/knative/helloworld-go:latest
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
```
{
  "severity": "DEBUG",
  "timestamp": "2023-10-10T15:32:56.949001622Z",
  "logger": "autoscaler.stats-websocket-server",
  "caller": "statserver/server.go:193",
  "message": "Received stat message: {
    Key: default/autoscale-go-00001,
    Stat: {
      PodName": activator-59dff6d45c-9rdxh,
      AverageConcurrentRequests: 18.873756322609804,
      AverageProxiedConcurrentRequests": 0,
      RequestCount: 19,
      ProxiedRequestCount: 0,
      ProcessUptime: 0,
      Timestamp: 0
    }
  }",
  "commit": "f1617ef",
  "address": ":8080"
}

{
   "severity":"INFO",
   "timestamp":"2023-10-10T15:32:56.432854252Z",
   "logger":"autoscaler",
   "caller":"kpa/kpa.go:188",
   "message":"Observed pod counts=kpa.podCounts{want:1, ready:0, notReady:1, pending:1, terminating:0}",
   "commit":"f1617ef",
   "knative.dev/controller":"knative.dev.serving.pkg.reconciler.autoscaling.kpa.Reconciler",
   "knative.dev/kind":"autoscaling.internal.knative.dev.PodAutoscaler",
   "knative.dev/traceid":"7988492e-eea3-4d19-bf5a-8762cf5ff8eb",
   "knative.dev/key":"default/autoscale-go-00001"
}

{
   "severity":"DEBUG",
   "timestamp":"2023-10-10T15:32:57.241052566Z",
   "logger":"autoscaler",
   "caller":"scaling/autoscaler.go:286",
   "message":"PodCount=0 Total1PodCapacity=10.000 ObsStableValue=19.874 ObsPanicValue=19.874 TargetBC=10.000 ExcessBC=-30.000",
   "commit":"f1617ef",
   "knative.dev/key":"default/autoscale-go-00001"
}
```
!!! important
    If you are creating revisions by using a service or configuration, you must set the annotations in the _revision template_ so that any modifications will be applied to each revision as they are created. Setting annotations in the top level metadata of a single revision will not propagate the changes to other revisions and will not apply changes to the autoscaling configuration for your application.
