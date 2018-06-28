# Knative the easy way (with Minikube)

This how-to will guide you through installation of the latest version of [Knative](https://github.com/knative/serving) using pre-built images and demonstrate deployment of a sample app onto the newly created Knative cluster.

## Prerequisites

Knative requires a Kubernetes cluster (v1.10 or newer). For these instructions we will use [Minikube](https://github.com/kubernetes/minikube).

### Install kubectl and Minikube

[Install kubectl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)

[Install and configure minikube](https://github.com/kubernetes/minikube#installation) with a [VM driver](https://github.com/kubernetes/minikube#requirements), e.g. `kvm2` on Linux or `hyperkit` on macOS.

## Start Kubernetes cluster

Once kubectl and  Minikube are installed, create a cluster with version 1.10 or greater and your chosen VM driver:

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

## Install Istio

Knative depends on Istio. Run the following to install Istio. (We are changing `LoadBalancer` to `NodePort` for the `istio-ingress` service)

```shell
wget -O - https://storage.googleapis.com/knative-releases/latest/istio.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply -f -

# Label the default namespace with istio-injection=enabled.
kubectl label namespace default istio-injection=enabled
```

Wait until each Istio component is running or completed (STATUS column shows 'Running' or 'Completed'):

```shell
kubectl get pods -n istio-system --watch
```

CTRL+C when it's done.

## Knative

Next, we will install [Knative](https://github.com/knative/serving):

We are using the `https://storage.googleapis.com/elafros-releases/latest/release-lite.yaml` file which omits some of the monitoring components to reduce the memory used by the Knative components since you do have limited resources available. To use the provided `release-lite.yaml` release run:

```shell
kubectl apply -f https://storage.googleapis.com/knative-releases/latest/release-lite.yaml
```

Wait until all Knative components are running (STATUS column shows 'Running'):

```shell
kubectl get pods -n knative-serving --watch
```

CTRL+C when it's done.

Now you can deploy your app/function to your newly created Knative cluster.

## Test App

The following instruction will deploy the `Primer` sample app onto your new Knative cluster.

> Note, you will be deploying using pre-build image so no need to clone the Primer repo or install anything locally. If you want to run the `Primer` app locally see the [Primer Readme](https://github.com/mchmarny/primer) for instructions.

```shell
kubectl apply -f https://storage.googleapis.com/knative-samples/primer.yaml
```

Wait for the ingress to get created. This may take a few seconds. You can check by running:

```shell
kubectl get ing --watch
```

CTRL+C when it's done.

Capture the IP and host name by running these commands:

> Note that we changed the `istio-ingress` service to use a `NodePort` since `LoadBalancer` is not supported on Minikube. Here we look up the IP of the Minikube node as well as the actual port used for the ingress.

```shell
export SERVICE_IP=$(minikube ip):$(kubectl get svc istio-ingress -n istio-system \
  -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')

export SERVICE_HOST=`kubectl get ing primer-ingress \
  -o jsonpath="{.spec.rules[0]['host']}"`
```

> Alternatively, you can create an entry in your DNS server to point your subdomain to the IP.

Run the Primer app. The higher the number, the longer it will run.

```shell
curl -H "Host: ${SERVICE_HOST}" http://$SERVICE_IP/5000000
```

## Cleanup

Delete the Kubernetes cluster along with Knative, Istio and Primer sample app

```shell
minikube delete
```