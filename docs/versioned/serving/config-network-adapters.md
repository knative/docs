---
audience: administrator
components:
  - serving
function: how-to
---

# Configure Knative networking

This page provides installation and configuration guidance for configuring Knative networking. These options include Ingress controls,  service-meshes, and gateways.

### Determine current state

Use the following command to determine which controllers are installed and their status.

```bash
kubectl get pods -n knative-serving
```

The ingress controllers tested for Knative have the following base names:

- Kourier: `kourier-control-*`, and `kourier-gateway-*`. Kourier is included in the Knative Serving installation should appear in the results.
- Contour: `contour-*`
- Istio: `istio-webhook-*`. The main Istio control plane pods such as `istiod-*` are in the `istio-system` namespace. In addition, Knative adds the `istio-webhook-*` pod in the `knative-serving` namespace when Istio is the chosen networking layer.

The `network-config` ConfigMap specifies the controller to be used in the ingress controller key. This key is patched with the name of the new controller when you configure a new one. See [Changing the ingress controller](#change-the-controller) for important information about using this key.

## Network layer options

Review the following tabs to determine the optimal networking layer for your cluster. Knative installs the Kourier controller as the default ingress. For most users, the Kourier ingress controller is sufficient in conjunction the default Istio gateway that is also included in the Knative Serving installation. You can expand your capabilities with the Contour ingress, a full-feature service mesh with Istio, and the Kubernetes Gateway API.

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

    The Knative `net-kourier` ingress is installed with Knative Serving. Kourier is a lightweight alternative for the Istio ingress as its deployment consists only of an Envoy proxy and a control plane. If Kourier is satisfactory, no further configurations are required.

    *Install and configure*

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
    *Install and configure*

    The Knative `net-contour` controller enables Contour to satisfy the networking needs by bridging Knative's KIngress resources to Contour's HTTPProxy resources. A good choice for clusters that already run non-Knative apps, want to reuse a single Ingress controller, and for teams who are already using Contour envoy but don't need a full-feature service mesh.

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

    The Knative `net-istio` defines a KIngress controller for Istio. It's a full-feature service mesh integrated with Knative that also functions as a Knative ingress. Good for enterprises already running Istio or needing advanced service mesh features.

    *Install and configure*

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

    Knative has a default Istio integration without the full-feature service mesh. The `knative-ingress-gateway` in the `knative-serving` namespace is a shared Istio gateway resource that handles all incoming (north-south) traffic to Knative services. This gateway points to the underlying `istio-ingressgateway` service in the `istio-system` namespace. You can replace this gateway with one of your own, see [Configuring the Ingress gateway](setting-up-custom-ingress-gateway.md).


=== "Gateway API"

    ```mermaid
    ---
    config:
      layout: elk
      theme: default
    ---
    flowchart LR
     subgraph net-gateway-api["net-gateway-api&nbsp;controller"]
            GW["Gateway"]
            Route["Knative&nbsp;Route"]
            HR["HTTPRoute"]
      end
     subgraph underlying["Underlying&nbsp;Controller<br>(Contour │ Istio │ Envoy Gateway │ …)"]
        Controller["GatewayClass&nbsp;Controller"]
      end
        KSvc["Knative&nbsp;Service"] --> Route
        Route -- translates&nbsp;to --> GW & HR
        GW --> Controller
        HR --> Controller
        Controller -- routes&nbsp;traffic&nbsp;to --> Pods["Your&nbsp;Pods"]

    style net-gateway-api fill:#e3f2fd,stroke:#1976d2
    style underlying fill:#fff3e0,stroke:#ef6c00
    ```

    The Knative `net-gateway-api` is a KIngress implementation and testing for Knative integration with the [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/). Good for teams adopting the Gateway API to unify ingress across Kubernetes.

    The Kubernetes Gateway API requires a controller or service mesh. Istio and Contour implementations are tested though other Gateway API implementations should work. Currently, there is no native Gateway API support for Kourier. For more information see [Tested Gateway API version and Ingress](https://github.com/knative-extensions/net-gateway-api/blob/main/docs/test-version.md).

    The controller that Knative uses is determined by which Gateway API-compatible controller you install and configure in your cluster. 

    *Configure*

    --8<-- "netadapter-gatewayapi.md"

## Configure DNS

--8<-- "dns.md"
--8<-- "real-dns-yaml.md"
--8<-- "no-dns.md"

## Changing the ingress controller
