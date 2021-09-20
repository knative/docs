# Revision Garbage Collection 

Knative will automatically clean up inactive revisions as configured by the operator. For more information, see the [operator settings](../admin/serving/revision-gc.md).

To always retain a revision add the annotation `serving.knative.dev/no-gc: "true"`

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-service
spec:
  template:
    metadata:
      annotations: 
        serving.knative.dev/no-gc: "true"
    spec:
...
```



