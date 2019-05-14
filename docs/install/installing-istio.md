---
title: "Installing Istio for Knative"
weight: 15
type: "docs"
---

This guide walks you through manually installing and customizing Istio for use
with Knative.

If your cloud platform offers a managed Istio installation, we recommend
installing Istio that way, unless you need the ability to customize your
installation. If your cloud platform offers a managed Istio installation,
the [install guide](./) for your specific platform will have those instructions.
For example, the [GKE Install Guide](./knative-with-gke) includes the
instructions for installing Istio on your cluster using `gcloud`.

## Before you begin

You need:
- A Kubernetes cluster created
- [`helm`](https://helm.sh/) installed

## Installing Istio

When you install Istio, there are a couple of different steps, and a few options
depending on your goals. For a basic Istio installation suitable for most use
cases, see the [Default Istio installation](#default-istio-instllation)
instructions. Those steps will get you up and running quickly without having to
make decisions about Istio. To customize Istio your Istion installion for use
with Knative, see the [Custom Istio installation](#customizing-your-installation) instructions.

### Default Istio installation
The following steps install a default version of Istio that is appropriate for
most Knative use cases.

1. Enter the following commands to download Istio:
   ```shell
   # Download and unpack Istio
   export ISTIO_VERSION=1.1.3
   curl -L https://git.io/getLatestIstio | sh -
   cd istio-${ISTIO_VERSION}
   ```

1. Enter the following command to install the Istio CRDs first:
   ```shell
   for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
   ```
   Wait a few seconds for the CRDs to be committed in the Kubernetes API-server,
   then continue with these instructions.

1. Enter the following command to install Istio:
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

This default installation enables [automatic sidecar injection][1].

## Customizing your installation

You can easily customize your Istio installation with `helm`. The below sections
cover a few useful customizations and their purpose.

### Installing Istio with sidecar injection

If you need Istio service mesh, and want to enable it by
[automatically injecting the Istio sidecars][1], then you must enable Istio
sidecar injection and add a few related configurations your Istio installation.

1. Enter the following commands to download Istio:
   ```shell
   # Download and unpack Istio
   export ISTIO_VERSION=1.1.3
   curl -L https://git.io/getLatestIstio | sh -
   cd istio-${ISTIO_VERSION}
   ```

1. Enter the following command to install the Istio CRDs first:
   ```shell
   for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
   ```
   Wait a few seconds for the CRDs to be committed in the Kubernetes API-server,
   then continue with these instructions.

1. Enter the following command to install Istio:
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

### Installing Istio with no sidecar injection

If you don't need Istio service mesh, or want to enable the service by 
[manually injecting the Istio sidecars](https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#manual-sidecar-injection), you can install an Istio without sidecar injector.

1. Enter the following commands to download Istio:
   ```shell
   # Download and unpack Istio
   export ISTIO_VERSION=1.1.3
   curl -L https://git.io/getLatestIstio | sh -
   cd istio-${ISTIO_VERSION}
   ```

1. Enter the following command to install the Istio CRDs first:
   ```shell
   for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
   ```
   Wait a few seconds for the CRDs to be committed in the Kubernetes API-server,
   then continue with these instructions.

1. Enter the following command to install Istio:
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

### Installing Istio with Secret Discovery Service

[Secret Discovery Service](https://istio.io/docs/tasks/traffic-management/secure-ingress/sds/)
is needed if you want to dynamically update your Gateway  with multiple TLS
certificates to terminate TLS connection. The below `helm` flag is needed in
your `helm` command to enable `SDS`:

```
--set gateways.istio-ingressgateway.sds.enabled=true
```

For example, the `helm` command for installing Istio with Ingress `SDS` and 
Istio sidecar injection is:

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

### Updating your install to use cluster local gateway

If you want your Routes to be visible only inside the cluster, you may
want to enable [cluster local routes](../docs/serving/cluster-local-route.md).
To use this feature, add an extra Istio cluster local gateway to your cluster.
Enter the following command to add the cluster local gateway to an existing
Istio installation:

```shell
# Add the extra gateway.
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

## Istio resources

- For the official Istio installation guide, see the
  [Istio Kubernetes Getting Started Guide](https://istio.io/docs/setup/kubernetes/).

- For the full list of available configs when installing Istio with `helm`, see
  the [Istio Installation Options reference](https://istio.io/docs/reference/config/installation-options/).

## Clean up Istio
Run below command to clean up all of the Istio files.
```shell
cd ../
rm -rf istio-${ISTIO_VERSION}
```

## What's next

- [Install Knative](./README.md).
- Try the [Getting Started with App Deployment guide](./getting-started-knative-app/)
  for Knative serving.

[1]: https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#automatic-sidecar-injection
