Use the following steps to install and configure the Knative Gateway API.

1. Install the Knative Gateway API channel:

    ```bash
      kubectl apply -f {{ artifact(repo="net-gateway-api",org="knative-extensions",file="net-gateawy-api.yaml") }}
    ```

1. Configure Knative Serving to use Knative Gateway API channel:

    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"gateway-api.ingress.networking.knative.dev"}}'
    ```

1. Get the external IP address (FQDN) to configure DNS records:

    ```bash
    kubectl get gateway --all-namespaces
    ```
