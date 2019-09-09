---
title: "Install on MicroK8s"
linkTitle: "MicroK8s"
weight: 10
type: "docs"
---

[MicroK8s](https://microk8s.io) is a lightweight, powerful fully-conformant Kubernetes that tracks upstream releases and makes clustering trivial. It can run on any flavor of Linux that supports [Snap](https://snapcraft.io) packages. It can run on Windows and Mac OS using [Mutlipass](https://multipass.run).
This guide walks you through the installation of Knative using MicroK8s.

You can find [guides for other platforms here](./README.md).

### Install MicroK8s

```shell
   sudo snap install --classic microk8s
```

## Alias MicroK8s kubectl for convenience

```shell
   sudo snap alias microk8s.kubectl kubectl
```

## Enable Knative

```shell
   echo 'N;' | microk8s.enable knative
```

This command will install all available Knative v0.7.1 components.

You can check the status of Knative pods using the following commands:

```shell
   kubectl get pods -n knative-serving
```

```shell
   kubectl get pods -n knative-eventing
```

```shell
   kubectl get pods -n knative-monitoring
```

## Cleaning up

Knative can be removed from MicroK8s using the following command:

```shell
sudo microk8s.disable knative
```
