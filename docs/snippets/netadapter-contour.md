Use the following steps to install and enable Contour and enable its Knative integration.

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

1. Get the external IP address (FQDN) to configure DNS records:

    ```bash
    kubectl --namespace contour-external get service envoy
    ```
