# Easy Install on Minikube

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.10 or newer. If you don't have one,
you can create one using [Minikube](https://github.com/kubernetes/minikube).

### Install kubectl and Minikube

1. [Install the kubectl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl).

1. [Install and configure minikube](https://github.com/kubernetes/minikube#installation)
    with a [VM driver](https://github.com/kubernetes/minikube#requirements), e.g.
    `kvm2` on Linux or `hyperkit` on macOS.

## Creating a Kubernetes cluster

Once kubectl and  Minikube are installed, create a cluster with version 1.10 or
greater and your chosen VM driver:

For Linux use:

```shell
minikube start --memory=8192 --cpus=4 \
  --kubernetes-version=v1.10.4 \
  --vm-driver=kvm2 \
  --bootstrapper=kubeadm \
  --extra-config=controller-manager.cluster-signing-cert-file="/var/lib/localkube/certs/ca.crt" \
  --extra-config=controller-manager.cluster-signing-key-file="/var/lib/localkube/certs/ca.key" \
  --extra-config=apiserver.admission-control="DenyEscalatingExec,LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
```

For macOS use:

```shell
minikube start --memory=8192 --cpus=4 \
  --kubernetes-version=v1.10.4 \
  --vm-driver=hyperkit \
  --bootstrapper=kubeadm \
  --extra-config=controller-manager.cluster-signing-cert-file="/var/lib/localkube/certs/ca.crt" \
  --extra-config=controller-manager.cluster-signing-key-file="/var/lib/localkube/certs/ca.key" \
  --extra-config=apiserver.admission-control="DenyEscalatingExec,LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
```

## Installing Istio

Knative depends on Istio. Run the following to install Istio. (We are changing
`LoadBalancer` to `NodePort` for the `istio-ingress` service).

```shell
wget -O - https://storage.googleapis.com/knative-releases/latest/istio.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply -f -

# Label the default namespace with istio-injection=enabled.
kubectl label namespace default istio-injection=enabled
```

Wait until each Istio component is running or completed (STATUS column shows
'Running' or 'Completed'):

```shell
kubectl get pods -n istio-system --watch
```

CTRL+C when it's done.

## Installing Knative Serving

Next, we will install [Knative Serving](https://github.com/knative/serving):

We are using the `https://storage.googleapis.com/knative-releases/latest/release-lite.yaml`
file which omits some of the monitoring components to reduce the memory used by
the Knative components since you do have limited resources available. To use the
provided `release-lite.yaml` release run:

```shell
kubectl apply -f https://storage.googleapis.com/knative-releases/latest/release-lite.yaml
```

Wait until all Knative components are running (STATUS column shows 'Running'):

```shell
kubectl get pods -n knative-serving --watch
```

CTRL+C when it's done.

Now you can deploy your app/function to your newly created Knative cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

## Cleaning up

Delete the Kubernetes cluster along with Knative, Istio and Primer sample app:

```shell
minikube delete
```
