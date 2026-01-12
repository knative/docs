<!-- Referenced by:
- install/yaml-install/serving/install-serving-with-yaml.md
-->
Use the following steps to install Istio and set it as the ingress controller.
    
1. Install a properly configured Istio:

    ```bash
    kubectl apply -l knative.dev/crd-install=true -f {{ artifact(repo="net-istio",org="knative-extensions",file="istio.yaml") }}
    kubectl apply -f {{ artifact(repo="net-istio",org="knative-extensions",file="istio.yaml") }}
    ```

1. Install the Knative Istio controller:

    ```bash
    kubectl apply -f {{ artifact(repo="net-istio",org="knative-extensions", file="net-istio.yaml") }}
    ```

1. Configure the `config-network` ConfigMap to use Istio:

    ```bash
        kubectl patch configmap/config-network \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"ingress-class":"istio.ingress.networking.knative.dev"}}'
    ```

1. Get the external IP address (FQDN) to later configure DNS:

    ```bash
    kubectl --namespace istio-system get service istio-ingressgateway
    ```
