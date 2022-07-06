## Prerequisites

The system requirements provided are recommendations only. The requirements for your installation might vary, depending on whether you use optional components.

!!! note
    Knative installation instructions assume you are running Mac or Linux with a bash shell.

### Prototyping deployments

Knative works on most local deployments of Kubernetes. For example, you can use a local, one-node cluster that has 3&nbsp;CPUs and 4&nbsp;GB of memory.

!!! tip
    You can install a local distribution of Knative for development purposes by using the [Knative Quickstart plugin](/docs/getting-started/quickstart-install/)

### Production-ready deployments

- Your cluster uses Kubernetes version 1.22 or newer and has internet access.

- You have installed the [`kubectl` CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

- System requirements:

    - If you have only one node in your cluster, you need at least 6&nbsp;CPUs, 6&nbsp;GB of memory, and 30&nbsp;GB of disk storage.

    - If you have multiple nodes in your cluster, for each node you need at least 2&nbsp;CPUs, 4&nbsp;GB of memory, and 20&nbsp;GB of disk storage.
