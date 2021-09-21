# Revision garbage collection

The `config-gc` ConfigMap contains settings that determine in-active revisions are cleaned up. This ConfigMap is located in the `knative-serving` namespace.


## Cluster-wide configuration

The following properties allow you to configure revision garbage collection:

Name|Description
-|-
`retain-since-create-time`| Duration since creation before considering a revision for GC or "disabled"
`retain-since-last-active-time`| Duration since active before considering a revision for GC or "disabled"
`min-non-active-revisions`| Minimum number of non-active revisions to retain.
`max-non-active-revisions`| Maximum number of non-active revisions to retain or "disabled" to disable any maximum limit.

Revisions are retained if they belong to any one of the following categories:

- Is active and is being reference by a route
- Created within `retain-since-create-time`
- Last referenced by a route within `retain-since-last-active-time`
- There are fewer than `min-non-active-revisions`


### Examples

#### Immediately collect any inactive revision
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-gc
  namespace: knative-serving
data:
  min-non-active-revisions: "0"
  retain-since-create-time: "disabled"
  retain-since-last-active-time: "disabled"
```

#### Keep around the last ten non-active revisions
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-gc
  namespace: knative-serving
data:
  retain-since-create-time: "disabled"
  retain-since-last-active-time: "disabled"
  max-non-active-revisions: "10"
```

#### Disable garbage collection
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-gc
  namespace: knative-serving
data:
  retain-since-create-time: "disabled"
  retain-since-last-active-time: "disabled"
  max-non-active-revisions: "disabled"
```

#### Complex example

The following example configuration keeps recently deployed or active revisions,
always maintains the last two revisions in case of rollback, and prevents burst
activity from exploding the count of old revisions:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-gc
  namespace: knative-serving
data:
  retain-since-create-time: "48h"
  retain-since-last-active-time: "15h"
  min-non-active-revisions: "2"
  max-non-active-revisions: "1000"
```

## Per-revision options

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
