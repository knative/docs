The following commands install Contour and enable its Knative integration.

1. Install a properly configured Contour by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="net-contour",org="knative-extensions",file="contour.yaml")}}
    ```
    <!-- TODO(https://github.com/knative-extensions/net-contour/issues/11): We need a guide on how to use/modify a pre-existing install. -->

1. Install the Knative Contour controller by running the command:
  ```bash
  kubectl apply -f {{ artifact(repo="net-contour",org="knative-extensions",file="net-contour.yaml")}}
  ```

1. Configure Knative Serving to use Contour by default by running the command:
  ```bash
  kubectl patch configmap/config-network \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"ingress-class":"contour.ingress.networking.knative.dev"}}'
  ```

