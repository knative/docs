# Performing a Custom Knative Installation

Use this guide to perform custom installations of Knative on your existing
Kubernetes clusters. Knative's pluggable components allow you to install only
what you want in each of your clusters.

The steps covered in the guide are for advanced operators who want to customize
each Knative installation. Installing individual Knative components requires
that you to run multiple and separate installation commands.

## Before you begin

- If you are new to Knative, you should instead
  [install one of the default installation packages](./README.md). Follow the
  host specific Knative installation instructions to help you get up and running
  with the least effort. Installing a default package also ensures that you can
  run all the
  [Knative Serving Samples](https://github.com/knative/docs/blob/master/serving/samples/README.md).

- The steps in this guide use `bash` for the MacOS or Linux environment; for
  Windows, some commands might need adjustment.

- This guide assumes that you have an existing Kubernetes cluster, on which
  you're comfortable installing and running _alpha_ level software.

- Kubernetes requirements:

  - Your Kubernetes cluster version must be v1.10 or newer.

  - Your version of the
    [`kubectl` CLI tool](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    must be v1.10 or newer.

## Installing Istio

Knative depends on [Istio](https://istio.io/docs/concepts/what-is-istio/) for
traffic routing and ingress. You have to option of injecting Istio sidecars and
enabling the Istio service mesh, but it's not required for certain Knative
component.

You should first install the `istio-crds.yaml` package to ensure that the Istio
[Custom Resource Definitions (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
are created before installing one of the Istio install packages.

### Choosing an Istio installation package

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
service mesh. If you install any of the following options, you must install the
`istio.yaml` package so that automatic sidecar injection is enabled:

- [Knative Eventing](https://github.com/knative/eventing)
- [Knative Eventing Sources](https://github.com/knative/eventing-sources)
- [Observability plugins](../serving/installing-logging-metrics-traces.md)

#### Istio installation packages

| Istio Package Filename | Description                                                            |
| ---------------------- | ---------------------------------------------------------------------- |
| [`istio-crds.yaml`][a] | Initially create CRDs before installing Istio.                         |
| [`istio.yaml`][b]      | Install Istio with service mesh enabled (automatic sidecar injection). |
| [`istio-lean.yaml`][c] | Install Istio and disable the service mesh by default.                 |

[a]: https://github.com/knative/serving/releases/download/v0.2.3/istio-crds.yaml
[b]: https://github.com/knative/serving/releases/download/v0.2.3/istio.yaml
[c]: https://github.com/knative/serving/releases/download/v0.2.3/istio-lean.yaml

### Installing Istio installation packages

1. If you choose to install the Istio service mesh with automatic sidecar
   injection, you must ensure that the
   [`MutatingAdmissionWebhook` admission controller](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#mutatingwebhookconfiguration-v1beta1-admissionregistration-k8s-io)
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
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.3/istio-crds.yaml
   ```

1. Install Istio by specifying the package's path and filename in the
   `kubectl apply` command:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.3/[FILENAME].yaml
   ```

   where `[FILENAME]` is the name of the Istio package that you want to install.
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

1. View the status of your Istio installation. It might take a few seconds so
   rerun the following command until all of the pods show a `STATUS` of
   `Running` or `Completed`:

   ```bash
   kubectl get pods --namespace istio-system
   ```

   > Tip: You can append the `--watch` flag to the `kubectl get` commands to
   > view the pod status in realtime. You use `CTRL + C` to exit watch mode.

## Installing Knative components

You can install each Knative component independently or use the default packages
to install multiple components. The individual component packages exclude an
observability plugin but you have the option to install one later.

### Choosing Knative installation packages

The following Knative installation packages are available:

- **Multiple Component Bundle**:

  - https://github.com/knative/serving/releases/download/v0.2.3/release.yaml
  - https://github.com/knative/serving/releases/download/v0.2.3/release-no-mon.yaml
  - https://github.com/knative/serving/releases/download/v0.2.3/release-lite.yaml

    If you are new to Knative, you should install a bundle to get started. More
    information about installing a bundle are in the
    [install guides](./README.md).

- **Build Component**:
  - https://github.com/knative/build/releases/download/v0.2.0/release.yaml
- **Eventing Component**:
  - https://github.com/knative/eventing/releases/download/v0.2.1/release.yaml
  - https://github.com/knative/eventing/releases/download/v0.2.1/eventing.yaml
  - https://github.com/knative/eventing-sources/releases/download/v0.2.1/release.yaml
  - https://github.com/knative/eventing-sources/releases/download/v0.2.1/release-with-gcppubsub.yaml
- **Serving Component**:
  - https://github.com/knative/serving/releases/download/v0.2.3/serving.yaml

#### Install package details and options

The following table includes details about the available Knative installation
packages from the Knative repositories:

- [Serving][1]
- [Build][3]
- [Eventing][4]
- [Eventing Sources][5]

| Knative Package Filename                             | Serving Component | Observability Plugin\*                                     | Build Component | Eventing Component | Eventing Notes                                                                      |
| ---------------------------------------------------- | ----------------- | ---------------------------------------------------------- | --------------- | ------------------ | ----------------------------------------------------------------------------------- |
| **knative/serving**                                  |                   |                                                            |                 |                    |                                                                                     |
| [`release.yaml`][1.1]                                | Included          | [ELK stack][2] with [Prometheus][2.1] and [Grafana][2.2]\* | Included        | -                  | -                                                                                   |
| [`release-no-mon.yaml`][1.2]                         | Included          | -                                                          | Included        | -                  | -                                                                                   |
| [`release-lite.yaml`][1.3]                           | Included          | [Prometheus][2.1] and [Grafana][2.2]\*                     | Included        | -                  |                                                                                     |
| [`serving.yaml`][1.4]                                | Included          | -                                                          | -               | -                  | -                                                                                   |
| [`build.yaml`][1.5] (copied from [knative/build][3]) | -                 | -                                                          | Included        | -                  | -                                                                                   |
| **knative/build**                                    |                   |                                                            |                 |                    |                                                                                     |
| [`release.yaml`][3.1]                                | -                 | -                                                          | Included        | -                  | -                                                                                   |
| **knative/eventing**                                 |                   |                                                            |                 |                    |                                                                                     |
| [`release.yaml`][4.1]                                | _Required_        | -                                                          | -               | Included           | Includes the in-memory channel provisioner.                                         |
| [`eventing.yaml`][4.2]                               | _Required_        | -                                                          | -               | Included           | No channel provisioner.                                                             |
| [`in-memory-channel.yaml`][4.3]                      | _Required_        | -                                                          | -               | _Required_         | Only the in-memory channel provisioner.                                             |
| [`kafka.yaml`][4.4]                                  | _Required_        | -                                                          | -               | _Required_         | Only the Kafka channel provisioner.                                                 |
| **knative/eventing-sources**                         |                   |                                                            |                 |                    |                                                                                     |
| [`release.yaml`][5.1]                                | _Required_        | -                                                          | -               | _Required_         | Source types: [Kubernetes][6], [GitHub][6.1], [Container image][6.3]                |
| [`release-with-gcppubsub.yaml`][5.2]                 | _Required_        | -                                                          | -               | _Required_         | Source types: [Kubernetes][6], [GitHub][6.1], [Container image][6.3], [PubSub][6.4] |
| [`message-dumper.yaml`][5.3]                         | _Required_        | -                                                          | -               | _Required_         | Event logging service for debugging.                                                |

_\*_ See
[Installing observability plugins](../serving/installing-logging-metrics-traces.md)
for details about the supported plugins and how to add monitoring, logging, and
tracing to your cluster.

[1]: https://github.com/knative/serving/releases/tag/v0.2.2
[1.1]: https://github.com/knative/serving/releases/download/v0.2.3/release.yaml
[1.2]:
  https://github.com/knative/serving/releases/download/v0.2.3/release-no-mon.yaml
[1.3]:
  https://github.com/knative/serving/releases/download/v0.2.3/release-lite.yaml
[1.4]: https://github.com/knative/serving/releases/download/v0.2.3/serving.yaml
[1.5]: https://github.com/knative/serving/releases/download/v0.2.3/build.yaml
[2]: https://www.elastic.co/elk-stack
[2.1]: https://prometheus.io
[2.2]: https://grafana.com
[3]: https://github.com/knative/build/releases/tag/v0.2.0
[3.1]: https://github.com/knative/build/releases/download/v0.2.0/release.yaml
[4]: https://github.com/knative/eventing/releases/tag/v0.2.1
[4.1]: https://github.com/knative/eventing/releases/download/v0.2.1/release.yaml
[4.2]:
  https://github.com/knative/eventing/releases/download/v0.2.1/eventing.yaml
[4.3]:
  https://github.com/knative/eventing/releases/download/v0.2.1/in-memory-channel.yaml
[4.4]: https://github.com/knative/eventing/releases/download/v0.2.1/kafka.yaml
[5]: https://github.com/knative/eventing-sources/releases/tag/v0.2.1
[5.1]:
  https://github.com/knative/eventing-sources/releases/download/v0.2.1/release.yaml
[5.2]:
  https://github.com/knative/eventing-sources/releases/download/v0.2.1/release-with-gcppubsub.yaml
[5.3]:
  https://github.com/knative/eventing-sources/releases/download/v0.2.1/message-dumper.yaml
[6]:
  https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#event-v1-core
[6.1]: https://developer.github.com/v3/activity/events/types/
[6.3]: https://github.com/knative/docs/tree/master/eventing#containersource
[6.4]: https://cloud.google.com/pubsub/

### Installing Knative packages

**Tip**: From the table above, copy and paste the URL and package filename into
the commands below.

1. To install a Knative package by specifying the package's path and filename in
   the `kubectl apply` command:

   - To install an individual package:

     ```bash
     kubectl apply --filename [INSTALL_PACKAGE]
     ```

   - To install multiple packages, append additional
     `--filename [INSTALL_PACKAGE]` flags to the `kubectl apply` command:

     ```bash
     kubectl apply --filename [INSTALL_PACKAGE] --filename [INSTALL_PACKAGE] \
       --filename [INSTALL_PACKAGE]
     ```

     where [`INSTALL_PACKAGE`] is the URL path and filename of the a Knative
     installation package:

     `https://github.com/knative/[COMPONENT]/releases/download/[VERSION]/[FILENAME].yaml`

     and `[COMPONENT]`, `[VERSION]`, and `[FILENAME]` are the Knative component,
     release version, and filename of the installable resource. Examples:

     - `https://github.com/knative/build/releases/download/v0.2.0/release.yaml`
     - `https://github.com/knative/eventing/releases/download/v0.2.1/eventing.yaml`
     - `https://github.com/knative/eventing-sources/releases/download/v0.2.1/release.yaml`
     - `https://github.com/knative/serving/releases/download/v0.2.3/serving.yaml`


    **Example install commands:**

     * To install the Knative Serving and Build bundle:

       ```bash
       kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.3/release.yaml
       ```

    * To install all three Knative components without an observibility plugin:

      ```bash
      kubectl apply --filename https://github.com/knative/build/releases/download/v0.2.0/release.yaml \
        --filename https://github.com/knative/eventing/releases/download/v0.2.1/eventing.yaml \
        --filename https://github.com/knative/serving/releases/download/v0.2.3/serving.yaml
      ```

1. Depending on what you choose to install, you view the status of your
   installation by running one or more of the following commands. It might take
   a few seconds so rerun the commands until all of the components show a
   `STATUS` of `Running`:

   ```bash
   kubectl get pods --namespace knative-build
   kubectl get pods --namespace knative-eventing
   kubectl get pods --namespace knative-sources
   kubectl get pods --namespace knative-serving
   ```

   > Tip: You can append the `--watch` flag to the `kubectl get` commands to
   > view the pod status in realtime. You use `CTRL + C` to exit watch mode.

1. If you installed a package that includes an observability plugin, run the
   following command to ensure that the `knative-monitoring` pods show a
   `STATUS` of `Running`:

   ```bash
   kubectl get pods --namespace knative-monitoring
   ```

You are now ready to deploy an app, create a build, or start sending and
receiving events in your Knative cluster.

## What's next

If you want to add monitoring, logging, and tracing support to your cluster, see
[Installing observability plugins](../serving/installing-logging-metrics-traces.md)
for details about the supported plugins.

Depending on the Knative components you installed, you can use the following
guides to help you get started with Knative:

- [Getting Started with Knative App Deployment](./getting-started-knative-app.md).

  - [Knative Serving sample apps](../serving/samples/README.md).

- [Creating a simple Knative Build](../build/creating-builds.md).

  - [Knative Build templates](https://github.com/knative/build-templates).

- [Knative Eventing overview](../eventing/README.md).

  - [Knative Eventing code samples](../eventing/samples).
