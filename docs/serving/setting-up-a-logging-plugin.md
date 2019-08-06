---
title: "Setting up a logging plugin"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 50
type: "docs"
---

Knative allows cluster operators to use different backends for their logging
needs. This document describes how to change these settings. Knative currently
requires changes in Fluentd configuration files, however we plan on abstracting
logging configuration in the future
([#906](https://github.com/knative/serving/issues/906)). Once
[#906](https://github.com/knative/serving/issues/906) is complete, the
methodology described in this document will no longer be valid and migration to
a new process will be required. In order to minimize the effort for a future
migration, we recommend only changing the output configuration of Fluentd and
leaving the rest intact.

**NOTE**: All the files mentioned below are in
[knative/serving](https://github.com/knative/serving) repository. You run the
commands mentioned below from the root directory of `knative/serving`.

## Configuring

### Configure the DaemonSet for stdout/stderr logs

Operators can do the following steps to configure the Fluentd DaemonSet for
collecting `stdout/stderr` logs from the containers:

1. Replace `900.output.conf` part in
   [100-fluentd-configmap.yaml](https://github.com/knative/serving/blob/master/config/monitoring/logging/elasticsearch/100-fluentd-configmap.yaml)
   with the desired output configuration. Knative provides a sample for sending
   logs to Elasticsearch or Stackdriver. Developers can simply use
   `100-fluentd-configmap.yaml` or override any with other configuration.
2. Replace the `image` field of `fluentd-ds` container of `fluentd-ds` DaemonSet
   in
   [200-fluentd.yaml](https://github.com/knative/serving/blob/master/config/monitoring/logging/elasticsearch/200-fluentd.yaml)
   with the Fluentd image including the desired Fluentd output plugin. See
   [here](./fluentd-requirements.md) for the requirements of Flunetd image on
   Knative.

### Configure the DaemonSet for log files under /var/log

The Fluentd DaemonSet can also capture `/var/log` logs from the containers. To
enable:

- Set `logging.enable-var-log-collection` to `true` in
  [config-observability](https://github.com/knative/serving/blob/master/config/config-observability.yaml)

## Deploying

Operators need to deploy Knative components after the configuring:

```shell
# Deploy the configuration for enabling /var/log collection
kubectl apply --filename config/config-observability.yaml

# Deploy the DaemonSet to make configuration for DaemonSet take effect
kubectl apply --recursive --filename config/monitoring/100-namespace.yaml \
    --filename <path-of-fluentd-daemonset-config>
```

In the commands above, replace `<path-of-fluentd-daemonset-config>` with the
Fluentd DaemonSet configuration file, e.g.
`config/monitoring/logging/stackdriver`.

**NOTE**: The deployment above will not affect the existing pods. Developers
need to redeploy their app to get the newest configuration for `/var/log`
collection.

**NOTE**: Operators sometimes need to deploy extra services as the logging
backends. For example, if they desire Elasticsearch&Kibana, they have to deploy
the Elasticsearch and Kibana services. Knative provides this sample:

```shell
kubectl apply --recursive --filename third_party/config/monitoring/logging/elasticsearch
```

See [here](./installing-logging-metrics-traces.md) for deploying the whole
Knative monitoring components.

## Uninstalling

To uninstall a logging plugin, run:

```shell
kubectl delete --recursive --filename <path-of-fluentd-daemonset-config>
```


