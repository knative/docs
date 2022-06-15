<!-- Snippet used in the following topics:
- /docs/getting-started/README.md
- /docs/install/quickstart-install.md
- /docs/getting-started/quickstart-install.md
-->
## Before you begin

!!! warning
    Knative `quickstart` environments are for experimentation use only.
    For a production ready installation, see the [YAML-based installation](/docs/install/yaml-install/)
    or the [Knative Operator installation](/docs/install/operator/knative-with-operators/).

Before you can get started with a Knative `quickstart` deployment you must install:

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start){target=_blank} (Kubernetes in Docker)
or [minikube](https://minikube.sigs.k8s.io/docs/start/){target=_blank} to enable
you to run a local Kubernetes cluster with Docker container nodes.

- The [Kubernetes CLI (`kubectl`)](https://kubernetes.io/docs/tasks/tools/install-kubectl){target=_blank} to run commands against Kubernetes clusters. You can use `kubectl` to deploy applications, inspect and manage cluster resources, and view logs.

- The Knative CLI (`kn`). For instructions, see the next section.

- You need to have a minimum of 3&nbsp;CPUs and 3&nbsp;GB of RAM available for the cluster to be created.
