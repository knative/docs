---
audience: administrator
components:
  - serving
function: how-to
---

# Configure Knative networking

This page describes and provides installation and configuration guidance for the following networking plugins.

## Network layers

For most users, the Kourier ingress controller is sufficient with the already installed default Istio gateway resource. You can expand your capabilities with more Ingress, full-feature service mesh, and the Kubernetes Gateway API.

### Kourier controller

Designed for Knative Serving with efficient serverless function deployment is the goal. Has a simple setup. Kourier is the default ingress choice for most users, when a service mesh is not required, as it has a simple setup.

### Contour controller

General-purpose Envoy-based ingress controller with full Kubernetes Ingress support. A Knative ingress controller that integrates with Project Contour, translating Knative Ingress into Contour’s HTTPProxy resources.

A good choice for clusters that already run non-Knative apps and want to reuse a single Ingress controller as well as teams who are already using Contour/Envoy and wanting Knative integration with advanced routing but not full service mesh.

### Istio full-feature service mesh

A full-feature service mesh integrated with Knative that can also function as a Knative ingress. Best for enterprises already running Istio or needing advanced service mesh features alongside Knative.

Note that Knative has a default Istio integration without the full-feature service mesh. The `knative-ingress-gateway` in the `knative-serving` namespace is a shared Istio gateway resource that handles all incoming (north-south) traffic to Knative services. This gateway points to the underlying 1istio-ingressgateway` service in the `istio-system` namespace. You can replace this gateway with one of your own, see [Configuring the Ingress gateway](setting-up-custom-ingress-gateway.md).

### Gateway API

Emerging Kubernetes-native networking API (replacing Ingress)extensible than traditional Ingress APIs. It is a specification, not an implementation itself.

The Kubernetes Gateway API requires a controller or service mesh. Istio and Contour implementations are tested though other Gateway API implementations should work. For more information see [Tested Gateway API version and Ingress](https://github.com/knative-extensions/net-gateway-api/blob/main/docs/test-version.md).

Best for forward-looking teams adopting Gateway API to unify ingress across Kubernetes, with Knative leveraging the same standard.

## Architecture

=== "Kourier"

    ```mermaid
    ---
    config:
      theme: default
      layout: elk
      look: neo
    ---
    flowchart LR
     subgraph Kourier["Kourier for Knative"]
            K2["Creates Ingress objects"]
            K1["Kourier"]
            K3["Class: kourier.ingress.networking.knative.dev"]
      end
        K1 --> K2
        K2 --> K3
        style Kourier fill:#e3f2fd
    ```
=== "Courier"

    ```mermaid
    ---
    config:
      theme: default
      layout: elk
      look: neo
    ---
    flowchart LR
    subgraph Contour["Contour for Knative"]
          C1[Contour] --> C2[Creates Ingress objects]
          C2 --> C3[Class: contour.ingress.networking.knative.dev]
    end
    style Contour fill:#fff3e0
    ```

=== "Istio"

    ```mermaid
    ---
    config:
      theme: default
      layout: elk
      look: neo
    ---
    flowchart LR
    subgraph Istio["Istio full-feature service mesh for Knative"]
          I1[Istio] --> I2[Creates VirtualService + Gateway]
          I2 --> I3[Class: istio.ingress.networking.knative.dev]
          I3 --> I4[No native Ingress objects]
    end
    style Istio fill:#f3e5f5
    ```

=== "Gateway API"

    ```mermaid
    ---
    config:
      theme: default
      layout: elk
      look: neo
    ---
    flowchart TB
     subgraph s1["Gateway API for Knative"]
        HR["HTTPRoute"]
        GW["Gateway listener"]
      end
        KSvc["Knative Service"] -- owns --> Route["Route"]
        Route -- creates --> HR & GW
    ```

## Network Layer setup

This section provides installation and configuration steps.

=== "Kourier"

    --8<-- "netadapter-kourier.md"

=== "Contour"

    --8<-- "netadapter-contour.md"

=== "Istio"

    For detailed instructions, see [Install Istio for Knative](../install/installing-istio.md).

    --8<-- "netadapter-istio.md"

=== "Gateway API"

    --8<-- "netadapter-gatewayapi.md"

### Verify installations

    Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`. Use the `get-pods` command to determine network components and their status.

    ```bash
    kubectl get pods -n knative-serving
    ```

### Configure DNS

--8<-- "dns.md"
--8<-- "real-dns-yaml.md"
--8<-- "no-dns.md"
