---
title: "Performing a Custom Istio Installation"
weight: 15
type: "docs"
---

Use this guide to perform a custom installation of Istio for use with Knative.

## Before you begin

You need:
- A Kubernetes cluster created
- [`helm`](https://helm.sh/) installed

## Download Istio

Run below command to download Istio.
```shell
# Download and unpack Istio
export ISTIO_VERSION=1.1.3
curl -L https://git.io/getLatestIstio | sh -
cd istio-${ISTIO_VERSION}
```

## Install Istio CRDs 
Default Istio Installation
Run below command to install Istio CRDs first.
```shell
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
```
wait a few seconds for the CRDs to be committed in the Kubernetes API-server

## Custom Installation

### Istio with Sidecar Injector

If you need Istio service mesh, and want to enable it by [automatically 
injecting the Istio sidecars](https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#automatic-sidecar-injection), then Istio sidecar injector and related configurations are needed in your Istio. Run 
below command to install the custom Istio.
```shell
# A template with sidecar injection enabled.
helm template --namespace=istio-system \
  --set sidecarInjectorWebhook.enabled=true \
  --set sidecarInjectorWebhook.enableNamespacesByDefault=true \
  --set global.proxy.autoInject=disabled \
  --set global.disablePolicyChecks=true \
  --set prometheus.enabled=false \
  `# Disable mixer prometheus adapter to remove istio default metrics.` \
  --set mixer.adapters.prometheus.enabled=false \
  `# Disable mixer policy check, since in our template we set no policy.` \
  --set global.disablePolicyChecks=true \
  `# Set gateway pods to 1 to sidestep eventual consistency / readiness problems.` \
  --set gateways.istio-ingressgateway.autoscaleMin=1 \
  --set gateways.istio-ingressgateway.autoscaleMax=1 \
  --set gateways.istio-ingressgateway.resources.requests.cpu=500m \
  --set gateways.istio-ingressgateway.resources.requests.memory=256Mi \
  `# More pilot replicas for better scale` \
  --set pilot.autoscaleMin=2 \
  `# Set pilot trace sampling to 100%` \
  --set pilot.traceSampling=100 \
  install/kubernetes/helm/istio \
  `# Removing trailing whitespaces to make automation happy` \
  | sed 's/[ \t]*$//' \
  > ./istio.yaml

kubectl apply -f istio.yaml
```

### Istio with no Sidecar Injector

If you don't need Istio service mesh, or want to enable the service by 
[manually injecting the Istio sidecars](https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#manual-sidecar-injection), you can install an Istio without sidecar injector. Run below command to install the custom 
Istio.
```shell
# A lighter template, with no sidecar injection.
helm template --namespace=istio-system \
  --set sidecarInjectorWebhook.enabled=false \
  --set global.proxy.autoInject=disabled \
  --set global.omitSidecarInjectorConfigMap=true \
  --set global.disablePolicyChecks=true \
  --set prometheus.enabled=false \
  `# Disable mixer prometheus adapter to remove istio default metrics.` \
  --set mixer.adapters.prometheus.enabled=false \
  `# Disable mixer policy check, since in our template we set no policy.` \
  --set global.disablePolicyChecks=true \
  `# Set gateway pods to 1 to sidestep eventual consistency / readiness problems.` \
  --set gateways.istio-ingressgateway.autoscaleMin=1 \
  --set gateways.istio-ingressgateway.autoscaleMax=1 \
  `# Set pilot trace sampling to 100%` \
  --set pilot.traceSampling=100 \
  install/kubernetes/helm/istio \
  `# Removing trailing whitespaces to make automation happy` \
  | sed 's/[ \t]*$//' \
  > ./istio-lean.yaml

kubectl apply -f istio-lean.yaml
```

### Install Cluster Local Gateway

If you want your Routes to be only visible inside the cluster, you may
want to use the feature of [cluster local route](../docs/serving/cluster-local-route.md). In order to use this feature, an extra Istio
cluster local gateway needs to be added into your cluster. Run below command
to add the cluster local gateway.
```shell
# Generate the extra gateway.
helm template --namespace=istio-system \
  --set gateways.custom-gateway.autoscaleMin=1 \
  --set gateways.custom-gateway.autoscaleMax=1 \
  --set gateways.custom-gateway.cpu.targetAverageUtilization=60 \
  --set gateways.custom-gateway.labels.app='cluster-local-gateway' \
  --set gateways.custom-gateway.labels.istio='cluster-local-gateway' \
  --set gateways.custom-gateway.type='ClusterIP' \
  --set gateways.istio-ingressgateway.enabled=false \
  --set gateways.istio-egressgateway.enabled=false \
  --set gateways.istio-ilbgateway.enabled=false \
  install/kubernetes/helm/istio \
  -f install/kubernetes/helm/istio/example-values/values-istio-gateways.yaml \
  | sed -e "s/custom-gateway/cluster-local-gateway/g" -e "s/customgateway/clusterlocalgateway/g" \
  `# Removing trailing whitespaces to make automation happy` \
  | sed "s/[[:space:]]*$//" \
  > ./istio-local-gateway.yaml

kubectl apply -f istio-local-gateway.yaml
```

### Istio with Secret Discovery Service

[Secret Discovery Service](https://istio.io/docs/tasks/traffic-management/secure-ingress/sds/) is needed if you want to dyanmically update your Gateway 
with multiple TLS certificates to terminate TLS connection. The below`helm` flag is needed in your `helm` command to enable `SDS`.
```
--set gateways.istio-ingressgateway.sds.enabled=true
```
For example, the `helm` command for installing Istio with Ingress `SDS` and 
Istio sidecar injector is
```shell
helm template --namespace=istio-system \
  --set sidecarInjectorWebhook.enabled=true \
  --set sidecarInjectorWebhook.enableNamespacesByDefault=true \
  --set global.proxy.autoInject=disabled \
  --set global.disablePolicyChecks=true \
  --set prometheus.enabled=false \
  `# Disable mixer prometheus adapter to remove istio default metrics.` \
  --set mixer.adapters.prometheus.enabled=false \
  `# Disable mixer policy check, since in our template we set no policy.` \
  --set global.disablePolicyChecks=true \
  `# Set gateway pods to 1 to sidestep eventual consistency / readiness problems.` \
  --set gateways.istio-ingressgateway.autoscaleMin=1 \
  --set gateways.istio-ingressgateway.autoscaleMax=1 \
  --set gateways.istio-ingressgateway.resources.requests.cpu=500m \
  --set gateways.istio-ingressgateway.resources.requests.memory=256Mi \
  `# Enable SDS in the gateway to allow dynamically configuring TLS of gateway.` \
  --set gateways.istio-ingressgateway.sds.enabled=true \
  `# More pilot replicas for better scale` \
  --set pilot.autoscaleMin=2 \
  `# Set pilot trace sampling to 100%` \
  --set pilot.traceSampling=100 \
  install/kubernetes/helm/istio \
  `# Removing trailing whitespaces to make automation happy` \
  | sed 's/[ \t]*$//' \
  > ./istio.yaml

  kubectl apply -f istio.yaml

```

## Full Istio Installation Guide.

1. For the full Istio Installation Guide, check [doc](https://istio.io/docs/setup/kubernetes/).

1. For the full Istio Installation Option, check [doc](https://istio.io/docs/reference/config/installation-options/).

## Clean up
Run below command to clean up all of the Istio files.
```shell
cd ../
rm -rf istio-${ISTIO_VERSION}
```
