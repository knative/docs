---
audience: administrator
components:
  - serving
function: how-to
---

# Configure Contour adapter

This page describes how to install the Contour adapter for Knative.

## Before you begin

This installation requires a Kubernetes cluster with [Contour](https://projectcontour.io/docs/) installed.

For information about Contour versions, see the Contour [Compatibility Matrix](https://projectcontour.io/resources/compatibility-matrix/).

## Install Contour adapter for Knative

1. Install a properly configured Contour by running the folowing command command:

```bash
kubectl apply -f {{ artifact(repo="net-contour",org="knative-extensions",file="contour.yaml")}}
```

1. Install the Knative Contour controller:

```bash
kubectl apply -f {{ artifact(repo="net-contour",org="knative-extensions",file="net-contour.yaml")}}
```

1. Configure Knative Serving to use Contour by default:

```bash
kubectl patch configmap/config-network \
--namespace knative-serving \
--type merge \
--patch '{"data":{"ingress-class":"contour.ingress.networking.knative.dev"}}'
```

1. Fetch the External IP address or CNAME:

```bash
kubectl --namespace contour-external get service envoy
```

The adapter's configurations are performed natively through Contour. For more information and resources see [Contour](https://projectcontour.io/) home page.

## Visibility

The following table shows the classes and services configurations for how to expose services.

| ExternalIP | ClusterLocal |
| --- | --- |
| class: contour-external | class: contour-internal |
| service: contour-external/envoy | service: contour-internal/envoy |
