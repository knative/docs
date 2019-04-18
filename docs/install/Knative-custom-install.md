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

> Note: [Gloo](https://gloo.solo.io/) is available as an alternative to Istio.
> Gloo is not currently compatible with the Knative Eventing component.
> [Click here](./Knative-with-Gloo.md) to install Knative with Gloo.

Knative depends on [Istio](https://istio.io/docs/concepts/what-is-istio/) for
traffic routing and ingress. You have the option of injecting Istio sidecars and
enabling the Istio service mesh, but it's not required for all Knative
components.

You should first install the `istio-crds.yaml` file to ensure that the Istio
[Custom Resource Definitions (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
are created before installing Istio.

### Choosing an Istio installation

You can Istio with or without a service mesh:

- _automatic sidecar injection_: Enables the Istio service mesh by
  [automatically injecting the Istio sidecars](https://istio.io/docs/setup/kubernetes/sidecar-injection/#automatic-sidecar-injection).
  The sidecars are injected into each pod of your cluster as each pod is
  created.

- _manual sidecar injection_: Provides your Knative installation with traffic
  routing and ingress, without the Istio service mesh. You do have the option of
  later enabling the service mesh if you
  [manually inject the Istio sidecars](https://istio.io/docs/setup/kubernetes/sidecar-injection/#manual-sidecar-injection).

If you are just getting started with Knative, you should choose automatic
sidecar injection and enable the Istio service mesh.

Due to current dependencies, some installable Knative options require the Istio
service mesh. If you install any of the following options, you must install
`istio.yaml` so that automatic sidecar injection is enabled:

- [Knative Eventing](https://github.com/knative/eventing)
- [Knative Eventing Sources](https://github.com/knative/eventing-sources)
- [Observability plugins](../serving/installing-logging-metrics-traces.md)

#### Istio installation options

| Istio Install Filename  | Description                                                            |
| ----------------------- | ---------------------------------------------------------------------- |
| [`istio-crds.yaml`][a]† | Creates CRDs before installing Istio.                                  |
| [`istio.yaml`][b]†      | Install Istio with service mesh enabled (automatic sidecar injection). |
| [`istio-lean.yaml`][c]  | Install Istio and disable the service mesh by default.                 |

† These are the recommended standard install files suitable for most use cases.

[a]: https://github.com/knative/serving/releases/download/v0.5.0/istio-crds.yaml
[b]: https://github.com/knative/serving/releases/download/v0.5.0/istio.yaml
[c]: https://github.com/knative/serving/releases/download/v0.5.0/istio-lean.yaml

### Installing Istio

1. If you choose to install the Istio service mesh with automatic sidecar
   injection, you must ensure that the
   [`MutatingAdmissionWebhook` admission controller](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#mutatingwebhookconfiguration-v1beta1-admissionregistration-k8s-io)
   is enabled on your cluster by running the following command:

   ```bash
   kubectl api-versions | grep admissionregistration
   ```

   Result:

   ```bash
   admissionregistration.k8s.io/v1beta1
   ```

   If `admissionregistration.k8s.io/v1beta1` is not listed, follow the
   [Kubernetes instructions about enabling the `MutatingAdmissionWebhook` admission controller](https://kubernetes.io/docs/admin/admission-controllers/#how-do-i-turn-on-an-admission-controller).

   For example, you add `--enable-admission-plugins=MutatingAdmissionWebhook` to
   the `/etc/kubernetes/manifests/kube-apiserver.yaml` file.

1. Create the Istio CRDs on your cluster:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.0/istio-crds.yaml
   ```

1. Install Istio by specifying the filename in the `kubectl apply` command:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.0/[FILENAME].yaml
   ```

   where `[FILENAME]` is the name of the Istio file that you want to install.
   Examples:

   - `istio.yaml`
   - `istio-lean.yaml`

1. If you chose to install the Istio service mesh with automatic sidecar
   injection, you must label the default namespace with
   `istio-injection=enabled`:

   ```bash
   kubectl label namespace default istio-injection=enabled
   ```

   Important: You should set the `istio-injection` namespace, if you intend on
   later enabling the Istio service mesh through manual sidecar injection.

1. View the status of your Istio installation. It might take a few seconds, so
   rerun the following command until all of the pods show a `STATUS` of
   `Running` or `Completed`:

   ```bash
   kubectl get pods --namespace istio-system
   ```

   > Tip: You can append the `--watch` flag to the `kubectl get` commands to
   > view the pod status in realtime. You use `CTRL + C` to exit watch mode.

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
  - https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml
  - https://github.com/knative/serving/releases/download/v0.5.0/monitoring.yaml
  - https://github.com/knative/serving/releases/download/v0.5.0/monitoring-logs-elasticsearch.yaml
  - https://github.com/knative/serving/releases/download/v0.5.0/monitoring-metrics-prometheus.yaml
  - https://github.com/knative/serving/releases/download/v0.5.0/monitoring-tracing-zipkin.yaml
  - https://github.com/knative/serving/releases/download/v0.5.0/monitoring-tracing-zipkin-in-mem.yaml
- **Build Component**:
  - https://github.com/knative/build/releases/download/v0.5.0/build.yaml
- **Eventing Component**:
  - https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml
  - https://github.com/knative/eventing/releases/download/v0.5.0/eventing.yaml
  - https://github.com/knative/eventing/releases/download/v0.5.0/in-memory-channel.yaml
  - https://github.com/knative/eventing/releases/download/v0.5.0/kafka.yaml
- **Eventing sources**:
  - https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml
  - https://github.com/knative/eventing-sources/releases/download/v0.5.0/camel.yaml
  - https://github.com/knative/eventing-sources/releases/download/v0.5.0/gcppubsub.yaml
  - https://github.com/knative/eventing-sources/releases/download/v0.5.0/kafka.yaml
  - https://github.com/knative/eventing-sources/releases/download/v0.5.0/event-display.yaml
- **Cluster roles**:
  - https://raw.githubusercontent.com/knative/serving/v0.5.0/third_party/config/build/clusterrole.yaml

#### Install details and options

The following table includes details about the available Knative installation
files from the Knative repositories:

- [Serving][1]
- [Build][3]
- [Eventing][4]
- [Eventing Sources][5]

| Knative Install Filename                       | Notes                                                                                                                          | Dependencies                                                      |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| **knative/serving**                            |                                                                                                                                |                                                                   |
| [`serving.yaml`][1.1]†                         | Installs the Serving component.                                                                                                | Cluster roles enabled, if interacting with Build                  |
| [`monitoring.yaml`][1.2]†                      | Installs the [ELK stack][2], [Prometheus][2.1], [Grafana][2.2], and [Zipkin][2.3]**\***                                        | Serving component                                                 |
| [`monitoring-logs-elasticsearch.yaml`][1.3]    | Installs only the [ELK stack][2]**\***                                                                                         | Serving component                                                 |
| [`monitoring-metrics-prometheus.yaml`][1.4]    | Installs only [Prometheus][2.1]**\***                                                                                          | Serving component                                                 |
| [`monitoring-tracing-zipkin.yaml`][1.5]        | Installs only [Zipkin][2.3].**\***                                                                                             | Serving component, ELK stack (monitoring-logs-elasticsearch.yaml) |
| [`monitoring-tracing-zipkin-in-mem.yaml`][1.6] | Installs only [Zipkin in-memory][2.3]**\***                                                                                    | Serving component                                                 |
| **knative/build**                              |                                                                                                                                |                                                                   |
| [`build.yaml`][3.1]†                         | Installs the Build component.                                                                                                  | Cluster roles enabled, if interacting with Serving                |
| **knative/eventing**                           |                                                                                                                                |                                                                   |
| [`release.yaml`][4.1]†                         | Installs the Eventing component. Includes the in-memory channel provisioner.                                                   | Serving component                                                 |
| [`eventing.yaml`][4.2]                         | Installs the Eventing component. Does not include the in-memory channel provisioner.                                           | Serving component                                                 |
| [`in-memory-channel.yaml`][4.3]                | Installs only the in-memory channel provisioner.                                                                               | Serving component, Eventing component                             |
| [`kafka.yaml`][4.4]                            | Installs only the Kafka channel provisioner.                                                                                   | Serving component, Eventing component                             |
| **knative/eventing-sources**                   |                                                                                                                                |                                                                   |
| [`eventing-sources.yaml`][5.1]†                | Installs the following sources: [Kubernetes][6], [GitHub][6.1], [Container image](../eventing#containersource), [CronJob][6.2] | Serving component, Eventing component                             |
| [`camel.yaml`][5.4]                            | Installs the Apache Camel source.                                                                                              | Serving component, Eventing component                             |
| [`gcppubsub.yaml`][5.2]                        | Installs the [GCP PubSub source][6.3]                                                                                          | Serving component, Eventing component                             |
| [`kafka.yaml`][5.5]                            | Installs the Apache Kafka source.                                                                                              | Serving component, Eventing component                             |
| [`event-display.yaml`][5.3]                    | Installs a Knative Service that logs events received for use in samples and debugging.                                         | Serving component, Eventing component                             |
| **Cluster roles**                              |                                                                                                                                |                                                                   |
| [`clusterrole.yaml`][7]†                       | Enables the Build and Serving components to interact.                                                                          | Serving component, Build component                                |

_\*_ See
[Installing logging, metrics, and traces](../serving/installing-logging-metrics-traces.md)
for details about installing the various supported observability plugins.

† These are the recommended standard install files suitable for most use cases.

<!-- USE ONLY FULLY QUALIFIED URLS -->

[1]: https://github.com/knative/serving/releases/tag/v0.5.0
[1.1]: https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml
[1.2]:
  https://github.com/knative/serving/releases/download/v0.5.0/monitoring.yaml
[1.3]:
  https://github.com/knative/serving/releases/download/v0.5.0/monitoring-logs-elasticsearch.yaml
[1.4]:
  https://github.com/knative/serving/releases/download/v0.5.0/monitoring-metrics-prometheus.yaml
[1.5]:
  https://github.com/knative/serving/releases/download/v0.5.0/monitoring-tracing-zipkin.yaml
[1.6]:
  https://github.com/knative/serving/releases/download/v0.5.0/monitoring-tracing-zipkin-in-mem.yaml
[2]: https://www.elastic.co/elk-stack
[2.1]: https://prometheus.io
[2.2]: https://grafana.com
[2.3]: https://zipkin.io/
[3]: https://github.com/knative/build/releases/tag/v0.5.0
[3.1]: https://github.com/knative/build/releases/download/v0.5.0/build.yaml
[4]: https://github.com/knative/eventing/releases/tag/v0.5.0
[4.1]: https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml
[4.2]:
  https://github.com/knative/eventing/releases/download/v0.5.0/eventing.yaml
[4.3]:
  https://github.com/knative/eventing/releases/download/v0.5.0/in-memory-channel.yaml
[4.4]: https://github.com/knative/eventing/releases/download/v0.5.0/kafka.yaml
[5]: https://github.com/knative/eventing-sources/releases/tag/v0.5.0
[5.1]:
  https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml
[5.2]:
  https://github.com/knative/eventing-sources/releases/download/v0.5.0/gcppubsub.yaml
[5.3]:
  https://github.com/knative/eventing-sources/releases/download/v0.5.0/event-display.yaml
[5.4]:
  https://github.com/knative/eventing-sources/releases/download/v0.5.0/camel.yaml
[5.5]:
  https://github.com/knative/eventing-sources/releases/download/v0.5.0/kafka.yaml
[6]:
  https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#event-v1-core
[6.1]: https://developer.github.com/v3/activity/events/types/
[6.2]:
  https://github.com/knative/eventing-sources/blob/master/samples/cronjob-source/README.md
[6.3]: https://cloud.google.com/pubsub/
[7]:
  https://raw.githubusercontent.com/knative/serving/v0.5.0/third_party/config/build/clusterrole.yaml

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
   run the install command first with the `-l knative.dev/crd-install=true` flag,
   then a second time without the selector flag. This installs the CRDs first:

     ```bash
     kubectl apply --selector knative.dev/crd-install=true \
     --filename [FILE_URL] \
     --filename [FILE_URL]
     ```

   - Then run the `kubectl apply` command again without the `-l` flag to
   complete the install:

     ```bash
     kubectl apply --filename [FILE_URL] \
     --filename [FILE_URL]
     ```

     You can add as many `--filename [FILE_URL]` as needed.

     [`FILE_URL`] is the URL path of the desired Knative release:

     `https://github.com/knative/[COMPONENT]/releases/download/[VERSION]/[FILENAME].yaml`

     `[COMPONENT]`, `[VERSION]`, and `[FILENAME]` are the Knative component,
     release version, and filename of the Knative component or plugin. Examples:

     - `https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml`
     - `https://github.com/knative/build/releases/download/v0.5.0/build.yaml`
     - `https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml`
     - `https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml`

    **Example install commands:**

     - To install the Knative Serving component with the set of observability
       plugins, enter the following command. The `--selector` flag
       installs the CRDs first:

       ```bash
       kubectl apply --selector knative.dev/crd-install=true \
       --filename https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml \
       --filename https://github.com/knative/serving/releases/download/v0.5.0/monitoring.yaml
       ```
       Then complete the install by running the command again, this time without
       `--selector knative.dev/crd-install=true`:

       ```bash
       kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml \
       --filename https://github.com/knative/serving/releases/download/v0.5.0/monitoring.yaml
       ```

   * To install all three Knative components and the set of Eventing sources
     without an observability plugin, enter the following command. The
    `--selector` flag installs the CRDs first:

      ```bash
      kubectl apply --selector knative.dev/crd-install=true \
      --filename https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml \
      --filename https://github.com/knative/build/releases/download/v0.5.0/build.yaml \
      --filename https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml \
      --filename https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml \
      --filename https://raw.githubusercontent.com/knative/serving/v0.5.0/third_party/config/build/clusterrole.yaml
      ```

     Then complete the install by running the command again, this time without
     `--selector knative.dev/crd-install=true`:

      ```bash
      kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml \
      --filename https://github.com/knative/build/releases/download/v0.5.0/build.yaml \
      --filename https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml \
      --filename https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml \
      --filename https://raw.githubusercontent.com/knative/serving/v0.5.0/third_party/config/build/clusterrole.yaml
      ```

1. Depending on what you chose to install, view the status of your installation
   by running one or more of the following commands. It might take a few
   seconds, so rerun the commands until all of the components show a `STATUS` of
   `Running`:

   ```bash
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-build
   kubectl get pods --namespace knative-eventing
   kubectl get pods --namespace knative-sources
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
