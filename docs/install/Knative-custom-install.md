---
title: "Performing a Custom Knative Installation"
linkTitle: "Customizing your install"
weight: 15
type: "docs"
---

Use this guide to perform a custom installation of Knative on an existing
Kubernetes cluster. Knative's pluggable components allow you to install only
what you need.

The steps covered in this guide are for advanced operators who want to customize
each Knative installation. Installing individual Knative components requires you
to run multiple installation commands.

## Before you begin

- If you are new to Knative, you should instead
  [follow one of the platform-specific installation guides](./README.md) to help
  you get up and running quickly.

- The steps in this guide use `bash` for the MacOS or Linux environment; for
  Windows, some commands might need adjustment.

- This guide assumes that you have an existing Kubernetes cluster, on which
  you're comfortable installing and running _alpha_ level software.

- Knative requires a Kubernetes cluster v1.14 or newer, as well as a compatible
`kubectl`.

## Installing Istio

Knative depends on [Istio](https://istio.io/docs/concepts/what-is-istio/) for
traffic routing and ingress. You have the option of injecting Istio sidecars and
enabling the Istio service mesh, but it's not required for all Knative
components.

If your cloud platform offers a managed Istio installation, we recommend
installing Istio that way, unless you need the ability to customize your
installation.

If you prefer to install Istio manually, if your cloud provider doesn't offer a
managed Istio installation, or if you're installing Knative locally using
Minkube or similar, see the
[Installing Istio for Knative guide](./installing-istio.md).

> Note: [Ambassador](https://www.getambassador.io/) and
> [Gloo](https://gloo.solo.io/) are available as an alternative to Istio.
> [Click here](./Knative-with-Ambassador.md) to install Knative with Ambassador.
> [Click here](./Knative-with-Gloo.md) to install Knative with Gloo.

## Installing `cluster-local-gateway` for serving cluster-internal traffic

If you installed Istio, you can install a `cluster-local-gateway` within your Knative cluster so that you can serve cluster-internal traffic. If you want to configure your revisions to use routes that are visible only within your cluster, [install and use the `cluster-local-gateway`](./installing-istio#updating-your-install-to-use-cluster-local-gateway).

## Installing Knative components

Each Knative component must be installed individually. You can decide which
components and observability plugins to install based on what you plan to do
with Knative.

> **Note**: If your install fails on the first attempt, try rerunning the
> commands. They will likely succeed on the second attempt. For background info
> and to track the upcoming solution to this problem, see issues
> [#968](https://github.com/knative/docs/issues/968) and
> [#1036](https://github.com/knative/docs/issues/1036).

### Choosing Knative installation files

The following Knative installation files are available:

- **Serving Component**:
  - https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml
  - https://github.com/knative/serving/releases/download/{{< version >}}/serving-cert-manager.yaml
- **Observability Plugins**:
  - https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
  - https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-logs-elasticsearch.yaml
  - https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-metrics-prometheus.yaml
  - https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-tracing-jaeger.yaml
  - https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-tracing-jaeger-in-mem.yaml
  - https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-tracing-zipkin.yaml
  - https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-tracing-zipkin-in-mem.yaml
- **Eventing Component**:
  - https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml
  - https://github.com/knative/eventing/releases/download/{{< version >}}/eventing.yaml
  - https://github.com/knative/eventing/releases/download/{{< version >}}/in-memory-channel.yaml
- **Eventing Resources**:
  - https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/github.yaml
  - https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/camel.yaml
  - https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/gcppubsub.yaml
  - https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/kafka.yaml
  - https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/kafka-channel.yaml

#### Install details and options

The following table includes details about the available Knative installation
files from the Knative repositories:

- [Serving][1.0]
- [Eventing][4.0]
- [Eventing Resources][5.0]

| Knative Install Filename                       | Notes                                                                                                                                                                  | Dependencies                                                                              |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **knative/serving**                             |                                                                                                                                                                        |                                                                                           |
| [`serving.yaml`][1.10]†                     | Installs the Serving component.                                                                                                                          |                                                                                     |
| [`serving-cert-manager.yaml`][1.20]      | Installs support for `cert-manager` and [automatic TLS cert provisioning](../serving/using-auto-tls.md).    | Serving component                                        |
| **Observability plugins**                             |                                                                                                                                                                        |                                                                                           |
| [`monitoring.yaml`][1.30]†                      | Installs the [ELK stack][2.0], [Prometheus][2.10], [Grafana][2.20], and [Zipkin][2.30]**\***                                                                                | Serving component                                                              |
| [`monitoring-logs-elasticsearch.yaml`][1.40]    | Installs only the [ELK stack][2.0]**\***                                                                                                                                 | Serving or Eventing component                                                                         |
| [`monitoring-metrics-prometheus.yaml`][1.50]    | Installs only [Prometheus][2.10]**\***                                                                                                                                  | Serving component                                                                         |
| [`monitoring-tracing-jaeger.yaml`][1.60]        | Installs only [Jaeger][2.40]**\***                                                                                                                                      | Serving or Eventing component, ELK stack (monitoring-logs-elasticsearch.yaml), [Jaeger Operator][2.50] |
| [`monitoring-tracing-jaeger-in-mem.yaml`][1.70] | Installs only [Jaeger in-memory][2.40]**\***                                                                                                                            | Serving or Eventing component, [Jaeger Operator][2.50]                           |
| [`monitoring-tracing-zipkin.yaml`][1.80]        | Installs only [Zipkin][2.30].**\***                                                                                                                                     | Serving or Eventing component, ELK stack (monitoring-logs-elasticsearch.yaml)     |
| [`monitoring-tracing-zipkin-in-mem.yaml`][1.90] | Installs only [Zipkin in-memory][2.30]**\***                                                                                                                            | Serving or Eventing component                                                                  |
| **knative/eventing**                           |                                                                                                                                                                        |                                                                                           |
| [`release.yaml`][4.1]†                         | Installs the Eventing component. Includes [ContainerSource](../eventing#containersource), [CronJobSource][6.2], InMemoryChannel.                     |                                                                                           |
| [`eventing.yaml`][4.2]                         | Installs the Eventing component. Includes [ContainerSource](../eventing#containersource) and [CronJobSource][6.2]. Does not include any Channel. |                                                                                           |
| [`in-memory-channel.yaml`][4.3]            | Installs only the InMemoryChannel.                                                                                                                       | Eventing component                                                                        |
| **knative/eventing-contrib**                   |                                                                                                                                                                        |                                                                                           |
| [`github.yaml`][5.10]†                          | Installs the [GitHub][6.10] source.                                                                                                                                     | Eventing component                                                                        |
| [`camel.yaml`][5.40]                            | Installs the Apache Camel source.                                                                                                                                      | Eventing component                                                                        |
| [`kafka-source.yaml`][5.50]                     | Installs the Apache Kafka source.                                                                                                                                      | Eventing component                                                                        |
| [`kafka-channel.yaml`][5.60]                    | Installs the KafkaChannel.                                                                                                                                      | Eventing component                                                                        |
| [`awssqs.yaml`][5.70]                           | Installs the AWS SQS source.                                                                                                                                           | Eventing component                                                                        |
| [`event-display.yaml`][5.30]                    | Installs a Knative Service that logs events received for use in samples and debugging.                                                                                 | Serving component, Eventing component                                                     |
| [`natss-channel.yaml`][5.80]                    | Installs the NATS streaming channel implementation.                                                                                                                       | Eventing component                                                                        |
| **knative/google/knative-gcp**                  |                                                                                                                                                                           |                                                                                           |
| [`cloud-run-events.yaml`][7.10]                 | Installs the GCP PubSub channel implementation                                                                                                                            |                                                                                           |

_\*_ See
[Installing logging, metrics, and traces](../serving/installing-logging-metrics-traces.md)
for details about installing the various supported observability plugins.

† These are the recommended standard install files suitable for most use cases.

<!-- USE ONLY FULLY QUALIFIED URLS -->

[1.0]: https://github.com/knative/serving/releases/tag/{{< version >}}
[1.10]: https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml
[1.20]: https://github.com/knative/serving/releases/download/{{< version >}}/serving-cert-manager.yaml
[1.30]:
  https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
[1.40]:
  https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-logs-elasticsearch.yaml
[1.50]:
  https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-metrics-prometheus.yaml
[1.60]:
  https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-tracing-jaeger.yaml
[1.70]:
  https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-tracing-jaeger-in-mem.yaml
[1.80]:
  https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-tracing-zipkin.yaml
[1.90]:
  https://github.com/knative/serving/releases/download/{{< version >}}/monitoring-tracing-zipkin-in-mem.yaml
[2.0]: https://www.elastic.co/elk-stack
[2.10]: https://prometheus.io
[2.20]: https://grafana.com
[2.30]: https://zipkin.io/
[2.40]: https://jaegertracing.io/
[2.50]: https://github.com/jaegertracing/jaeger-operator#installing-the-operator
[4.0]: https://github.com/knative/eventing/releases/tag/{{< version >}}
[4.10]: https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml
[4.20]:
  https://github.com/knative/eventing/releases/download/{{< version >}}/eventing.yaml
[4.30]:
  https://github.com/knative/eventing/releases/download/{{< version >}}/in-memory-channel.yaml
[4.40]: https://github.com/knative/eventing/releases/download/{{< version >}}/kafka.yaml
[5.0]: https://github.com/knative/eventing-contrib/releases/tag/{{< version >}}
[5.10]:
  https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/github.yaml
[5.30]:
  https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/event-display.yaml
[5.40]:
  https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/camel.yaml
[5.50]:
  https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/kafka-source.yaml
[5.60]:
  https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/kafka-channel.yaml
[5.70]:
  https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/awssqs.yaml
[5.80]:
  https://github.com/knative/eventing-contrib/releases/download/{{< version >}}/natss.yaml  
[6.10]: https://developer.github.com/v3/activity/events/types/
[6.20]:
  https://github.com/knative/eventing-contrib/blob/master/samples/cronjob-source/README.md
[7.0]: https://github.com/google/knative-gcp/releases/tag/{{< version >}}
[7.10]: https://github.com/google/knative-gcp/releases/download/{{< version >}}/cloud-run-events.yaml

### Installing Knative

**Tip**: From the table above, copy and paste the URL and filename into the
commands below.

1. If you are upgrading from Knative 0.3.x: Update your domain and static IP
   address to be associated with the LoadBalancer `istio-ingressgateway` instead
   of `knative-ingressgateway`. Then run the following to clean up leftover
   resources:

   ```
   kubectl delete svc knative-ingressgateway -n istio-system
   kubectl delete deploy knative-ingressgateway -n istio-system
   ```

   If you have the Knative Eventing Sources component installed, you will also
   need to delete the following resource before upgrading:

   ```
   kubectl delete statefulset/controller-manager -n knative-sources
   ```

   While the deletion of this resource during the upgrade process will not
   prevent modifications to Eventing Source resources, those changes will not be
   completed until the upgrade process finishes.

1. To install Knative components or plugins, specify the filenames in the
   `kubectl apply` command. To prevent install failures due to race conditions,
   run the install command first with the `-l knative.dev/crd-install=true`
   flag, then a second time without the selector flag.

   1. Install only the CRDs by using the
      `--selector knative.dev/crd-install=true` flag:

      ```bash
      kubectl apply --selector knative.dev/crd-install=true \
      --filename [FILE_URL] \
      --filename [FILE_URL]
      ```

   1. Remove `--selector knative.dev/crd-install=true` and then run the command
      again to install the actual components or plugins:

      ```bash
      kubectl apply --filename [FILE_URL] \
      --filename [FILE_URL]
      ```

      You can add as many `--filename [FILE_URL]` flags to your commands as
      needed.

      Syntax:

      - `[FILE_URL]`: URL path of a Knative component or plugin:
        `https://github.com/knative/[COMPONENT]/releases/download/[VERSION]/[FILENAME].yaml`

        - `[COMPONENT]`: A Knative component repository.
        - `[VERSION]`: Version number of a Knative component release.
        - `[FILENAME]`: Filename of the component or plugin that you want
          installed.

      `[FILE_URL]`Examples:

      - `https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml`
      - `https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml`
      - `https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml`

      **Example install commands:**

   - To install the Knative Serving component with the set of observability
     plugins, run the following commands:

     1. Installs the CRDs only:

        ```bash
        kubectl apply --selector knative.dev/crd-install=true \
          --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
          --filename https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
        ```

     1. Remove the `--selector knative.dev/crd-install=true` flag and then run
        the command to install the Serving component and observability plugins:

        ```bash
        kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
          --filename https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
        ```

   - To install all three Knative components without an observability plugin, 
     run the following commands.
     
     1. Installs the CRDs only:

        ```bash
        kubectl apply --selector knative.dev/crd-install=true \
          --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
          --filename https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml
        ```

     1. Remove the `--selector knative.dev/crd-install=true` flag and then run
        the command to install all the Knative components, including the
        Eventing resources:

        ```bash
        kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
          --filename https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml
        ```

1. Depending on what you chose to install, view the status of your installation
   by running one or more of the following commands. It might take a few
   seconds, so rerun the commands until all of the components show a `STATUS` of
   `Running`:

   ```bash
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-eventing
   ```

   > Tip: You can append the `--watch` flag to the `kubectl get` commands to
   > view the pod status in realtime. You use `CTRL + C` to exit watch mode.

1. If you installed an observability plugin, run the following command to ensure
   that the necessary `knative-monitoring` pods show a `STATUS` of `Running`:

   ```bash
   kubectl get pods --namespace knative-monitoring
   ```

See the following topics for information about installing other Knative features:

- [Installing logging, metrics, and traces](../serving/installing-logging-metrics-traces.md):
  Learn how to install and set up the various observability plugins.
   
- [Installing Cert-Manager](../serving/installing-cert-manager.md):
  Learn how to set up and configure secure HTTPS requests and enable
  [automatic TLS cert provisioning](../serving/using-auto-tls.md).

You are now ready to deploy an app or start sending and receiving
events in your Knative cluster.

## What's next

Depending on the Knative components you installed, you can use the following
guides to help you get started with Knative:

- [Getting Started with Knative App Deployment](../serving/getting-started-knative-app.md)

  - [Knative Serving sample apps](../serving/samples/README.md)

- [Knative Eventing overview](../eventing/README.md)

  - [Knative Eventing code samples](../eventing/samples/)
