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

- Kubernetes requirements:

  - Your Kubernetes cluster version must be v1.11 or newer.

  - Your version of the
    [`kubectl` CLI tool](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    must be v1.10 or newer.

## Installing Istio

> Note: [Ambassador](https://www.getambassador.io/) and [Gloo](https://gloo.solo.io/) are available as an alternative to Istio.
> [Click here](./Knative-with-Ambassador.md) to install Knative with Ambassador.
> [Click here](./Knative-with-Gloo.md) to install Knative with Gloo.

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

- **Serving Component and Observability Plugins**:
  - https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml
  - https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml
  - https://github.com/knative/serving/releases/download/v0.7.0/monitoring-logs-elasticsearch.yaml
  - https://github.com/knative/serving/releases/download/v0.7.0/monitoring-metrics-prometheus.yaml
  - https://github.com/knative/serving/releases/download/v0.7.0/monitoring-tracing-jaeger.yaml
  - https://github.com/knative/serving/releases/download/v0.7.0/monitoring-tracing-jaeger-in-mem.yaml
  - https://github.com/knative/serving/releases/download/v0.7.0/monitoring-tracing-zipkin.yaml
  - https://github.com/knative/serving/releases/download/v0.7.0/monitoring-tracing-zipkin-in-mem.yaml
- **Build Component**:
  - https://github.com/knative/build/releases/download/v0.7.0/build.yaml
- **Eventing Component**:
  - https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml
  - https://github.com/knative/eventing/releases/download/v0.7.0/eventing.yaml
  - https://github.com/knative/eventing/releases/download/v0.7.0/in-memory-channel.yaml
  - https://github.com/knative/eventing/releases/download/v0.7.0/kafka.yaml
- **Eventing sources**:
  - https://github.com/knative/eventing-contrib/releases/download/v0.7.0/github.yaml
  - https://github.com/knative/eventing-contrib/releases/download/v0.7.0/camel.yaml
  - https://github.com/knative/eventing-contrib/releases/download/v0.7.0/gcppubsub.yaml
  - https://github.com/knative/eventing-contrib/releases/download/v0.7.0/kafka.yaml

#### Install details and options

The following table includes details about the available Knative installation
files from the Knative repositories:

- [Serving][1]
- [Build][3]
- [Eventing][4]
- [Eventing Sources][5]

| Knative Install Filename                       | Notes                                                                                                                                                                  | Dependencies                                                                              |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **knative/serving**                            |                                                                                                                                                                        |                                                                                           |
| [`serving.yaml`][1.1]†                         | Installs the Serving component.                                                                                                                                        |                                                                                           |
| [`monitoring.yaml`][1.2]†                      | Installs the [ELK stack][2], [Prometheus][2.1], [Grafana][2.2], and [Zipkin][2.3]**\***                                                                                | Serving component                                                                         |
| [`monitoring-logs-elasticsearch.yaml`][1.3]    | Installs only the [ELK stack][2]**\***                                                                                                                                 | Serving component                                                                         |
| [`monitoring-metrics-prometheus.yaml`][1.4]    | Installs only [Prometheus][2.1]**\***                                                                                                                                  | Serving component                                                                         |
| [`monitoring-tracing-jaeger.yaml`][1.5]        | Installs only [Jaeger][2.4]**\***                                                                                                                                      | Serving component, ELK stack (monitoring-logs-elasticsearch.yaml), [Jaeger Operator][2.5] |
| [`monitoring-tracing-jaeger-in-mem.yaml`][1.6] | Installs only [Jaeger in-memory][2.4]**\***                                                                                                                            | Serving component, [Jaeger Operator][2.5]                                                 |
| [`monitoring-tracing-zipkin.yaml`][1.7]        | Installs only [Zipkin][2.3].**\***                                                                                                                                     | Serving component, ELK stack (monitoring-logs-elasticsearch.yaml)                         |
| [`monitoring-tracing-zipkin-in-mem.yaml`][1.8] | Installs only [Zipkin in-memory][2.3]**\***                                                                                                                            | Serving component                                                                         |
| **knative/build**                              |                                                                                                                                                                        |                                                                                           |
| [`build.yaml`][3.1]†                           | Installs the Build component.                                                                                                                                          |                                                                                           |
| **knative/eventing**                           |                                                                                                                                                                        |                                                                                           |
| [`release.yaml`][4.1]†                         | Installs the Eventing component. Includes [ContainerSource](../eventing#containersource), [CronJobSource][6.2], the in-memory channel provisioner.                     |                                                                                           |
| [`eventing.yaml`][4.2]                         | Installs the Eventing component. Includes [ContainerSource](../eventing#containersource) and [CronJobSource][6.2]. Does not include the in-memory channel provisioner. |                                                                                           |
| [`in-memory-channel.yaml`][4.3]                | Installs only the in-memory channel provisioner.                                                                                                                       | Eventing component                                                                        |
| [`kafka.yaml`][4.4]                            | Installs only the Kafka channel provisioner.                                                                                                                           | Eventing component                                                                        |
| [`natss.yaml`][4.5]                            | Installs only the NATSS channel provisioner.                                                                                                                           | Eventing component                                                                        |
| [`gcp-pubsub.yaml`][4.6]                       | Installs only the GCP PubSub channel provisioner.                                                                                                                      | Eventing component                                                                        |
| **knative/eventing-contrib**                   |                                                                                                                                                                        |                                                                                           |
| [`github.yaml`][5.1]†                          | Installs the [GitHub][6.1] source.                                                                                                                                     | Eventing component                                                                        |
| [`camel.yaml`][5.4]                            | Installs the Apache Camel source.                                                                                                                                      | Eventing component                                                                        |
| [`gcppubsub.yaml`][5.2]                        | Installs the [GCP PubSub source][6.3]                                                                                                                                  | Eventing component                                                                        |
| [`kafka.yaml`][5.5]                            | Installs the Apache Kafka source.                                                                                                                                      | Eventing component                                                                        |
| [`awssqs.yaml`][5.6]                           | Installs the AWS SQS source.                                                                                                                                           | Eventing component                                                                        |
| [`event-display.yaml`][5.3]                    | Installs a Knative Service that logs events received for use in samples and debugging.                                                                                 | Serving component, Eventing component                                                     |

_\*_ See
[Installing logging, metrics, and traces](../serving/installing-logging-metrics-traces.md)
for details about installing the various supported observability plugins.

† These are the recommended standard install files suitable for most use cases.

<!-- USE ONLY FULLY QUALIFIED URLS -->

[1]: https://github.com/knative/serving/releases/tag/v0.7.0
[1.1]: https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml
[1.2]:
  https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml
[1.3]:
  https://github.com/knative/serving/releases/download/v0.7.0/monitoring-logs-elasticsearch.yaml
[1.4]:
  https://github.com/knative/serving/releases/download/v0.7.0/monitoring-metrics-prometheus.yaml
[1.5]:
  https://github.com/knative/serving/releases/download/v0.7.0/monitoring-tracing-jaeger.yaml
[1.6]:
  https://github.com/knative/serving/releases/download/v0.7.0/monitoring-tracing-jaeger-in-mem.yaml
[1.7]:
  https://github.com/knative/serving/releases/download/v0.7.0/monitoring-tracing-zipkin.yaml
[1.8]:
  https://github.com/knative/serving/releases/download/v0.7.0/monitoring-tracing-zipkin-in-mem.yaml
[2]: https://www.elastic.co/elk-stack
[2.1]: https://prometheus.io
[2.2]: https://grafana.com
[2.3]: https://zipkin.io/
[2.4]: https://jaegertracing.io/
[2.5]: https://github.com/jaegertracing/jaeger-operator#installing-the-operator
[3]: https://github.com/knative/build/releases/tag/v0.7.0
[3.1]: https://github.com/knative/build/releases/download/v0.7.0/build.yaml
[4]: https://github.com/knative/eventing/releases/tag/v0.7.0
[4.1]: https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml
[4.2]:
  https://github.com/knative/eventing/releases/download/v0.7.0/eventing.yaml
[4.3]:
  https://github.com/knative/eventing/releases/download/v0.7.0/in-memory-channel.yaml
[4.4]: https://github.com/knative/eventing/releases/download/v0.7.0/kafka.yaml
[4.5]: https://github.com/knative/eventing/releases/download/v0.7.0/natss.yaml
[4.6]:
  https://github.com/knative/eventing/releases/download/v0.7.0/gcp-pubsub.yaml
[5]: https://github.com/knative/eventing-contrib/releases/tag/v0.7.0
[5.1]:
  https://github.com/knative/eventing-contrib/releases/download/v0.7.0/github.yaml
[5.2]:
  https://github.com/knative/eventing-contrib/releases/download/v0.7.0/gcppubsub.yaml
[5.3]:
  https://github.com/knative/eventing-contrib/releases/download/v0.7.0/event-display.yaml
[5.4]:
  https://github.com/knative/eventing-contrib/releases/download/v0.7.0/camel.yaml
[5.5]:
  https://github.com/knative/eventing-contrib/releases/download/v0.7.0/kafka.yaml
[5.6]:
  https://github.com/knative/eventing-contrib/releases/download/v0.7.0/awssqs.yaml
[6]:
  https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#event-v1-core
[6.1]: https://developer.github.com/v3/activity/events/types/
[6.2]:
  https://github.com/knative/eventing-contrib/blob/master/samples/cronjob-source/README.md
[6.3]: https://cloud.google.com/pubsub/

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

      - `https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager`
      - `https://github.com/knative/build/releases/download/v0.7.0/build.yaml`
      - `https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml`
      - `https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml`

      **Note**: By default, the Knative Serving component installation
      (`serving.yaml`) includes a controller for
      [enabling automatic TLS certificate provisioning](../serving/using-auto-tls.md).
      If you do intend on immediately enabling auto certificates in Knative, you
      can remove the
      `--selector networking.knative.dev/certificate-provider!=cert-manager`
      statement to install the controller. Otherwise, you can choose to install
      the auto certificates feature and controller at a later time.

      **Example install commands:**

   - To install the Knative Serving component with the set of observability
     plugins but exclude the auto certificates controller, run the following
     commands:

     1. Installs the CRDs only:

        ```bash
        kubectl apply --selector knative.dev/crd-install=true \
          --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager\
          --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml
        ```

     1. Remove the `--selector knative.dev/crd-install=true` flag and the run
        the command to install the Serving component and observability plugins:

        ```bash
        kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager\
          --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml
        ```

   - To install all three Knative components and the set of Eventing sources
     without an observability plugin, run the following commands.

     In this example, the auto certificate controller is installed so that you
     can
     [enable automatic certificates provisioning](/serving/using-auto-tls.md).

     1. Installs the CRDs only:

        ```bash
        kubectl apply --selector knative.dev/crd-install=true \
          --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml \
          --filename https://github.com/knative/build/releases/download/v0.7.0/build.yaml \
          --filename https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml
        ```

     1. Remove the `--selector knative.dev/crd-install=true` flag and the run
        the command to install all the Knative components, including the
        Eventing sources and auto certificate controller:

        ```bash
        kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml \
          --filename https://github.com/knative/build/releases/download/v0.7.0/build.yaml \
          --filename https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml
        ```

1. Depending on what you chose to install, view the status of your installation
   by running one or more of the following commands. It might take a few
   seconds, so rerun the commands until all of the components show a `STATUS` of
   `Running`:

   ```bash
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-build
   kubectl get pods --namespace knative-eventing
   ```

   > Tip: You can append the `--watch` flag to the `kubectl get` commands to
   > view the pod status in realtime. You use `CTRL + C` to exit watch mode.

1. If you installed an observability plugin, run the following command to ensure
   that the necessary `knative-monitoring` pods show a `STATUS` of `Running`:

   ```bash
   kubectl get pods --namespace knative-monitoring
   ```

   See
   [Installing logging, metrics, and traces](../serving/installing-logging-metrics-traces.md)
   for details about setting up the various supported observability plugins.

You are now ready to deploy an app, run a build, or start sending and receiving
events in your Knative cluster.

## What's next

Depending on the Knative components you installed, you can use the following
guides to help you get started with Knative:

- [Getting Started with Knative App Deployment](./getting-started-knative-app.md)

  - [Knative Serving sample apps](../serving/samples/README.md)

- [Creating a simple Knative Build](../build/creating-builds.md)

  - [Knative Build templates](https://github.com/knative/build-templates)

- [Knative Eventing overview](../eventing/README.md)

  - [Knative Eventing code samples](../eventing/samples/)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
