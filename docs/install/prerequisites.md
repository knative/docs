---
title: "Prerequisites"
weight: 01
type: "docs"
showlandingtoc: "false"
---

Before installing Knative, you must meet the following prerequisites:

- You have a cluster that uses Kubernetes v1.18 or newer.
- You have installed the [`kubectl` CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- If you have only one node in your cluster, you will need at least 6 CPUs, 6 GB of memory, and 30 GB of disk storage.
- If you have multiple nodes in your cluster, for each node you will need at least 2 CPUs, 4 GB of memory, and 20 GB of disk storage.
<!--TODO: Verify these requirements-->
- Your Kubernetes cluster must have access to the internet, since Kubernetes needs to be able to fetch images.
