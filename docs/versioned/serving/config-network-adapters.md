---
audience: administrator
components:
  - serving
function: how-to
---

# Configure Knative networking

This page provides installation and configuration guidance for configuring Knative networking. These options include Ingress controls,  service-meshes, and gateways.

## Network layer options

Use the following command to determine which controllers are installed and their status.

```bash
kubectl get pods -n knative-serving
```

The controllers have the following base names:

- Kourier: `kourier-control-*`, and `kourier-gateway-*`.
- Contour: `contour-*`
- Istio: `istio-webhook-*`

The main Istio control plane pods such as `istiod-*` are in the `istio-system` namespace, but Knative adds the `istio-webhook-*` pod in `knative-serving` when Istio is the chosen networking layer.

Review the following tabs to determine the optimal networking layer for your cluster. Knative installs the Kourier controller as the default ingress. For most users, the Kourier ingress controller is sufficient with the already installed default Istio gateway resource. You can expand your capabilities with more ingress using Contour, a full-feature service mesh with Istio, and the Kubernetes Gateway API.

The `network-config` ConfigMap specifies the controller to be used with the ingress controller key. This key is patched with the name of the new controller when you configure a new one, as described in these instructions. See [Changing the controller](#change-the-controller) for more information about the ingress controller key.

=== "Kourier"

    ```mermaid
    ---
    config:
      theme: default
      layout: elk
      look: neo
    ---
    flowchart LR
    K1["Knative<br>net-kourier"] -- creates --> K2["Ingress&nbsp;objects"]
    K2 --> K3["Class: kourier.ingress.networking.knative.dev"]
    ```

    The Knative `net-kourier` is an Ingress for Knative Serving. Kourier is a lightweight alternative for the Istio ingress as its deployment consists only of an Envoy proxy and a control plane. 

    Designed for Knative Serving with efficient serverless function deployment is the goal. Kourier is the default ingress choice for most users, when a service mesh is not required, as it has a simple setup.

    The following setup procedure automatically obtains the latest release of [net-kourier](https://github.com/knative-extensions/net-kourier/releases) on the Knative extensions.

    --8<-- "netadapter-kourier.md"

=== "Contour"

    ```mermaid
    ---
    config:
      theme: default
      layout: elk
      look: neo
    ---
    flowchart LR
    C1["Knative<br>net-contour"] -- creates --> C2["Ingress&nbsp;objects"]
    C2 --> C3["Class: contour.ingress.networking.knative.dev"]
    ```

    The Knative `net-contour` controller enables Contour to satisfy the networking needs of Knative Serving by bridging Knative's KIngress resources to Contour's HTTPProxy resources.

    A good choice for clusters that already run non-Knative apps and want to reuse a single Ingress controller as well as teams who are already using Contour/Envoy and wanting Knative integration with advanced routing but not full service mesh.

    The following setup procedure automatically obtains the latest release of [net-contour](https://github.com/knative-extensions/net-contour/releases) on the Knative extensions.

    --8<-- "netadapter-contour.md"

=== "Istio"

    ```mermaid
    ---
    config:
      theme: default
      layout: elk
    ---
    flowchart LR
        I1["Knative&nbsp;net-istio"] -- creates --> I2["Service + Gateway"]
        I2 --> I3["Class: istio.ingress.networking.knative.dev<br>No native Ingress objects"]
    ```

    The Knative `net-istio` defines a KIngress controller for Istio. A full-feature service mesh integrated with Knative that can also function as a Knative ingress. Best for enterprises already running Istio or needing advanced service mesh features alongside Knative.

    Note that Knative has a default Istio integration without the full-feature service mesh. The `knative-ingress-gateway` in the `knative-serving` namespace is a shared Istio gateway resource that handles all incoming (north-south) traffic to Knative services. This gateway points to the underlying 1istio-ingressgateway` service in the `istio-system` namespace. You can replace this gateway with one of your own, see [Configuring the Ingress gateway](setting-up-custom-ingress-gateway.md).

    The following setup procedure automatically obtains the latest release of [net-istio](https://github.com/knative-extensions/net-istio/releases) on the Knative extensions.

    --8<-- "netadapter-istio.md"

=== "Ingress Gateway"

```mermaid
    ---
    config:
      layout: elk
      theme: default
      look: neo
    ---
    flowchart LR
        Client["External&nbsp;Client"] --> CGW["Custom&nbsp;Ingress&nbsp;Gateway"]
        CGW --> KIGW["Knative&nbsp;Ingress&nbsp;Gateway"] & Client
        KIGW --> Revision["Knative&nbsp;Revision"] & CGW
        Revision --> KIGW
    ```

    Knative uses a shared ingress gateway to serve all incoming traffic within Knative service mesh. For information on customizing the gateway, see [Configure the Ingress Gateway](/versioned/serving/setting-up-custom-ingress-gateway.md).

=== "Gateway API"

    ```mermaid
    ---
    config:
      layout: elk
      theme: default
    ---
    flowchart LR
      subgraph s1["Gateway API for Knative"]
            HR["HTTPRoute"]
            GW["Gateway listener"]
      end
        KSvc["Knative Service"] -- owns --> Route["Route"]
                Route -- creates --> HR & GW
    ```

    The Knative `net-gateway-api` is a KIngress implementation and testing for Knative integration with the Kubernetes Gateway API.

    The Kubernetes Gateway API requires a controller or service mesh. Istio and Contour implementations are tested though other Gateway API implementations should work. For more information see [Tested Gateway API version and Ingress](https://github.com/knative-extensions/net-gateway-api/blob/main/docs/test-version.md).

    Best for forward-looking teams adopting Gateway API to unify ingress across Kubernetes, with Knative leveraging the same standard.

    The following setup procedure automatically obtains the latest release of [net-gateway-api](https://github.com/knative-extensions/net-gateway-api/releases) on the Knative extensions.

    --8<-- "netadapter-gatewayapi.md"

## Configure DNS

--8<-- "dns.md"
--8<-- "real-dns-yaml.md"
--8<-- "no-dns.md"

## Change the controller

