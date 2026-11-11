---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Installation requirements

These recommendations describe the starting environments for the installation routes. Actual requirements vary with the installed components, extensions, and workload.

## Environment and capacity

| Route | Kubernetes deployment | Recommended starting hardware |
| --- | --- | --- |
| [Quickstart](../getting-started/quickstart-install.md) | Local `kind` or Minikube cluster | 3 CPUs, 3 GB RAM |
| [YAML-based installation](yaml-install/README.md) | Existing cluster | One node: 6 CPUs, 6 GB memory, 30 GB disk. Multiple nodes: 2 CPUs, 4 GB memory, 20 GB disk per node. |
| [Operator installation](operator/knative-with-operators.md) | Existing cluster | Same recommendation as YAML-based installation |

The documented installation routes support Linux, macOS, and Windows. Check the selected guide for its tool-specific prerequisites.

## Administrator prerequisites

For an existing-cluster installation, you need:

- Familiarity with Kubernetes administration and the `kubectl` CLI.
- `cluster-admin` permissions or equivalent permissions to install software and manage the required cluster-scoped and namespaced resources. See [Kubernetes RBAC authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/).
- A supported Kubernetes version for the Knative release you are installing.
- The prerequisites for your selected networking or messaging implementation. See the [extensions catalog](extensions.md) and the component installation guide.

## Kubernetes minimum for Knative v1.24

Serving v1.24.0 and Eventing v1.24.0 both declare a default minimum Kubernetes server version of **v1.35.0**. This was checked independently in the tagged [Serving version check](https://github.com/knative/serving/blob/knative-v1.24.0/vendor/knative.dev/pkg/version/version.go) and [Eventing version check](https://github.com/knative/eventing/blob/knative-v1.24.0/vendor/knative.dev/pkg/version/version.go), not inferred from Quickstart's client-tool requirement.

Their shared startup version check compares the API server version with that minimum. `KUBERNETES_MIN_VERSION` can override the check, and the [Operator v1.24 transform](https://github.com/knative/operator/blob/knative-v1.24.0/pkg/reconciler/common/kubernetes_min_version.go) propagates an Operator override to managed workloads. Bypassing the default gate does not establish that an older Kubernetes version is supported or validated.

The server minimum is separate from the installed `kubectl` version and its Kubernetes version-skew requirements. Check each component release and extension you deploy; a bundled older Knative release does not inherit v1.24's minimum automatically.

## Release compatibility

Use release-specific compatibility information, not the capacity table, to select versions:

- [Serving releases](https://github.com/knative/serving/releases) and [Eventing releases](https://github.com/knative/eventing/releases) provide release information for the components.
- [Operator-supported component versions](operator/supported-versions.md) lists the versions bundled with the documented Operator release. The Operator's bundled versions constrain what it can install.
- [Check the installed version](upgrade/check-install-version.md) before choosing an upgrade path.

This page records the v1.24 component minimum, not a complete Kubernetes-to-Knative compatibility matrix. Consult the selected release's requirements before installing or upgrading; a cluster that satisfies the hardware recommendations is not necessarily version-compatible.
