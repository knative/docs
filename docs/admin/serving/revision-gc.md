# Revision Garbage Collection

The `config-gc` ConfigMap contains settings that determine how to clean up in-active revisions. This ConfigMap is located in the `knative-serving` namespace.


## Cluster-wide Configuration

The following properties allow you to configure revision garbage collection:

-|-
name|description
`retain-since-create-time`| Duration since creation before considering a revision for GC or "disabled"
`retain-since-last-active-time`| Duration since active before considering a revision for GC or "disabled"
`min-non-active-revisions`| Minimum number of non-active revisions to retain.
`max-non-active-revisions`| Maximum number of non-active revisions to retain or "disabled" to disable any maximum limit.

Revisions are retained if they fall into any one of the following categories
- Is active and is being reference by a route
- Created within `retain-since-create-time`
- Last referenced by a route within `retain-since-last-active-time`
- There are fewer than `min-non-active-revisions`


### Examples

#### Immediately collect any inactive revision

```
min-non-active-revisions: "0"
retain-since-create-time: "disabled"
retain-since-last-active-time: "disabled"
```

#### Keep around the last ten non-active revisions
```
retain-since-create-time: "disabled"
retain-since-last-active-time: "disabled"
max-non-active-revisions: "10"
```

#### Disable GC
```
retain-since-create-time: "disabled"
retain-since-last-active-time: "disabled"
max-non-active-revisions: "disabled"
```

#### Complex Example

This example config wll keep recently deployed or active revisions,
always maintain the last two in case of rollback, and prevent burst
activity from exploding the count of old revisions.

```
retain-since-create-time: "48h"
retain-since-last-active-time: "15h"
min-non-active-revisions: "2"
max-non-active-revisions: "1000"
```

## Per Revision Options

Users can alwaysretain a revision by adding the annotation `serving.knative.dev/no-gc: "true"`

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
