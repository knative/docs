---
title: "Migrating to the PingSource"
weight: 20
type: "docs"
aliases:
   - /docs/eventing/ping.md
---

The _deprecated_ `CronJobsource` should be converted to the newer `PingSource`.

Imagine you have a `CronJobSource` running in your cluster that emits its events to a Knative Serving Service.
The installation YAML would look like:

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: cronjob-source
spec:
  schedule: "* * * * *"
  data: '{"message": "Hello world!"}'
  sink:
    apiVersion: serving.knative.dev/v1
    kind: Service
    name: event-display
```

If you now want to migration to the newer `PingSource`, a couple of steps are needed:

* different GVK (see `apiVersion` and `kind` differences) 
* the `PingSources` does use `jsonData` instead of `data`

The final result would looke like:

```yaml
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource
metadata:
  name: ping-source
spec:
  schedule: "* * * * *"
  jsonData: '{"message": "Hello world!"}'
  sink:
    ref:
    apiVersion: serving.knative.dev/v1
    kind: Service
    name: event-display
```
