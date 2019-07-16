---
title: "Install on Minikube"
linkTitle: "Minikube"
weight: 10
type: "docs"
---

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](./README.md).

## Before you begin

Although Knative requires a Kubernetes cluster v1.11 or newer, installing
Knative on [Minikube](https://github.com/kubernetes/minikube) requires a cluster
v1.12 or newer.

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

After kubectl and Minikube are installed, create a cluster with version 1.12 or
greater and your chosen VM driver:

For Linux use:

```shell
minikube start --memory=8192 --cpus=6 \
  --kubernetes-version=v1.12.0 \
  --vm-driver=kvm2 \
  --disk-size=30g \
  --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
```

For macOS use:

```shell
minikube start --memory=8192 --cpus=6 \
  --kubernetes-version=v1.12.0 \
  --vm-driver=hyperkit \
  --disk-size=30g \
  --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
```

## Installing Istio

> Note: [Ambassador](https://www.getambassador.io/) and
> [Gloo](https://gloo.solo.io/) are available as an alternative to Istio.
> [Click here](./Knative-with-Ambassador.md) to install Knative with Ambassador.
> [Click here](./Knative-with-Gloo.md) to install Knative with Gloo.

Knative depends on Istio. Run the following to install Istio. (We are changing
`LoadBalancer` to `NodePort` for the `istio-ingress` service).

```shell
kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.5.2/third_party/istio-1.0.7/istio-crds.yaml &&
curl -L https://raw.githubusercontent.com/knative/serving/v0.5.2/third_party/istio-1.0.7/istio.yaml \
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

## Installing Knative

The following commands install all available Knative components as well as the
standard set of observability plugins. To customize your Knative installation,
see [Performing a Custom Knative Installation](./Knative-custom-install.md).

1. If you are upgrading from Knative 0.3.x: Update your domain and static IP
   address to be associated with the LoadBalancer `istio-ingressgateway` instead
   of `knative-ingressgateway`. Then run the following to clean up leftover
   resources:

   ```shell
   kubectl delete svc knative-ingressgateway -n istio-system
   kubectl delete deploy knative-ingressgateway -n istio-system
   ```

   If you have the Knative Eventing Sources component installed, you will also
   need to delete the following resource before upgrading:

   ```shell
   kubectl delete statefulset/controller-manager -n knative-sources
   ```

   While the deletion of this resource during the upgrade process will not
   prevent modifications to Eventing Source resources, those changes will not be
   completed until the upgrade process finishes.

1. To install Knative, first install the CRDs by running the `kubectl apply`
   command once with the `-l knative.dev/crd-install=true` flag. This prevents
   race conditions during the install, which cause intermittent errors:

   ```shell
   kubectl apply --selector knative.dev/crd-install=true \
   --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml \
   --filename https://github.com/knative/build/releases/download/v0.7.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml
   ```

1. To complete the install of Knative and its dependencies, run the
   `kubectl apply` command again, this time without the `--selector` flag, to
   complete the install of Knative and its dependencies:

   ```shell
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager \
   --filename https://github.com/knative/build/releases/download/v0.7.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml
   ```

   > **Notes**:
   >
   > - By default, the Knative Serving component installation (`serving.yaml`)
   >   includes a controller for
   >   [enabling automatic TLS certificate provisioning](../serving/using-auto-tls.md).
   >   If you do intend on immediately enabling auto certificates in Knative,
   >   you can remove the
   >   `--selector networking.knative.dev/certificate-provider!=cert-manager`
   >   statement to install the controller. Otherwise, you can choose to install
   >   the auto certificates feature and controller at a later time.

1. Monitor the Knative components until all of the components show a `STATUS` of
   `Running`:

   ```shell
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-build
   kubectl get pods --namespace knative-eventing
   kubectl get pods --namespace knative-monitoring
   ```

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](./getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

> Note: When looking up the IP address to use for accessing your app, you need
> to look up the NodePort for the `istio-ingressgateway` well as the IP address
> used for Minikube. You can use the following command to look up the value to
> use for the {IP_ADDRESS} placeholder used in the samples:

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
