---
title: "Configuring the requests per second (RPS) target"
linkTitle: "Configuring the requests per second (RPS) target"
weight: 50
type: "docs"
---

This setting specifies a target for requests-per-second per replica of an application.

* **Global key:** `requests-per-second-target-default`
* **Per-revision annotation key:** `autoscaling.knative.dev/target` (your revision must also be configured to use the `rps` [metric annotation](./autoscaling-metrics.md))
* **Possible values:** An integer.
* **Default:** `"200"`

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
            autoscaling.knative.dev/target: "150"
            autoscaling.knative.dev/metric: "rps"
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
    requests-per-second-target-default: "150"
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
          requests-per-second-target-default: "150"
    ```
