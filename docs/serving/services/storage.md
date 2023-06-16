# Configuring storage for Knative services

Knative Serving integrates with K8s storage capabilities via supporting a subset of ephemeral storage volumes and via PersistentVolumeClaims(PVCs) volume types.
In detail Knative Serving supports emptyDir by default, secret, configmap, projection and PVCs volume types.
For more details on volume configuration check the related [feature flags](../configuration/feature-flags.md) when applicable.

Here is an example of using PVCs:

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

The example assumes that the user has enabled PVC support via the corresponding feature flag.

!!! warning
    Mounting large volumes may add considerable overhead to the application's start up time.
