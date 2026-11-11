---
audience: developer
components:
  - serving
  - eventing
function: how-to
---

# Connect CLI tools to a cluster

Select a Kubernetes context and verify that `kubectl` and `kn` can read Knative Services in the intended namespace. This guide does not install Knative or provision cluster credentials.

## Prerequisites

- `kubectl` and [`kn`](install-kn.md) are installed.
- You have a kubeconfig file and any credential helper required by your cluster provider.
- Knative Serving is installed on the target cluster.
- Your account can list Knative Services in the target namespace.

Do not run resource-changing commands until you have confirmed the cluster and namespace. A context selects both cluster connection details and credentials.

## Select the connection

1. By default, the tools use `$HOME/.kube/config`. If your kubeconfig is elsewhere, set its path for this shell:

    ```bash
    export KUBECONFIG=/path/to/kubeconfig
    ```

    Replace the example path with your file. Obtain credentials from your cluster administrator or provider if you do not have a kubeconfig; see [provider guidance](#using-kubeconfig-files-with-your-platform).

2. List the available contexts:

    ```bash
    kubectl config get-contexts
    ```

    Find the context for the intended cluster. The `CURRENT` marker identifies the default context, but the next steps select a context explicitly rather than changing that default.

3. Set the context and namespace for the checks:

    ```bash
    CONTEXT=my-cluster-context
    NAMESPACE=default
    ```

    Replace both example values with the context name and namespace you intend to use.

## Verify access

Read Services with both tools using the same context and namespace:

```bash
kubectl --context "$CONTEXT" get services.serving.knative.dev -n "$NAMESPACE"
kn service list --context "$CONTEXT" --namespace "$NAMESPACE"
```

Both commands should list the same Knative Services. An empty list or `No resources found` is a valid result if the namespace has no Services. Successful reads verify the connection and list permission, not permission to create or update resources.

If the checks fail:

- A context-not-found error means the selected name is not in the loaded kubeconfig. Check `KUBECONFIG` and the context list.
- Authentication or credential-helper errors require renewing credentials or installing the provider's helper.
- A `Forbidden` response means you reached the API server but do not have the required permission. Ask the cluster administrator for access to the intended namespace.
- A missing Knative Service resource type can mean Serving is not installed on this cluster. Confirm the context before asking the administrator to check the installation.
- A connection or timeout error requires checking the API-server address and network access with your cluster administrator.

Continue using the explicit context and namespace on subsequent commands if you do not want to rely on defaults. For supported command flags, consult the [`kn` command reference]({{ clientdocs() }}){target=_blank}.

## Kubeconfig versus kn configuration

A kubeconfig supplies cluster connection details and credentials. The separate `kn` configuration file supplies CLI preferences such as plugin and sink mappings. `kn --config` selects that preferences file; it is not a substitute for `--kubeconfig` or `KUBECONFIG`.

See [Customizing kn](configure-kn.md) for the configuration-file reference, and [Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/){target=_blank} for Kubernetes' kubeconfig rules.

## Using kubeconfig files with your platform

Provider-specific instructions for obtaining or updating kubeconfig:

- [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html){target=_blank}
- [Google GKE](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl){target=_blank}
- [IBM IKS](https://cloud.ibm.com/docs/containers?topic=containers-getting-started){target=_blank}
- [Red Hat OpenShift Cloud Platform](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/administrator-cli-commands.html#create-kubeconfig){target=_blank}
- [minikube](https://minikube.sigs.k8s.io/docs/start/){target=_blank} — starting minikube writes a kubeconfig or adds a context to an existing file.
