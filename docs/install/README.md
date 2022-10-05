# Installing Knative

You can install the Serving component, Eventing component, or both on your
cluster by using one of the following deployment options:

- Use the [Knative Quickstart plugin](quickstart-install.md) to install a
preconfigured, local distribution of Knative for development purposes.

- Use a YAML-based installation to install a production ready deployment:
    - [Install Knative Serving by using YAML](yaml-install/serving/install-serving-with-yaml.md)
    - [Install Knative Eventing by using YAML](yaml-install/eventing/install-eventing-with-yaml.md)

- Use the [Knative Operator](operator/knative-with-operators.md) to install and
configure a production-ready deployment.

- Follow the documentation for vendor-managed [Knative offerings](knative-offerings.md).

You can also [upgrade an existing Knative installation](upgrade/README.md).

!!! note
    Knative installation instructions assume you are running Mac or Linux with a Bash shell.
<!-- TODO: Link to provisioning guide for advanced installation -->
