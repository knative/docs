<!-- Referenced by:
- install/yaml-install/serving/install-serving-with-yaml.md
-->
This component is in beta. For the latest information including supported implementations, see the [Knative net-gateway-api](https://github.com/knative-extensions/net-gateway-api).

Use the following steps to install and configure the Knative Gateway API controller.  Note that you need to have a [Gateway API implementation](https://gateway-api.sigs.k8s.io/implementations/) installed in your cluster.  The Knative team currently tests the Istio, Contour, and Envoy-Gateway implementations of Gateway API.

1. Install the Knative Gateway API:

    ```bash
    kubectl apply -f {{ artifact(repo="net-gateway-api",org="knative-extensions",file="net-gateway-api.yaml") }}
    ```

    <!-- TODO: Alternatively, you can use `contour-gateway.yaml` or `istio-gateway.yaml`.  -->

1. Configure Gateway resources for external ("north-south") and local ("east-west") Knative traffic. If you do not need separate routing for local traffic (or [private Knative services](../../../serving/services/private-services.md)), you can use the external Gateway for both.

    Knative verifies traffic settings according to the Kubernetes namespace, the name of the Gateways, and an underlying DNS name such as a Kubernetes service DNS name that corresponds to the Gateway.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-gateway
      namespace: knative-serving
    data:
      external-gateways: |
        - name: knative-ingress-gateway  # Name of the external Gateway resource
          namespace: knative-serving     # Namespace where the Gateway is deployed
          service: knative-ingress-service.knative-serving.svc.cluster.local  # backing Service FQDN
      local-gateways: |
        - name: knative-local-gateway    # Name of the local Gateway resource
          namespace: knative-serving     # Namespace where the Gateway is deployed
          service: knative-local-service.knative-serving.svc.cluster.local    # backing Service FQDN
    EOF
    ```

1. Configure Knative Serving to use the Knative Gateway API ingress class:

    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"gateway-api.ingress.networking.knative.dev"}}'
    ```

1. Verify the `config-gateway` ConfigMap:

    ```bash
    kubectl describe configmaps config-gateway -n knative-serving
    ```

    Examine the values for the `externals-gateways` and `local-gateways` keys.

1. Get the external IP address (FQDN) to configure DNS records:

    ```bash
    kubectl get gateway --all-namespaces
    ```

    Look for the external Gateway (`knative-ingress-gateway`) to get status and address for DNS configurations.
