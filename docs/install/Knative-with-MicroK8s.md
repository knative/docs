---
title: "Install on MicroK8s"
linkTitle: "MicroK8s"
weight: 10
type: "docs"
---

This guide walks you through the installation of Knative using [MicroK8s](https://microk8s.io).

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

This command will install all available Knative components.

You can check the status of Knative pods using the following commands:

```shell
   kubectl get pods -n knative-serving
```

```shell
   kubectl get pods -n knative-build
```

```shell
   kubectl get pods -n knative-eventing
```

```shell
   kubectl get pods -n knative-monitoring
```

## Cleaning up

Delete MicroK8s along with Knative, Istio, and any deployed apps:

```shell
sudo snap remove microk8s
```
