Use the following steps to install Istio and enable its Knative integration.

1. Install a properly configured Istio:

    ```bash
    kubectl apply -l knative.dev/crd-install=true -f {{ artifact(repo="net-istio",org="knative-extensions",file="istio.yaml")}}
    kubectl apply -f {{ artifact(repo="net-istio",org="knative-extensions",file="istio.yaml")}}
    ```

1. Install the Knative Istio controller:

    ```bash
    kubectl apply -f {{ artifact(repo="net-istio",file="net-istio.yaml")}}
    ```

1. Verify the installation by having pods with the base name of `istio` and `istio-webhook` in the results.

    ```bash
    kubectl get pods -n knative-serving
    ```

1. Get the external IP address (FQDN) to configure DNS records:

    ```bash
    kubectl --namespace istio-system get service istio-ingressgateway
    ```