Use the following steps to install Istio and set it as the ingress conroller.

1. Install a properly configured Istio:

    ```bash
    kubectl apply -l knative.dev/crd-install=true -f {{ artifact(repo="net-istio",org="knative-extensions",file="istio.yaml") }}
    kubectl apply -f {{ artifact(repo="net-istio",org="knative-extensions",file="istio.yaml") }}
    ```

    <!-- ```bash
    kubectl apply -l knative.dev/crd-install=true -f https://github.com/knative-extensions/net-istio/releases/download/knative-v1.20.1/istio.yaml
    kubectl apply -f https://github.com/knative-extensions/net-istio/releases/download/knative-v1.20.1/istio.yaml
    ``` -->

1. Install the Knative Istio controller:

    ```bash
    kubectl apply -f {{ artifact(repo="net-istio",file="net-istio.yaml") }}
    ```

    <!-- ```bash
    kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.20.1/net-istio.yaml
    ``` -->

1. Configure the `config-network` ConfigMap to use Istio:

    ```bash
      kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"istio.ingress.networking.knative.dev"}}'
    ```

1. Verify the installation by having pods with the base name of `istio` and `istio-webhook` in the results.

    ```bash
    kubectl get pods -n knative-serving
    ```

1. Get the external IP address (FQDN) to configure DNS records:

    ```bash
    kubectl --namespace istio-system get service istio-ingressgateway
    ```