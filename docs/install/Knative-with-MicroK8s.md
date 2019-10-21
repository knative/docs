---
title: "Install on MicroK8s"
linkTitle: "MicroK8s"
weight: 10
type: "docs"
---

[MicroK8s](https://microk8s.io) is a lightweight, powerful fully-conformant Kubernetes that tracks upstream releases and makes clustering trivial. It can run on any flavor of Linux that supports [Snap](https://snapcraft.io) packages. It can run on Windows and Mac OS using [Multipass](https://multipass.run).
This guide walks you through the installation of Knative using MicroK8s.

If you need help or support please reach out on the [Kubernetes forum](https://discuss.kubernetes.io/tags/microk8s) or Kubernetes.slack.com channel #microk8s. 
Additionally if you wish to contribute or report an issue please visit [MicroK8s Github](https://github.com/ubuntu/microk8s).

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
This command will install Knative Serving version 0.7.1 and Eventing version 0.7.1 components.

NOTE: As of this writing, MicroK8s comes with version 0.7.1, this doc will be updated to reflect versioning changes. 

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

To delete MicroK8s along with Knative, Istio, and any deployed apps run:

```shell
sudo snap remove microk8s
```
