---
title: "Prerequisites"
weight: 01
type: "docs"
showlandingtoc: "false"
---

Before installing Knative, you must meet the following prerequisites:

## System requirements

**For prototyping purposes**, Knative will work on most local deployments of Kubernetes.
For example, you can use a local, one-node cluster that has 2 CPU and 4GB of memory.

**For production purposes**, it is recommended that:
- If you have only one node in your cluster, you will need at least 6 CPUs, 6 GB of memory, and 30 GB of disk storage.
- If you have multiple nodes in your cluster, for each node you will need at least 2 CPUs, 4 GB of memory, and 20 GB of disk storage.
<!--TODO: Verify these requirements-->

**NOTE:** The system requirements provided are recommendations only.
The requirements for your installation may vary, depending on whether you use optional components, such as a networking layer.

## Prerequisites

Before installation, you must meet the following prerequisites:

- You have a cluster that uses Kubernetes v1.18 or newer.
- You have installed the [`kubectl` CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- Your Kubernetes cluster must have access to the internet, since Kubernetes needs to be able to fetch images. (To pull from a private registry, see [Deploying images from a private container registry](https://knative.dev/docs/serving/deploying/private-registry/))

## Next Steps: Install Knative Serving and Eventing

You can install the Serving component, Eventing component, or both on your cluster. If you're planning on installing both, **we recommend starting with Knative Serving.**

  - [Installing Knative Serving using YAML files](./install-serving-with-yaml.md)
  - [Installing Knative Eventing using YAML files](./install-eventing-with-yaml.md)
