# Developer configuration options

While Revisions cannot be created manually without modifying the Configuration of a Knative Service, you can modify the spec of an existing Revision to change its behavior.

## Garbage collection

--8<-- "about-revisions-garbage-collection.md"

### Disabling garbage collection for a Revision

You can configure a Revision so that it is never garbage collected by adding the `serving.knative.dev/no-gc: "true"` annotation:

```yaml
apiVersion: serving.knative.dev/v1
kind: Revision
metadata:
  annotations:
    serving.knative.dev/no-gc: "true"
...
```
