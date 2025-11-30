Use the following steps to install the Knative Gateway API controller.

1. Configure Knative Serving to use `net-gateway-api` controller:

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
