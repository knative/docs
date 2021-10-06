# Sources Configurations

Each Knative Source can be configured depending on how it is generating events. This document contains details about how to configure the available Sources that can be configured.

## Ping Source Configurations

A [Ping Source](../../developer/eventing/sources/ping-source/README.md) is an event source that produces events with a fixed payload on a specified cron schedule. You can find how to create new Ping Source and the available parameters [here](../../developer/eventing/sources/ping-source/reference.md).

Besides the parameters that can be configured in the `PingSource` resources, there is a global `ConfigMap` called `config-ping-defaults`.

This `ConfigMap` allows you to change the maximun amount of data that the `PingSource` will add to the produced CloudEvents.

The `dataMaxSize` parameter allows you to set the max number of bytes allowed to be sent for message excluding any base64 decoding. The default value (-1) is no limit set for data.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-ping-defaults
  namespace: knative-eventing
data:
  dataMaxSize: -1
```

You can edit this `ConfigMap` by running:

```
kubectl edit cm config-ping-defaults -n knative-eventing
```