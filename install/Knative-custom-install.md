# Performing a Custom Knative Installation

Use this guide to perform custom installations of Knative on your existing
Kubernetes clusters. Knative's pluggable components allow you to
install only what you want in each of your clusters.

The steps covered in the guide are for advanced operators who want to
customize each Knative installation. Installing individual Knative components
requires that you to run multiple and separate installation commands.

## Before you begin

* If you are new to Knative, you should instead [install one of the default
  installation packages](./README.md). Follow the host specific Knative installation
  instructions for the default package to help you get up and running with the
  least effort. Installing a default package also ensures that you can run all the
  [Knative Serving Samples](https://github.com/knative/docs/blob/master/serving/samples/README.md).

* The following steps use `bash` for a MacOS or Linux environment; for Windows,
  some commands might need adjustment.

* This installation guide assumes that you have an existing Kubernetes cluster,
  on which you're comfortable installing and running _alpha_ level software.

* Kubernetes requirements:

  * Knative requires that the version of your Kubernetes cluster is v1.10 or newer.

  * Your Kubernetes cluster must also have the
    [MutatingAdmissionWebhook admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#how-do-i-turn-on-an-admission-controller)
    enabled.

  * The version of your
    [`kubectl` CLI tool](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    must be v1.10 or newer.

## Installing Istio

Knative depends on [Istio](https://istio.io/docs/concepts/what-is-istio/) for
the service mesh. You can choose the default package to install the Istio service mesh with
[automatic sidecar injection](https://istio.io/docs/setup/kubernetes/sidecar-injection).
You should install the default package if you are just getting started with Knative.

Alternatively, you can choose to install Istio with manual sidecar injection or with support for
[Custom Resource Definitions (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).

### Choosing an Istio installation package

You can choose from the following installation packages to install the Istio
service mesh on you cluster:

| Istio Package Filename | Description       |
| ---------------------- | ----------------- |
| [`istio.yaml`][a]             | Default: Configured for Automatic Sidecar Injection. |
| [`istio-crds.yaml`][b]        | Support for Custom Resource Definitions. **Q: This have to do with "Pilot"? Why choose this?** |
| [`istio-lean.yaml`][c]        | Configured for Manual Sidecar Injection. **Q: When or why should users choose this?** |

[a]: https://github.com/knative/serving/releases/download/v0.2.2/istio.yaml
[b]: https://github.com/knative/serving/releases/download/v0.2.2/istio-crds.yaml
[c]: https://github.com/knative/serving/releases/download/v0.2.2/istio-lean.yaml

### Installing Istio installation packages

1. Install an Istio package with the `kubectl apply` command by specifying the
   package filename:
    ```bash
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.2/[FILENAME].yaml
    ```

    where `[FILENAME]` is the name of the Istio package that you want to install. Example:
    `https://github.com/knative/serving/releases/download/v0.2.2/istio.yaml
    `
1. Label the default namespace with `istio-injection=enabled`: **Q: For which install package is this needed? Or is this needed for all Istio installs?**
    ```bash
    kubectl label namespace default istio-injection=enabled
    ```
1. View the status of your Istio installation. It might take a few
   seconds so rerun the following command until all of the pods show a
   `STATUS` of `Running` or `Completed`:
    ```bash
    kubectl get pods --namespace istio-system
    ```

    > Tip: You can append the `--watch` flag to the `kubectl get` commands to
      view the pod status in realtime. You use `CTRL + C` to exit watch mode.

## Installing Knative components

You can install each Knative component independently or use the default packages
to install multiple components. The individual component packages exclude
an observability plugin but you have the option to install one later.

### Choosing Knative installation packages

The following Knative installation packages are available.

This installation method is suggested for experienced operators. If you are new to
Knative, you should [install the default package](./README.md) to help you get up
and running with the least effort.

| Knative Package Filename | Serving Component | Build Component | Eventing Component | Observability Plugin* |
| ------------------------ | ----------------- | --------------- | ------------------ | ----------------- |
| Default: [`release.yaml`][1] ([knative/serving repo][1.1]) | Included | Included | -     | [ELK stack][2] |
| [`release-no-mon.yaml`][3] | Included        | Included        | -                  | -                 |
| [`release-lite.yaml`][4] | Included          | Included        | -                  | Includes support for a [`fluentd` based observability plugin][5] that you provide. |
| [`build.yaml`][6] ([knative/serving repo][1.1]) <br/> Or [`release.yaml`][6.1] ([knative/build repo][6.2]) | -               | Included        | -                  | -                 |
| [`eventing.yaml`][7]     | -                 | -               | Included           | -                 |
| [`release.yaml`][8] ([knative/eventing-sources repo][8.1]) | - | - | Included       | -                 |
| [`serving.yaml`][9]      | Included          | -               | -           | -                 |

_*_ See [Installing observability plugins](../serving/installing-logging-metrics-traces.md)
for details about the supported plugins and how to add monitoring, logging, and
tracing to your cluster.

[1]: https://github.com/knative/serving/releases/download/v0.2.2/release.yaml
[1.1]: https://github.com/knative/serving/releases/tag/v0.2.2
[2]: https://www.elastic.co/elk-stack
[3]: https://github.com/knative/serving/releases/download/v0.2.2/release-no-mon.yaml
[4]: https://github.com/knative/serving/releases/download/v0.2.2/release-lite.yaml
[5]: ../serving/setting-up-a-logging-plugin.md
[6]: https://github.com/knative/serving/releases/download/v0.2.2/build.yaml
[6.1]: https://github.com/knative/build/releases/download/v0.2.0/release.yaml
[6.2]: https://github.com/knative/build/releases/tag/v0.2.0
[7]: https://github.com/knative/eventing/releases/download/v0.2.0/eventing.yaml
[7.1]: https://github.com/knative/eventing/releases/tag/v0.2.0
[8]: https://github.com/knative/eventing-sources/releases/download/v0.2.0/release.yaml
[8.1]: https://github.com/knative/eventing-sources/releases/tag/v0.2.0
[9]: https://github.com/knative/serving/releases/download/v0.2.2/serving.yaml

Note: Each of the installable Knative resources are also listed in the Assets
section of each Knative component's release page:
* [Serving v0.2.2][1.1]
* [Build v0.2.0][6.2]
* [Eventing v0.2.0][7.1]

### Installing Knative packages

**Tip**: From the table above, you can copy and paste the URL and filename of
the installation package that you want to install.

1. To install a Knative package, run the `kubectl apply` command
   and specify the package path and filename:

   * To install an individual package:
      ```bash
      kubectl apply --filename [INSTALL_PACKAGE]
      ```

   * To install multiple packages, you can append additional `--filename [INSTALL_PACKAGE]`
     flags to the `kubectl apply` command:
      ```bash
      kubectl apply --filename [INSTALL_PACKAGE] --filename [INSTALL_PACKAGE] \
        --filename [INSTALL_PACKAGE]
      ```

    Where [`INSTALL_PACKAGE`] is the URL path and filename of the a Knative installation package:

    `https://github.com/knative/[COMPONENT]/releases/download/[VERSION]/[FILENAME].yaml`

    And `[COMPONENT]`, `[VERSION]`, and `[FILENAME]` are the Knative component, release version, and filename of the installable resource. For example:
    * `https://github.com/knative/build/releases/download/v0.2.0/release.yaml`
    * `https://github.com/knative/eventing/releases/download/v0.2.0/eventing.yaml`
    * `https://github.com/knative/eventing-sources/releases/download/v0.2.0/release.yaml`
    * `https://github.com/knative/serving/releases/download/v0.2.2/serving.yaml`


    **Example install commands:**

     * To install the default package that includes both Knative Serving and Build:

       ```bash
       kubectl apply -f https://github.com/knative/serving/releases/download/v0.2.2/release.yaml
       ```

    * To install all three Knative components without an observibility plugin:

      ```bash
      kubectl apply -f https://github.com/knative/serving/releases/download/v0.2.2/serving.yaml \
        -f https://github.com/knative/build/releases/download/v0.2.0/release.yaml \
        -f https://github.com/knative/eventing/releases/download/v0.2.0/eventing.yaml
      ```

1. Depending on what you choose to install, you view the status of your
   installation by running one or more of the following commands. It
   might take a few seconds so rerun the commands until all of the components
   show a `STATUS` of `Running`:

    ```bash
    kubectl get pods --namespace knative-build
    kubectl get pods --namespace knative-eventing
    kubectl get pods --namespace knative-eventing-sources
    kubectl get pods --namespace knative-serving
    ```

    > Tip: You can append the `--watch` flag to the `kubectl get` commands to
      view the pod status in realtime. You use `CTRL + C` to exit watch mode.

1. If you installed an observability plugin, run the following command to ensure
   that the `knative-monitoring` pods show a `STATUS` of `Running`:

    ```bash
    kubectl get pods --namespace knative-monitoring
    ```

You are now ready to deploy an app, create a build, or start sending and receiving
events in your Knative cluster.

## What's next

Depending on the Knative components you installed, the following guides can help
you get started with Knative:

* [Getting Started with Knative App Deployment](./getting-started-knative-app.md).

  * [Knative Serving sample apps](../serving/samples/README.md).

* [Creating a simple Knative Build](../build/creating-builds.md).

  * [Knative Build templates](https://github.com/knative/build-templates).

* [Knative Eventing overview](../eventing/README.md).

  * [Knative Eventing code samples](../eventing/samples).
