---
audience: administrator
components:
  - serving
function: how-to
---

# Configure Contour adapter

This page describes how to install and configure the Contour adapter for Knative: `net-contour`.

## Before you begin

This installation requires a Kubernetes cluster with [Contour](https://projectcontour.io/docs/) installed.

For information about Contour versions, see the Contour [Compatibility Matrix](https://projectcontour.io/resources/compatibility-matrix/).

## Install and configure the adapter

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

1. Get the External IP address or full qualified domain name (CNAME):

    ```bash
    kubectl --namespace contour-external get service envoy
    ```

    Use this value to configure your external DNS records.

The adapter's configurations are performed natively through Contour. For more information and resources see [Contour](https://projectcontour.io/) home page.

## Visibility

The following table shows the classes and services that expose Contour networking.

| ExternalIP | ClusterLocal |
| --- | --- |
| class: contour-external | class: contour-internal |
| service: contour-external/envoy | service: contour-internal/envoy |
