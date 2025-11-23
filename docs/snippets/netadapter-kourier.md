Use the following stesp to install Kourier and enable its Knative integration.

1. Install the Knative Kourier controller:

    ```bash
    kubectl apply -f {{ artifact(repo="net-kourier",org="knative-extensions",file="kourier.yaml")}}
    ```

1. Configure Knative Serving to use Kourier by default:

    ```bash
    kubectl patch configmap/config-network \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
    ```

1. Get the external IP address (FQDN) to configure DNS records:

    ```bash
    kubectl --namespace kourier-system get service kourier
    ```
