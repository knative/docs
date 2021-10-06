# Configure event source defaults

This topic describes how to configure defaults for Knative event sources. You can configure event sources depending on how they generate events.

## Ping Source Configurations

A [Ping Source](../../developer/eventing/sources/ping-source/README.md) is an event source that produces events with a fixed payload on a specified cron schedule. You can find how to create new Ping Source and the available parameters [here](../../developer/eventing/sources/ping-source/reference.md).

In addition to the parameters that you can configure in the PingSource resource, there is a global ConfigMap called `config-ping-defaults`.
This ConfigMap allows you to change the maximum amount of data that the PingSource adds to the CloudEvents it produces.

The `dataMaxSize` parameter allows you to set the maximum number of bytes allowed to be sent for a message excluding any base64 decoding. The default value, `-1`, sets no limit for data.

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
