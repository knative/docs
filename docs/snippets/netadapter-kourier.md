<!-- Snippet used in the following topics:
- versioned/install/yaml-install/serving/install-serving-with-yaml.md
- versioned/functions/deploying-functions.md
-->    
  The following commands install Kourier and enable its Knative integration.

    1. Install the Knative Kourier controller by running the command:
    ```bash
    kubectl apply -f {{ artifact(repo="net-kourier",org="knative-extensions",file="kourier.yaml")}}
    ```

    1. Configure Knative Serving to use Kourier by default by running the command:
      ```bash
      kubectl patch configmap/config-network \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
      ```
