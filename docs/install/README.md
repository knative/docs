# Installing Knative

!!! tip
    You can install a local distribution of Knative for development purposes
    using the [Knative `quickstart` plugin](../getting-started/quickstart-install.md).

You can install the Serving component, Eventing component, or both on your cluster by using one of the following deployment options:

- Use a YAML-based installation:
    - [Install Knative Serving by using YAML](yaml-install/serving/install-serving-with-yaml.md)
    - [Install Knative Eventing by using YAML](yaml-install/eventing/install-eventing-with-yaml.md)
- Use the [Knative Operator](operator/knative-with-operators.md) to install and
configure Knative.
- Follow the documentation for vendor managed [Knative offerings](knative-offerings.md).

You can also [upgrade an existing Knative installation](upgrade/README.md).

!!! note
    Knative installation instructions assume you are running Mac or Linux with a bash shell.
<!-- TODO: Link to provisioning guide for advanced installation -->
