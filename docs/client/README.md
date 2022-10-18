# CLI tools

The following CLI tools are supported for use with Knative.

## kubectl

You can use `kubectl` to apply the YAML files required to install Knative components, and also to create Knative resources, such as services and event sources using YAML.

See [Install and Set Up `kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/){target=_blank}.

## kn

`kn` provides a quick and easy interface for creating Knative resources such as services and event sources, without the need to create or modify YAML files directly. `kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

!!! note
    `kn` cannot be used to install Knative components such as Serving or Eventing.

### Additional resources

- See [Installing `kn`](install-kn.md).
- See the [`kn` documentation]({{ clientdocs() }}){target=_blank} in Github.

## func

The `func` CLI enables you to create, build, and deploy Knative Functions without the need to create or modify YAML files directly.

### Additional resources

- See [Installing Knative Functions](../functions/install-func.md).
- See the [`func` documentation]({{ funcdocs() }}){target=_blank} in Github.

## Connecting CLI tools to your cluster

After you have installed `kubectl` or `kn`, these tools will search for the `kubeconfig` file of your cluster in the default location of `$HOME/.kube/config`, and will use this file to connect to the cluster. A `kubeconfig` file is usually automatically created when you create a Kubernetes cluster.

You can also set the environment variable `$KUBECONFIG`, and point it to the kubeconfig file.

Using the `kn` CLI, you can specify the following options to connect to the cluster:

- `--kubeconfig`: use this option to point to the `kubeconfig` file. This is equivalent to setting the `$KUBECONFIG` environment variable.
- `--context`: use this option to specify the name of a context from the existing `kubeconfig` file. Use one of the contexts from the output of `kubectl config get-contexts`.


You can also specify a config file in the following ways:

- Setting the environment variable `$KUBECONFIG`, and point it to the kubeconfig file.

- Using the `kn` CLI `--config` option, for example, `kn service list --config path/to/config.yaml`. The default config is at `~/.config/kn/config.yaml`.

For more information about `kubeconfig` files, see
[Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/){target=_blank}.

### Using kubeconfig files with your platform

Instructions for using `kubeconfig` files are available for the following platforms:

- [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html){target=_blank}
- [Google GKE](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl){target=_blank}
- [IBM IKS](https://cloud.ibm.com/docs/containers?topic=containers-getting-started){target=_blank}
- [Red Hat OpenShift Cloud Platform](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/administrator-cli-commands.html#create-kubeconfig){target=_blank}
- Starting [minikube](https://minikube.sigs.k8s.io/docs/start/){target=_blank} writes this file
automatically, or provides an appropriate context in an existing configuration file.
