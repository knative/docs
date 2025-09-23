# Volume Support for Knative services

You can provide data storage for Knative Services by configuring different volumes types.
Serving supports mounting the [volume types](https://kubernetes.io/docs/concepts/storage/volumes): `emptyDir`, `secret`, `configMap` and `projected`.
[PersistentVolumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) are supported but require a [feature flag](../configuration/feature-flags.md) to be enabled.

!!! warning
    
    Mounting large volumes may add considerable overhead to the application's start up time.


Bellow there is an example of using a persistent volume claim with a Knative Service.

## Prerequisites

Before you can configure PVCs for a Service, this feature must be enabled in the `config-features` ConfigMap as follows:

```
kubectl patch --namespace knative-serving configmap/config-features \
 --type merge \
 --patch '{"data":{"kubernetes.podspec-persistent-volume-claim": "enabled", "kubernetes.podspec-persistent-volume-write": "enabled"}}'
```

* The `kubernetes.podspec-persistent-volume-claim` extension controls whether persistent volumes (PVs) can be used with Knative Serving.
* The `kubernetes.podspec-persistent-volume-write` extension controls whether PVs are available to Knative Serving with the write access.

!!! note
   
    If you have installed Serving via the Knative operator then you need to set the above feature flags **only** at the corresponding Serving CR.

## Procedure

* Modify the PVC configuration for your Service:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
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
            claimName: knative-pv-claim
            readOnly: false
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: knative-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```