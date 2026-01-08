<!-- Referenced by:
- install/yaml-install/serving/install-serving-with-yaml.md
-->
=== "Contour"

    Use the following steps to install and enable Contour and set it as the ingress controller.
    
    1. Install the Knative Contour configuration:
    
        ```bash
        kubectl apply -f {{ artifact(repo="net-contour",org="knative-extensions",file="contour.yaml")}}
        ```
    
    1. Install the Knative Contour integration controller:
    
        ```bash
        kubectl apply -f {{ artifact(repo="net-contour",org="knative-extensions",file="net-contour.yaml")}}
        ```
    
    1. Configure Knative Serving to use Contour:
    
        ```bash
            kubectl patch configmap/config-network \
            --namespace knative-serving \
            --type merge \
            --patch '{"data":{"ingress-class":"contour.ingress.networking.knative.dev"}}'
        ```
    
    1. Get the external IP address (FQDN) to later configure DNS:
    
        ```bash
        kubectl --namespace contour-external get service envoy
        ```
    <!-- Must end with tab -->