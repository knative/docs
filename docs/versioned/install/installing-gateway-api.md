---
audience: administrator
components:
  - serving
function: how-to
---

# Installing Gateway API for Knative

This guide shows how to install the Kubernetes Gateway API. There are multiple projects that support the Gateway API. You can install either the standard or experimental Gateway API channel.

## Before you begin

This installation requires the following prerequisites:

- A Kubernetes cluster with the Knative Serving component installed.
- A Gateway Controller. You can install a Gateway Controller by using one of the following guides:

    - [Simple Gateway](https://gateway-api.sigs.k8s.io/guides/simple-gateway/) (a good one to start out with)
    - [HTTP routing](https://gateway-api.sigs.k8s.io/guides/http-routing/)
    - [HTTP redirects and rewrites](https://gateway-api.sigs.k8s.io/guides/http-redirect-rewrite/)
    - [HTTP traffic splitting](https://gateway-api.sigs.k8s.io/guides/traffic-splitting/)
    - [Routing across Namespaces](https://gateway-api.sigs.k8s.io/guides/multiple-ns/)
    - [Configuring TLS](https://gateway-api.sigs.k8s.io/guides/tls/)
    - [TCP routing](https://gateway-api.sigs.k8s.io/guides/tcp/)
    - [gRPC routing](https://gateway-api.sigs.k8s.io/guides/grpc-routing/)
    - [Migrating from Ingress](https://gateway-api.sigs.k8s.io/guides/migrating-from-ingress/)

Some Gateway controller setups include the installation of the Gateway API bundle.

## Install the standard Gateway API channel

The standard release channel includes all resources that have graduated to general availability or beta, including [GatewayClass](https://gateway-api.sigs.k8s.io/api-types/gatewayclass/), [Kubernetes Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/), [HTTPRoute](https://gateway-api.sigs.k8s.io/api-types/httproute/), and [ReferenceGrant](https://gateway-api.sigs.k8s.io/api-types/referencegrant/).

- Use the following command to install the standard channel:

    ```bash
    kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
    ```

    For more information about the `kubectl --server-side` command, see [Server-Side Apply](https://kubernetes.io/docs/reference/using-api/server-side-apply/).

## Install the experimental Gateway API Channel

The experimental release channel includes everything in the standard release channel plus some experimental resources and fields. This includes TCPRoute, TLSRoute, and UDPRoute.

Future releases of the API could include breaking changes to experimental resources and fields. For example, any experimental resource or field could be removed in a future release.

- Use the following command to install the experimental channel:

    ```bash
    kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml
    ```

Refer to the server-side apply documentation to learn more about this kubectl command option.

## Uninstall the Gateway API

To uninstall the Gateway API, replace `kubectl apply --server-side -f` with `kubectl delete --server-side -f` in the commands above.

Do not uninstall if the resources are in use or if they were installed by a Gateway controller. This command uninstalls the Gateway API resources for the entire cluster.

## See also

- [Kubernetes Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/)
- [Getting started with Gateway API](https://gateway-api.sigs.k8s.io/guides/)
