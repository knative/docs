Use the following steps to install and enable Contour and set it as the ingress conroller.

1. Install the Knative Contour controller:

    ```bash
    kubectl apply -f https://github.com/knative/net-kourier/releases/latest/download/kourier.yaml
    ```

1. Configure Knative Serving to use Contour:

  ```bash
    kubectl patch configmap/config-network \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"ingress-class":"contour.ingress.networking.knative.dev"}}'
  ```

1. Verify the installation by having a pod with the base name of `contour` in the results.

    ```bash
    kubectl get pods -n knative-serving
    ```

1. Get the external IP address (FQDN) to configure DNS records:

    ```bash
    kubectl --namespace contour-external get service envoy
    ```
