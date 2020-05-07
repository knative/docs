---
title: "Configuring target burst capacity"
linkTitle: "Configuring target burst capacity"
weight: 50
type: "docs"
---

_Target burst capacity_ is a [global and per-revision](./autoscaling-concepts.md) integer setting that determines the size of traffic burst a Knative application can handle without buffering.

If a traffic burst is too large for the application to handle, the _Activator_ service will be placed in the request path to protect the revision and optimize request load balancing.

The Activator service is responsible for receiving and buffering requests for inactive revisions, or for revisions where a traffic burst is larger than the limits of what can be handled without buffering for that revision.

Target burst capacity can be configured using a combination of the following parameters:

* Setting the targeted concurrency limits for the revision. For more information, see the documentation on [concurrency](./concurrency.md).
* Setting the target utilization parameters. For more information, see the documentation on [target utilization](./concurrency.md#target-utilization).
* Setting the target burst capacity per revision.

## Setting the target burst capacity per revision

* **Global key:** No global key.
* **Per-revision annotation key:** `autoscaling.knative.dev/targetBurstCapacity`
* **Possible values:** float
* **Default:** `70`

**Note:** If the activator is in the routing path, it will fully load all replicas up to `containerConcurrency`. It currently applies target utilization only on revision level.

**Example:**
{{< tabs name="targetBurstCapacity" default="Per Revision" >}}
{{% tab name="Per Revision" %}}
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  annotations:
  name: s3
  namespace: default
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "2"
        autoscaling.knative.dev/targetBurstCapacity: "70"
```
{{< /tab >}}
{{< /tabs >}}
