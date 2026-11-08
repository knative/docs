---
audience: administrator
components:
  - serving
  - eventing
function: how-to
---

# Install by using the Knative Operator CLI Plugin

Knative provides the Operator CLI Plugin to install, configure and manage Knative on the command line. This plugin helps you configure the Knative cluster, without interacting with the complexities of the custom resources.

This topic describes how to install the Knative Operator and the Serving and Eventing components using a CLI. The version flag selects the Operator release or component release, not the CLI plugin's release. The plugin is independently versioned: its [v1.21.0 install implementation](https://github.com/knative-extensions/kn-plugin-operator/blob/knative-v1.21.0/pkg/command/install/install.go) accepts these version arguments and uses the `v1beta1` Operator API. The v1.24 examples below match the verified Operator bundle; they are not a claim that a `knative-v1.24.0` plugin release exists or that this CLI route has been runtime-tested.

This installation requires the following prerequisites:

- The [CLI Tools](../../client/install-kn.md) are installed.
- An existing cluster meeting the [installation capacity recommendations and component Kubernetes requirements](../requirements.md).
- Administrator permissions for the target cluster and component namespaces.

For information on other Knative installs, see the [Installation Roadmap](../README.md#installation-roadmap).

## Install the Knative Operator

You can install Knative Operator of any specific version under any specific namespace. By default, the namespace is `default`,
and the version is the latest.

To install the latest version of Knative Operator, run:

```bash
kn operator install
```

To install Knative Operator under a certain namespace, e.g. knative-operator, run:

```bash
kn operator install -n knative-operator
```

To install Knative Operator of a specific version, e.g. 1.24.0, run:

```bash
kn operator install -v 1.24.0
```

## Install the Knative Serving component

Select a Knative Serving version from the installed Operator's [supported bundle](supported-versions.md) and use the intended component namespace. By default, the namespace is `knative-serving`,
and the version is the latest.

To install the latest version of Knative Serving, run:

```bash
kn operator install --component serving
```

To install Knative Serving under a certain namespace, e.g. knative-serving, run:

```bash
kn operator install --component serving -n knative-serving
```

To install Knative Serving of a specific version, e.g. 1.24, run:

```bash
kn operator install --component serving -n knative-serving -v "1.24"
```

To install the ingress plugin, e.g Kourier, together with the install command, run:

```bash
kn operator install --component serving -n knative-serving -v "1.24" --kourier
```

If you do not specify the ingress plugin, istio is used as the default. However, you need to make sure you install
[Istio](../installing-istio.md) first.

### Install the networking layer

You can configure the network layer option via the Operator CLI Plugin. Click on each of the following tabs to see how
you can configure Knative Serving with different ingresses:

=== "Kourier (Choose this if you are not sure)"

    The following steps install Kourier and enable its Knative integration:

    1. To configure Knative Serving to use Kourier, run the command as follows:

        ```bash
        kn operator enable ingress --kourier -n knative-serving
        ```

=== "Istio (default)"

    The following steps install Istio to enable its Knative integration:

    1. [Install Istio](../installing-istio.md).

    1. To configure Knative Serving to use Istio, run the command as follows:

        ```bash
        kn operator enable ingress --istio -n knative-serving
        ```

=== "Contour"

    The following steps install Contour and enable its Knative integration:

    1. Install a properly configured Contour:

        ```bash
        kubectl apply --filename {{artifact(repo="net-contour",org="knative-extensions",file="contour.yaml")}}
        ```

    1. To configure Knative Serving to use Contour, run the command as follows:

        ```bash
        kn operator enable ingress --contour -n knative-serving
        ```

## Install the Knative Eventing component

Select a Knative Eventing version from the installed Operator's [supported bundle](supported-versions.md) and use the intended component namespace. By default, the namespace is `knative-eventing`,
and the version is the latest.

To install the latest version of Knative Eventing, run:

```bash
kn operator install --component eventing
```

To install Knative Eventing under a certain namespace, e.g. knative-eventing, run:

```bash
kn operator install --component eventing -n knative-eventing
```

To install Knative Eventing of a specific version, e.g. 1.24, run:

```bash
kn operator install --component eventing -n knative-eventing -v "1.24"
```

### Install Knative Eventing with event sources

Knative Operator can configure the Knative Eventing component with different event sources.
Click on each of the following tabs to
see how you can configure Knative Eventing with different event sources:

=== "Ceph"

    1. To install the eventing source Ceph, run the following command:

        ```bash
        kn operator enable eventing-source --ceph --namespace knative-eventing
        ```

=== "GitHub"

    1. To install the eventing source Github, run the following command:

        ```bash
        kn operator enable eventing-source --github --namespace knative-eventing
        ```

=== "GitLab"

    1. To install the eventing source Gitlab, run the following command:

        ```bash
        kn operator enable eventing-source --gitlab --namespace knative-eventing
        ```

=== "Apache Kafka"

    1. To install the eventing source Kafka, run the following command:

        ```bash
        kn operator enable eventing-source --kafka --namespace knative-eventing
        ```

=== "RabbitMQ"

    1. To install the eventing source RabbitMQ, run the following command:

        ```bash
        kn operator enable eventing-source --rabbitmq --namespace knative-eventing
        ```

=== "Redis"

    1. To install the eventing source Redis, run the following command:

        ```bash
        kn operator enable eventing-source --redis --namespace knative-eventing
        ```

## What's next

- [Configure Knative Serving using Operator](configuring-serving-cr.md)
- [Configure Knative Eventing using Operator](configuring-eventing-cr.md)
