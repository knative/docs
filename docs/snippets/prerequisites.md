## Prerequisites

Before installing Knative, you must meet the following prerequisites:

- **For prototyping purposes**, Knative works on most local deployments of Kubernetes. For example, you can use a local, one-node cluster that has 3&nbsp;CPUs and 4&nbsp;GB of memory.

    !!! tip
        You can install a local distribution of Knative for development purposes
        using the [Knative Quickstart plugin](/docs/getting-started/quickstart-install/)

- **For production purposes**, it is recommended that:

    - If you have only one node in your cluster, you need at least 6&nbsp;CPUs, 6&nbsp;GB of memory, and 30&nbsp;GB of disk storage.
    - If you have multiple nodes in your cluster, for each node you need at least 2&nbsp;CPUs, 4&nbsp;GB of memory, and 20&nbsp;GB of disk storage.
- You have a cluster that uses Kubernetes v1.24 or newer.
- You have installed the [`kubectl` CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- Your Kubernetes cluster must have access to the internet, because Kubernetes needs to be able to fetch images. To pull from a private registry, see [Deploying images from a private container registry](/docs/serving/deploying-from-private-registry/).

!!! caution
    The system requirements provided are recommendations only. The requirements for your installation might vary, depending on whether you use optional components, such as a networking layer.
