# Setting Up A Logging Plugin

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
2. Replace the `image` field of `fluentd-ds` container of `flunetd-ds` DaemonSet
   in
   [200-fluentd.yaml](https://github.com/knative/serving/blob/master/config/monitoring/logging/elasticsearch/200-fluentd.yaml)
   with the Fluentd image including the desired Fluentd output plugin. See
   [here](fluentd/README.md) for the requirements of Flunetd image on Knative.

### Configure the Sidecar for log files under /var/log

Currently operators have to configure the Fluentd Sidecar separately for
collecting log files under `/var/log`. An
[effort](https://github.com/knative/serving/issues/818) is in process to get rid
of the sidecar. The steps to configure are:

1. Replace `logging.fluentd-sidecar-output-config` flag in
   [config-observability](https://github.com/knative/serving/blob/master/config/config-observability.yaml)
   with the desired output configuration. **NOTE**: The Fluentd DaemonSet is in
   `monitoring` namespace while the Fluentd sidecar is in the namespace same
   with the app. There may be small differences between the configuration for
   DaemonSet and sidecar even though the desired backends are the same.
2. Replace `logging.fluentd-sidecar-image` flag in
   [config-observability](https://github.com/knative/serving/blob/master/config/config-observability.yaml)
   with the Fluentd image including the desired Fluentd output plugin. In
   theory, this is the same with the one for Fluentd DaemonSet.

## Deploying

Operators need to deploy Knative components after the configuring:

```shell
# Deploy the configuration for sidecar
kubectl apply -f config/config-observability.yaml

# Deploy the DaemonSet to make configuration for DaemonSet take effect
kubectl apply --recursive -f config/monitoring/100-namespace.yaml \
    -f <path-of-fluentd-daemonset-config>
```

In the commands above, replace `<path-of-fluentd-daemonset-config>` with the
Fluentd DaemonSet configuration file, e.g. `config/monitoring/stackdriver`.

**NOTE**: The deployment above will not affect the fluentd sidecar of existing
pods. Developers need to redeploy their app to get the newest configuration for
the fluentd sidecar used to send logs to `/var/log`.

**NOTE**: Operators sometimes need to deploy extra services as the logging
backends. For example, if they desire Elasticsearch&Kibana, they have to deploy
the Elasticsearch and Kibana services. Knative provides this sample:

```shell
kubectl apply --recursive -f third_party/config/monitoring/elasticsearch
```

See [here](/serving/installing-logging-metrics-traces.md) for deploying the
whole Knative monitoring components.

## Uninstalling

To uninstall a logging plugin, run:

```shell
kubectl delete --recursive -f <path-of-fluentd-daemonset-config>
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
