---
title: "Installing Istio for Knative"
weight: 15
type: "docs"
---

This guide walks you through manually installing and customizing Istio for use
with Knative.

If your cloud platform offers a managed Istio installation, we recommend
installing Istio that way, unless you need the ability to customize your
installation. If your cloud platform offers a managed Istio installation, the
[install guide](./README.md) for your specific platform will have those
instructions.

For example, the [GKE Install Guide](./knative-with-gke.md) includes the
instructions for installing Istio on your cluster using `gcloud`.

## Before you begin

You need:

- A Kubernetes cluster created.
- [`helm`](https://helm.sh/) installed.

## Installing Istio

When you install Istio, there are a few options depending on your goals. For a
basic Istio installation suitable for most Knative use cases, follow the
[Installing Istio without sidecar injection](#installing-istio-without-sidecar-injection)
instructions. If you're familiar with Istio and know what kind of installation
you want, read through the options and choose the installation that suits your
needs.

You can easily customize your Istio installation with `helm`. The below sections
cover a few useful Istio configurations and their benefits.

### Choosing an Istio installation

You can install Istio with or without a service mesh:

- _automatic sidecar injection_: Enables the Istio service mesh by
  [automatically injecting the Istio sidecars][1]. The sidecars are injected
  into each pod of your cluster as they are created.

- _manual sidecar injection_: Provides your Knative installation with traffic
  routing and ingress, without the Istio service mesh. You do have the option of
  later enabling the service mesh if you [manually inject the Istio
  sidecars][2].

If you are just getting started with Knative, we recommend installing Istio
without automatic sidecar injection.

### Downloading Istio and installing CRDs

1. Enter the following commands to download Istio:

   ```shell
   # Download and unpack Istio
   export ISTIO_VERSION=1.1.7
   curl -L https://git.io/getLatestIstio | sh -
   cd istio-${ISTIO_VERSION}
   ```

1. Enter the following command to install the Istio CRDs first:

   ```shell
   for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
   ```

   Wait a few seconds for the CRDs to be committed in the Kubernetes API-server,
   then continue with these instructions.

1. Create `istio-system` namespace

   ```shell
   cat <<EOF | kubectl apply -f -
   apiVersion: v1
   kind: Namespace
   metadata:
     name: istio-system
     labels:
       istio-injection: disabled
   EOF
   ```

1. Finish the install by applying your desired Istio configuration:
   - [Installing Istio without sidecar injection](#installing-istio-without-sidecar-injection)(Recommended
     default installation)
   - [Installing Istio with sidecar injection](#installing-istio-with-sidecar-injection)
   - [Installing Istio with SDS to secure the ingress gateway](#installing-istio-with-SDS-to-secure-the-ingress-gateway)

#### Installing Istio without sidecar injection

If you want to get up and running with Knative quickly, we recommend installing
Istio without automatic sidecar injection. This install is also recommended for
users who don't need the Istio service mesh, or who want to enable the service
mesh by [manually injecting the Istio sidecars][2].

Enter the following command to install Istio:

```shell
# A lighter template, with just pilot/gateway.
# Based on install/kubernetes/helm/istio/values-istio-minimal.yaml
helm template --namespace=istio-system \
  --set prometheus.enabled=false \
  --set mixer.enabled=false \
  --set mixer.policy.enabled=false \
  --set mixer.telemetry.enabled=false \
  `# Pilot doesn't need a sidecar.` \
  --set pilot.sidecar=false \
  --set pilot.resources.requests.memory=128Mi \
  `# Disable galley (and things requiring galley).` \
  --set galley.enabled=false \
  --set global.useMCP=false \
  `# Disable security / policy.` \
  --set security.enabled=false \
  --set global.disablePolicyChecks=true \
  `# Disable sidecar injection.` \
  --set sidecarInjectorWebhook.enabled=false \
  --set global.proxy.autoInject=disabled \
  --set global.omitSidecarInjectorConfigMap=true \
  --set gateways.istio-ingressgateway.autoscaleMin=1 \
  --set gateways.istio-ingressgateway.autoscaleMax=2 \
  `# Set pilot trace sampling to 100%` \
  --set pilot.traceSampling=100 \
  install/kubernetes/helm/istio \
  > ./istio-lean.yaml

kubectl apply -f istio-lean.yaml
```

#### Installing Istio with sidecar injection

If you want to enable the Istio service mesh, you must enable [automatic sidecar
injection][1]. The Istio service mesh provides a few benefits:

- Allows you to turn on [mutual TLS][4], which secures service-to-service
  traffic within the cluster.

- Allows you to use the [Istio authorization policy][5], controlling the access
  to each Knative service based on Istio service roles.

Enter the following command to install Istio:

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
  --set gateways.istio-ingressgateway.autoscaleMin=1 \
  --set gateways.istio-ingressgateway.autoscaleMax=2 \
  --set gateways.istio-ingressgateway.resources.requests.cpu=500m \
  --set gateways.istio-ingressgateway.resources.requests.memory=256Mi \
  `# More pilot replicas for better scale` \
  --set pilot.autoscaleMin=2 \
  `# Set pilot trace sampling to 100%` \
  --set pilot.traceSampling=100 \
  install/kubernetes/helm/istio \
  > ./istio.yaml

kubectl apply -f istio.yaml
```

#### Installing Istio with SDS to secure the ingress gateway

Install Istio with [Secret Discovery Service (SDS)][3] to enable a few
additional configurations for the gateway TLS. This will allow you to:

- Dynamically update the gateway TLS with multiple TLS certificates to terminate
  TLS connections.

- Use [Auto TLS](../serving/using-auto-tls.md).

The below `helm` flag is needed in your `helm` command to enable `SDS`:

```
--set gateways.istio-ingressgateway.sds.enabled=true
```

Enter the following command to install Istio with ingress `SDS` and automatic
sidecar injection:

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
  --set gateways.istio-ingressgateway.autoscaleMin=1 \
  --set gateways.istio-ingressgateway.autoscaleMax=2 \
  --set gateways.istio-ingressgateway.resources.requests.cpu=500m \
  --set gateways.istio-ingressgateway.resources.requests.memory=256Mi \
  `# Enable SDS in the gateway to allow dynamically configuring TLS of gateway.` \
  --set gateways.istio-ingressgateway.sds.enabled=true \
  `# More pilot replicas for better scale` \
  --set pilot.autoscaleMin=2 \
  `# Set pilot trace sampling to 100%` \
  --set pilot.traceSampling=100 \
  install/kubernetes/helm/istio \
  > ./istio.yaml

  kubectl apply -f istio.yaml

```

### Updating your install to use cluster local gateway

If you want your Routes to be visible only inside the cluster, you may want to
enable [cluster local routes](../serving/cluster-local-route.md). To use
this feature, add an extra Istio cluster local gateway to your cluster. Enter
the following command to add the cluster local gateway to an existing Istio
installation:

```shell
# Add the extra gateway.
helm template --namespace=istio-system \
  --set gateways.custom-gateway.autoscaleMin=1 \
  --set gateways.custom-gateway.autoscaleMax=2 \
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
  > ./istio-local-gateway.yaml

kubectl apply -f istio-local-gateway.yaml
```

Alternatively, if you want to install the cluster local gateway for **development purposes**, enter the following command 
without `helm` for an easy installation:

```shell
# Istio minor version should be 1.2 or 1.3
export ISTIO_MINOR_VERSION=1.2

export VERSION=$(curl https://raw.githubusercontent.com/knative/serving/master/third_party/istio-${ISTIO_MINOR_VERSION}-latest)

kubectl apply -f https://raw.githubusercontent.com/knative/serving/master/third_party/${VERSION}/istio-knative-extras.yaml
```

**Note:** This method is only for development purposes. The production readiness of the above 
installation method is not ensured. For production installation, refer the `helm` installation method in this
section.

### Verifying your Istio install

View the status of your Istio installation to make sure the install was
successful. It might take a few seconds, so rerun the following command until
all of the pods show a `STATUS` of `Running` or `Completed`:

```bash
kubectl get pods --namespace istio-system
```

> Tip: You can append the `--watch` flag to the `kubectl get` commands to view
> the pod status in realtime. You use `CTRL + C` to exit watch mode.


### Configuring DNS

Knative dispatches to different services based on their hostname, so it greatly
simplifies things to have DNS properly configured. For this, we must look up the
external IP address that Gloo received. This can be done with the following command:

```
$ kubectl get svc -nistio-system
NAME                    TYPE           CLUSTER-IP   EXTERNAL-IP    PORT(S)                                      AGE
cluster-local-gateway   ClusterIP      10.0.2.216   <none>         15020/TCP,80/TCP,443/TCP                     2m14s
istio-ingressgateway    LoadBalancer   10.0.2.24    34.83.80.117   15020:32206/TCP,80:30742/TCP,443:30996/TCP   2m14s
istio-pilot             ClusterIP      10.0.3.27    <none>         15010/TCP,15011/TCP,8080/TCP,15014/TCP       2m14s
```

This external IP can be used with your DNS provider with a wildcard `A` record;
however, for a basic functioning DNS setup (not suitable for production!) this
external IP address can be used with `xip.io` in the `config-domain` ConfigMap
in `knative-serving`. You can edit this with the following command:

```
kubectl edit cm config-domain --namespace knative-serving
```

Given the external IP above, change the content to:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
data:
  # xip.io is a "magic" DNS provider, which resolves all DNS lookups for:
  # *.{ip}.xip.io to {ip}.
  34.83.80.117.xip.io: ""
```

## Istio resources

- For the official Istio installation guide, see the
  [Istio Kubernetes Getting Started Guide](https://istio.io/docs/setup/kubernetes/).

- For the full list of available configs when installing Istio with `helm`, see
  the
  [Istio Installation Options reference](https://istio.io/docs/reference/config/installation-options/).

## Clean up Istio

Enter the following command to remove all of the Istio files:

```shell
cd ../
rm -rf istio-${ISTIO_VERSION}
```

## What's next

- [Install Knative](./README.md).
- Try the
  [Getting Started with App Deployment guide](../serving/getting-started-knative-app/)
  for Knative serving.

[1]:
  https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#automatic-sidecar-injection
[2]:
  https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#manual-sidecar-injection
[3]: https://istio.io/docs/tasks/traffic-management/ingress/secure-ingress-sds/
[4]: https://istio.io/docs/tasks/security/mutual-tls/
[5]: https://istio.io/docs/tasks/security/authz-http/
