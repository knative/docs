# Volume Support for Knative services

By default Serving supports the mounting the [volume types](https://kubernetes.io/docs/concepts/storage/volumes): `emptyDir`, `secret`, `configMap` and `projected`. [PersistentVolumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) are supported but require a [feature flag](../configuration/feature-flags.md) to be enabled.

!!! warning
    Mounting large volumes may add considerable overhead to the application's start up time.


Here is an example of using a persistent volume claim with a Knative Service:

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
