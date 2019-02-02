---
title: "Install on Minikube"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 10
---

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](../).

## Before you begin

Knative requires a Kubernetes cluster v1.11 or newer. If you don't have one, you
can create one using [Minikube](https://github.com/kubernetes/minikube).

### Install kubectl and Minikube

1. If you already have `kubectl` CLI, run `kubectl version` to check the
   version. You need v1.10 or newer. If your `kubectl` is older, follow the next
   step to install a newer version.

1. [Install the kubectl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl).

1. [Install and configure minikube](https://github.com/kubernetes/minikube#installation)
   version v0.28.1 or later with a
   [VM driver](https://github.com/kubernetes/minikube#requirements), e.g. `kvm2`
   on Linux or `hyperkit` on macOS.

## Creating a Kubernetes cluster

After kubectl and Minikube are installed, create a cluster with version 1.11 or
greater and your chosen VM driver:

For Linux use:

```shell
minikube start --memory=8192 --cpus=4 \
  --kubernetes-version=v1.11.5 \
  --vm-driver=kvm2 \
  --disk-size=30g \
  --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
```

For macOS use:

```shell
minikube start --memory=8192 --cpus=4 \
  --kubernetes-version=v1.11.5 \
  --vm-driver=hyperkit \
  --disk-size=30g \
  --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
```

## Installing Istio

Knative depends on Istio. Run the following to install Istio. (We are changing
`LoadBalancer` to `NodePort` for the `istio-ingress` service).

```shell
curl -L https://github.com/knative/serving/releases/download/v0.3.0/istio.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -

# Label the default namespace with istio-injection=enabled.
kubectl label namespace default istio-injection=enabled
```

Monitor the Istio components until all of the components show a `STATUS` of
`Running` or `Completed`:

```shell
kubectl get pods --namespace istio-system
```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

## Installing Knative Serving

Next, install [Knative Serving](https://github.com/knative/serving):

Because you have limited resources available, install only the Knative Serving
component, omitting the other Knative components as well as the observability
and monitoring plugins.

Enter the following command:

```shell
curl -L https://github.com/knative/serving/releases/download/v0.3.0/serving.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -
```

Monitor the Knative components until all of the components show a `STATUS` of
`Running`:

```shell
kubectl get pods --namespace knative-serving
```

Just as with the Istio components, it will take a few seconds for the Knative
components to be up and running; you can rerun the command to see the current
status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

Now you can deploy an app to your newly created Knative cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](getting-started-knative-app/)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../../serving/samples/) repo.

> Note: When looking up the IP address to use for accessing your app, you need
> to look up the NodePort for the `istio-ingressgateway` well as the IP
> address used for Minikube. You can use the following command to look up the
> value to use for the {IP_ADDRESS} placeholder used in the samples:

```shell
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

echo $(minikube ip):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

## Cleaning up

Delete the Kubernetes cluster along with Knative, Istio, and any deployed apps:

```shell
minikube delete
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
