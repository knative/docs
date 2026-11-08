---
audience: developer
components:
  - eventing
  - functions
  - serving
function: explanation
---

# CLI tools

Choose a tool for your goal, then follow a task guide or use its command reference. The descriptions below explain the tools' roles; this page is not a command catalog.

## Accomplish a task

- [Install CLI tools](install-kn.md) or [install the Functions CLI/plugin](../functions/install-func.md).
- [Connect CLI tools to a cluster](connect-to-cluster.md) and verify read access before changing resources.
- Follow the [Serving Quickstart](../getting-started/first-service.md) for a guided first Service, or [choose a Functions task](../functions/README.md#accomplish-a-task) for an existing project.

## Understand the tools

Use `kubectl` when working with Kubernetes manifests, `kn` for Knative resource workflows, and `func` for function-project workflows. The tool-specific sections below describe these boundaries. For the Functions model, read [How Knative Functions fits together](../functions/about-functions.md).

## Look up details

- [`kn` command reference]({{ clientdocs() }}){target=_blank} and [`func` command reference]({{ funcdocs() }}){target=_blank} — maintained in their respective repositories; the links follow the documentation release branch when configured, otherwise `main`. Check a reference matching your installed binary when looking up flags.
- [kn configuration-file reference](configure-kn.md) — configuration locations and mappings.
- [kn plugins](kn-plugins.md) — plugin catalog and installation options.
- [Kubernetes kubectl reference](https://kubernetes.io/docs/reference/kubectl/){target=_blank} — Kubernetes-maintained command documentation.

## kubectl

You can use `kubectl` to apply the YAML files required to install Knative components, and also to create Knative resources, such as services and event sources using YAML.

See [Install and Set Up `kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/){target=_blank}.

## kn

`kn` provides a quick and easy interface for creating Knative resources such as services and event sources, without the need to create or modify YAML files directly. `kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

!!! note
    The core `kn` resource commands do not install Knative components such as Serving or Eventing. Separately installed plugins can add installation workflows: the [Knative Operator plugin](install-kn.md#install-the-knative-operator-cli-plugin) provides commands such as `kn operator install`. Follow the [Operator CLI installation guide](../install/operator/knative-with-operator-cli.md) for that administrator workflow.

### Additional resources

- See [Installing `kn`](install-kn.md).
- See the upstream [`kn` command reference]({{ clientdocs() }}){target=_blank} for subcommands and flags.

## func

The `func` CLI enables you to create, build, and deploy Knative Functions without the need to create or modify YAML files directly.

### Additional resources

- See [Installing Knative Functions](../functions/install-func.md).
- See the upstream [`func` command reference]({{ funcdocs() }}){target=_blank} for subcommands and flags.
- Choose a workflow from the [Functions task guides](../functions/README.md#accomplish-a-task).

## Connecting CLI tools to your cluster

Follow [Connect CLI tools to a cluster](connect-to-cluster.md) to select a kubeconfig/context and verify access with `kubectl` and `kn`.

A kubeconfig defines cluster connections and credentials; `kn`'s separate configuration file defines CLI preferences. `KUBECONFIG` and `--kubeconfig` concern cluster access, while `kn --config` selects the [kn preferences file](configure-kn.md). They are not interchangeable.

### Using kubeconfig files with your platform

Provider-specific links are retained in the cluster-access guide's [Using kubeconfig files with your platform](connect-to-cluster.md#using-kubeconfig-files-with-your-platform) section.
