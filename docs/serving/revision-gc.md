# Revision garbage collection

Knative automatically cleans up inactive revisions as configured by the Operator. For more information, see the [Operator settings](../serving/configuration/revision-gc.md).

You can configure a revision so that it is never garbage collected by adding the `serving.knative.dev/no-gc: "true"` annotation:

```yaml
apiVersion: serving.knative.dev/v1
kind: Revision
metadata:
  annotations:
    serving.knative.dev/no-gc: "true"
spec:
...
```
