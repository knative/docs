---
audience: administrator
components:
  - serving
  - eventing
function: explanation
---

# Choosing an installation method

YAML-based installation and the Knative Operator both install Serving and Eventing on an existing Kubernetes cluster. The important difference is where you express customizations and who applies them over the installation lifecycle.

If you want a local learning environment instead, use the [Quickstart](../getting-started/quickstart-install.md). For capacity recommendations and compatibility sources, see [installation requirements](requirements.md).

## Applying release manifests

A YAML-based installation gives you direct access to resource definitions. You apply the release manifests and manage any changes to them. This offers granular control, but also leaves you responsible for tracking those changes and reconciling them with new release manifests during upgrades.

This approach can fit a GitOps workflow in which manifests are checked into a Git repository and applied by tools such as [Flux](https://fluxcd.io) or [Argo CD](https://argo-cd.readthedocs.io/en/stable/).

## Using the Knative Operator

The Operator is a controller that extends the Kubernetes API with `KnativeServing` and `KnativeEventing` custom resources. You express installation choices and customizations in those resources; the Operator applies and reconciles the managed resources.

This separates the base installation from your customizations. It also changes where you make changes: manually editing an Operator-managed ConfigMap is not persistent because reconciliation overwrites it. Use the custom resource instead. Not every setting is exposed as a dedicated Operator field; ConfigMap values can be supplied through `spec.config`.

The Operator is also compatible with GitOps: keep the Operator installation and its custom resources under your chosen declarative workflow. Installing the Operator through manifests, Helm, or the CLI does not remove the need to manage its lifecycle.

## Comparing responsibilities

| Consideration | YAML-based installation | Operator installation |
| --- | --- | --- |
| Configuration source | Release manifests plus the changes you manage | Operator custom resources plus the Operator installation |
| Customization | Edit resource definitions directly | Express supported choices and overrides in the custom resource |
| Upgrades | Track and reapply customizations against new manifests | Update the component version in the custom resource within supported upgrade limits |
| Audit and version control | Store manifests and changes in your repository | Store the Operator installation and custom resources in your repository |

Neither route selects your operational policy for ingress, messaging, security, or availability. Those choices still depend on the cluster and workloads.

## Changing methods

The installation method is not a permanent choice for every cluster. However, [administrator guidance](../admin/admin-overview.md#installation-decisions) identifies new installations on separate clusters as the better-tested and officially supported approach, rather than switching methods on an existing cluster.

## Next steps

- [Install using YAML](yaml-install/README.md).
- [Install using the Operator](operator/knative-with-operators.md).
- [Review the upgrade procedures](upgrade/README.md) before planning lifecycle changes.
