# Install by using the Knative Operator CLI Plugin

Knative provides a CLI Plugin to install, configure and manage Knative via the command lines. This CLI plugin facilitates
you with a parameter-driven way to configure the Knative cluster, without interacting with the complexities of the custom
resources.

--8<-- "prerequisites.md"
--8<-- "security-prereqs-binaries.md"

## Install the Knative Operator CLI Plugin

Before you install the Knative Operator CLI Plugin, first install the [Knative CLI](../../client/install-kn.md).

=== "MacOS"

    1. Download the binary `kn-operator-darwin-amd64` for your system from the [release page](https://github.com/knative-sandbox/kn-plugin-operator/releases/tag/knative-v1.7.1).

    1. Rename the binary to `kn-operator`:

        ```bash
        mv kn-operator-darwin-amd64 kn-operator
        ```

=== "Linux"

    1. Download the binary `kn-operator-linux-amd64` for your system from the [release page](https://github.com/knative-sandbox/kn-plugin-operator/releases/tag/knative-v1.7.1).

    1. Rename the binary to `kn-operator`:

        ```bash
        mv kn-operator-linux-amd64 kn-operator
        ```

Make the plugin executable by running the command:

```bash
chmod +x kn-operator
```

Create the directory for the `kn` plugin:

```bash
mkdir -p ~/.config/kn/plugins
```

Move the file to a plugin directory for `kn`:

```bash
cp kn-operator ~/.config/kn/plugins
```

## Verify the installation of the Knative Operator CLI Plugin

You can run the following command to verify the installation:

```bash
kn operator -h
```

You should see more information about how to use this CLI plugin.

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

To install Knative Operator of a specific version, e.g. 1.7.1, run:

```bash
kn operator install -v 1.7.1
```

## Installing the Knative Serving component

You can install Knative Serving of any specific version under any specific namespace. By default, the namespace is `knative-serving`,
and the version is the latest.

To install the latest version of Knative Serving, run:

```bash
kn operator install --component serving
```

To install Knative Serving under a certain namespace, e.g. knative-serving, run:

```bash
kn operator install --component serving -n knative-serving
```

To install Knative Operator of a specific version, e.g. 1.7, run:

```bash
kn operator install --component serving -n knative-serving -v "1.7"
```

To install the ingress plugin, e.g Kourier, together with the install command, run:

```bash
kn operator install --component serving -n knative-serving -v "1.7" --kourier
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
        kubectl apply --filename {{artifact(repo="net-contour",file="contour.yaml")}}
        ```

    1. To configure Knative Serving to use Contour, run the command as follows:

        ```bash
        kn operator enable ingress --contour -n knative-serving
        ```

## Installing the Knative Eventing component

You can install Knative Eventing of any specific version under any specific namespace. By default, the namespace is `knative-eventing`,
and the version is the latest.

To install the latest version of Knative Eventing, run:

```bash
kn operator install --component eventing
```

To install Knative Eventing under a certain namespace, e.g. knative-eventing, run:

```bash
kn operator install --component eventing -n knative-eventing
```

To install Knative Operator of a specific version, e.g. 1.7, run:

```bash
kn operator install --component eventing -n knative-eventing -v "1.7"
```

### Installing Knative Eventing with event sources

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
