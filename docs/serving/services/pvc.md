# Permanent data storage

You can provide permanent data storage for Knative Services by configuring `PersistentVolumeClaims` (PVCs).

## Prerequisites

Before you can configure PVCs for a Service, this feature must be enabled in the `KnativeServing` ConfigMap:

```yaml
...
spec:
  config:
    features:
      "kubernetes.podspec-persistent-volume-claim": enabled
      "kubernetes.podspec-persistent-volume-write": enabled
...
```

* The `kubernetes.podspec-persistent-volume-claim` extension controls whether persistent volumes (PVs) can be used with Knative Serving.
* The `kubernetes.podspec-persistent-volume-write` extension controls whether PVs are available to Knative Serving with the write access.

## Procedure

* Modify the PVC configuration for your Service:

    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
    namespace: my-ns
    ...
    spec:
    template:
    spec:
        containers:
            ...
            volumeMounts: 
            - mountPath: /data
                name: mydata
                readOnly: false
        volumes:
        - name: mydata
            persistentVolumeClaim: 
            claimName: example-pv-claim
            readOnly: false
    ```
