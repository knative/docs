---
title: "Migrating from CronJobSource to the PingSource"
weight: 20
type: "docs"
aliases:
   - /docs/eventing/ping.md
---

In 0.13, the deprecated `CronJobSource` should be converted to the `PingSource`.

The YAML file for a `CronJobSource` that emits events to a Knative Serving service will look similar to this:

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

To migrate this source to a `PingSource`, the following steps are required::

* Different `apiVersion` and `kind` between the two
* `PingSource` uses the `jsonData` attribute instead of the `data` attribute.

The updated YAML for `PingSource` will look similar to the following:

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
