---
audience: administrator
components:
  - serving
  - eventing
# Landing page: routes readers to learning, tasks, explanation, and reference.
---

# Installing Knative

Choose a route based on whether you want to try Knative locally or install it on a Kubernetes cluster you administer. Serving and Eventing can be installed independently. Knative Functions uses the `func` client to build and deploy containers; it is not a separate cluster component to install.

## Installation roadmap

### Try Knative locally

If you are learning Knative, start with the [Quickstart installation](../getting-started/quickstart-install.md). It sets up a local environment for the guided exercises. You do not need to choose a cluster installation method first.

### Install on an existing cluster

These routes are for Kubernetes administrators with permission to install cluster-wide resources. First check the [installation requirements](requirements.md), then choose a method:

- **Apply release manifests:** [Install Serving with YAML](yaml-install/serving/install-serving-with-yaml.md), [install Eventing with YAML](yaml-install/eventing/install-eventing-with-yaml.md), or both. You manage the installed manifests and your customizations.
- **Use a controller to manage the installation:** [Install with the Knative Operator](operator/knative-with-operators.md). You manage Operator custom resources. If you prefer the CLI workflow, use [the Operator CLI installation guide](operator/knative-with-operator-cli.md).

An installation procedure does not by itself establish production readiness. Plan configuration, security, availability, monitoring, and upgrades for your environment; see [administrator guidance](../admin/admin-overview.md).

## YAML and Knative Operator installations compared

For responsibilities, customization, and GitOps trade-offs, read [Choosing an installation method](installation-methods.md). Both methods work with an existing cluster; neither replaces Kubernetes administration.

## Extensibility

Choose ingress, messaging, and optional integrations for your environment using the [installation extensions catalog](extensions.md). Follow the implementation-specific installation guide before enabling an extension. For commercial distributions and hosted options, see [Knative offerings](knative-offerings.md).

### Networking plugins

Use the [networking plugins catalog](extensions.md#networking-plugins) to find ingress implementations and their installation guidance.

### Messaging plugins

Use the [messaging plugins catalog](extensions.md#messaging-plugins) to find transport options; implementation-specific capabilities and migration behavior require separate review.

### Integration plugins

Use the [integration plugins catalog](extensions.md#integration-plugins) to find certificate-management installation guidance.

## Installation resources

After installing:

- **Configure:** [Configure Knative using the Operator](operator/configuring-with-operator.md), or read [Working with ConfigMaps](../admin/editing-configmaps.md) for installations not managed by the Operator.
- **Secure:** [Security guidance and disclosure](../reference/security/README.md).
- **Maintain:** [Check the installed version](upgrade/check-install-version.md) and [upgrade Knative](upgrade/README.md).
- **Recover or remove:** [Troubleshoot installation](troubleshooting.md) or [uninstall Knative](uninstall.md).
