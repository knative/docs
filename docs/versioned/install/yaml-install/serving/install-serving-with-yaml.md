---
audience: administrator
components:
  - serving
function: how-to
---

# Installing Knative Serving using YAML files

This topic describes how to install Knative Serving by applying YAML files. This installation requires the following prerequisites:

- The [CLI Tools](../../../client/install-kn.md) are installed.
- Sufficient hardware:

  One node requires at least 6 CPUs, 6 GB of memory, and 30 GB of disk storage.

  Multiple nodes require 2 CPUs, 4 GB of memory, and 20 GB of disk storage.

- The existing Kubernetes is running a supported version.

For information on other Knative installs, see the [Installation Roadmap](../../README.md#installation-roadmap).

## Install Serving { #install-the-knative-serving-component }

To install the Knative Serving component:

1. Install the required custom resources by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-crds.yaml")}}
    ```

1. Install the core components of Knative Serving by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-core.yaml")}}
    ```

    !!! info
        See [Installation files](#knative-serving-installation-files) below for a reference table of all Knative Serving YAML files.

## Install a networking layer

Expand the following tabs for instructions on installing network layers. For an overview of network layer options, architecture, and configurations see the [ingress providers](../../../serving/config-network-adapters.md#ingress-providers) on the [Configure Knative Networking](../../../serving/config-network-adapters.md) page.

=== "Kourier"
{% filter indent(width=4) %}
{% include "netadapter-kourier.md" %}
{% endfilter %}
=== "Contour"
{% filter indent(width=4) %}
{% include "netadapter-contour.md" %}
{% endfilter %}
=== "Istio"
{% filter indent(width=4) %}
{% include "netadapter-istio.md" %}
{% endfilter %}
=== "Gateway API"
{% filter indent(width=4) %}
{% include "netadapter-gatewayapi.md" %}
{% endfilter %}

## Verify the installation

!!! success
    Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`.
    You can do this by running the following command and inspecting the output:

    ```bash
    kubectl get pods -n knative-serving
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                                      READY   STATUS    RESTARTS   AGE
    3scale-kourier-control-54cc54cc58-mmdgq   1/1     Running   0          81s
    activator-67656dcbbb-8mftq                1/1     Running   0          97s
    autoscaler-df6856b64-5h4lc                1/1     Running   0          97s
    controller-788796f49d-4x6pm               1/1     Running   0          97s
    webhook-859796bc7-8n5g2                   1/1     Running   0          96s
    ```

## Configure DNS
<!-- These are snippets from the docs/snippets directory -->
You can configure DNS to avoid specifying the host header in curl commands, or to access the content with a web browser.

The following tabs show instructions for configuring DNS. Follow the procedure for the DNS of your choice.

=== "Magic DNS (sslip.io)"
{% filter indent(width=4) %}
{% include "dns.md" %}
{% endfilter %}
=== "Real DNS"
{% filter indent(width=4) %}
{% include "real-dns-yaml.md" %}
{% endfilter %}
=== "No DNS"
{% filter indent(width=4) %}
{% include "no-dns.md" %}
{% endfilter %}

## Install optional Serving extensions

The following tabs expand to show instructions for installing each Serving extension.

=== "HPA autoscaling"

    Knative also supports the use of the Kubernetes Horizontal Pod Autoscaler (HPA)
    for driving autoscaling decisions.

    * Install the components needed to support HPA-class autoscaling by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="serving",file="serving-hpa.yaml")}}
        ```

    <!-- TODO(https://github.com/knative/docs/issues/2152): Link to a more in-depth guide on HPA-class autoscaling -->

=== "Knative encryption with cert-manager"

    Knative supports encryption features through  [cert-manager](https://cert-manager.io/docs/).
    Follow the documentation in [Serving encryption](../../../serving/encryption/encryption-overview.md)
    for more information.

## Installation files { #knative-serving-installation-files }

The following table describes the core and optional YAML installation files for Knative Serving:

| File name | Description | Dependencies |
| --- | --- | --- |
| [serving-core.yaml]({{ artifact(repo="serving",file="serving-core.yaml")}}) | Required: Knative Serving core components. | [serving-crds.yaml]({{ artifact(repo="serving",file="serving-crds.yaml")}}) |
| [serving-crds.yaml]({{ artifact(repo="serving",file="serving-crds.yaml")}}) | Required: Knative Serving core CRDs. | none |
| [serving-default-domain.yaml]({{ artifact(repo="serving",file="serving-default-domain.yaml")}}) | Configures Knative Serving to use [http://sslip.io](http://sslip.io) as the default DNS suffix. | [serving-core.yaml]({{ artifact(repo="serving",file="serving-core.yaml")}}) |
| [serving-hpa.yaml]({{ artifact(repo="serving",file="serving-hpa.yaml")}}) | Components to autoscale Knative revisions through the Kubernetes Horizontal Pod Autoscaler. | [serving-core.yaml]({{ artifact(repo="serving",file="serving-core.yaml")}}) |
| [serving-post-install-jobs.yaml]({{ artifact(repo="serving",file="serving-post-install-jobs.yaml")}}) | Additional jobs after installing `serving-core.yaml`. Currently it is the same as `serving-storage-version-migration.yaml`. | [serving-core.yaml]({{ artifact(repo="serving",file="serving-core.yaml")}}) |
| [serving-storage-version-migration.yaml]({{ artifact(repo="serving",file="serving-storage-version-migration.yaml")}}) | Migrates the storage version of Knative resources, including Service, Route, Revision, and Configuration, from `v1alpha1` and `v1beta1` to `v1`. Required by upgrade from version 0.18 to 0.19. | [serving-core.yaml]({{ artifact(repo="serving",file="serving-core.yaml")}}) |
