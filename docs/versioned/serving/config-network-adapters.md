---
audience: administrator
components:
  - serving
function: how-to
---

# Configure Knative networking

This page provides installation and configuration guidance for Knative networking. You can configure Ingress controls, service-meshes, and gateways.

## Network layer options

Review the following tabs to determine the optimal networking layer for your cluster. For most users, the Kourier ingress controller is sufficient. You can expand your capabilities with the Contour ingress, a full-feature service mesh with Istio, and the Kubernetes Gateway API.

The Knative `networking.internal.knative.dev` Ingress type is generally referred to as KIngress objects.

=== "Kourier"

    The following diagram depicts the flow of KIngress objects, as read by Knative serving.

    ```mermaid
    ---
    config:
      layout: elk
      theme: default
    ---
    flowchart LR
      subgraph top[" "]
        direction LR
            kingress1["Ingress object (KIngress)<br>networking.internal.knative.dev"]
            serving["Serving<br>controller"]
            route["Route object"]
      end
        route -- read by --> serving
        serving -- creates --> kingress1
        style kingress1 fill:#BBDEFB,stroke-width:1px,stroke-dasharray: 0
        style serving fill:#FFE0B2
        style top fill:transparent
    ```


    ```mermaid
    ---
    config:
      layout: elk
      theme: default
    ---
    flowchart LR
     subgraph bottom[" "]
        direction LR
            envoy["Envoy deployment<br>kourier-system namespace"]
            kourier["net-kourier<br>controller"]
            kingress2["KIngress class:<br>kourier.ingress.networking.knative.dev"]
      end
        kingress2 -- read by --> kourier
        kourier -- programs --> envoy
    
        style envoy fill:#BBDEFB
        style kourier fill:#FFE0B2
        style bottom fill:transparent
    ```

    Kourier is a lightweight alternative for the Istio ingress as its deployment consists only of an envoy proxy and a control plane. If Kourier is satisfactory, no further configurations are required.

    Kourier is a fine choice for all platforms, but for IBM-Z and IBM-P platforms it's the only supported option and requires additional steps as documented in [Install Serving with YAML on IBM-Z and IBM-P](../install/yaml-install/serving/install-serving-with-yaml-on-IBM-Z-and-IBM-P.md).

=== "Contour"

    ```mermaid
    ---
    config:
      theme: default
      layout: elk
      look: neo
    ---
    flowchart LR
    C1["Knative<br>net-contour"] -- creates --> C2["KIngress&nbsp;objects"]
    C2 --> C3["Class: contour.ingress.networking.knative.dev"]
    ```

    The Contour ingress controller, `net-contour`, bridges Knative's KIngress resources to Contour's HTTPProxy resources. A good choice for clusters that already run non-Knative apps, teams who want to use a single Ingress controller, and are already using Contour envoy but don't need a full-feature service mesh.

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

    The Knative `net-istio` is a KIngress controller for Istio. It's a full-feature service mesh that also functions as a Knative ingress. Good for enterprises already running Istio or needing advanced service mesh features.

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

    Knative has a default Istio integration without the full-feature service mesh. The `knative-ingress-gateway` in the `knative-serving` namespace is a shared Istio gateway resource that handles all incoming (north-south) traffic to Knative services. This gateway points to the underlying `istio-ingressgateway` service in the `istio-system` namespace. You can replace this gateway with one of your own.


    See [Configuring the Ingress gateway](setting-up-custom-ingress-gateway.md).

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

## Determine current state

Use the following command to determine which ingress controllers are installed and their status.

    ``` bash
    kubectl get pods -n knative-serving
    ```

The Knative team tests the following ingress controllers:

- Kourier: `kourier-control-*`, and `kourier-gateway-*`. Kourier is included in the Knative Serving installation should appear in the results when your cluster is first created.
- Contour: `contour-*`
- Istio: `istio-webhook-*`. The main Istio control plane pods such as `istiod-*` are in the `istio-system` namespace. Knative adds the `istio-webhook-*` pod in the `knative-serving` namespace when Istio is the chosen networking layer.

Each ingress controller manages only those ingress objects that are annotated with its key. Knative Serving uses a default value of the key based on the `network-config` ConfigMap. See [Changing the ingress controller](#change-the-controller) for important information about using this key.

## Changing the controller

If you want to change the controller, install and configure the new controller as instructed in the [Network layer options](#network-layer-options). There is no requirement to remove ingress controllers that are not in use.

You can determine the controller in use by examining the `config-network.yaml`:

    ```bash
    kubectl get cm config-network -n knative-serving -o yaml
    ```

Look for the `ingress-class` key. It could also be the `ingress.class` key with a dot. The dash usage is more current and supersedes any key with the dot. In the following example, the `ingress.class` key was initially set for the Kourier controller, but is now set to Contour because the ingress key with a dash takes precedence.

    ```yml
    ingress-class: contour.ingress.networking.knative.dev
    ingress.class: kourier.ingress.networking.knative.dev
    ```

If you want to switch back to a previously installed controller, patch the `config-network` ConfigMap with the new controller. In the following example Kourier is used because of the dash in `ingress-class`.

    ```bash
    kubectl patch cm config-network -n knative-serving \
      --type merge -p '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
    ```

You can remove an unused key with a dot with the following command:

    ```bash
    kubectl patch configmap config-network -n knative-serving \                                                    
    --type=json -p='[{"op": "remove", "path": "/data/ingress.class"}]'
    ```
