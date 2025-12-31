Use the following steps to install and configure the Knative Gateway API adapter.  Note that you need to have a [Gateway API implementation](https://gateway-api.sigs.k8s.io/implementations/) installed in your cluster.  The Knative team currently tests the Istio, Contour, and Envoy-Gateway implementations of Gateway API.

1. Clone the Gateway API repo:

    ```bash
    git clone https://github.com/knative-extensions/net-gateway-api.git
    cd net-gateway-api
    ```

1. Set environment variables:

    ```bash
    export KO_DOCKER_REPO=kind.local
    export KIND_CLUSTER_NAME=knative  # (keep this if your cluster is named "knative")
    ```

1. Deploy Gateway API resources:

    ```bash
    ko apply -f config/
    ```

1. Install the Knative Gateway API:

    ```bash
      kubectl apply -f {{ artifact(repo="net-gateway-api",org="knative-extensions",file="net-gateway-api.yaml") }}
    ```

1. Configure Knative Serving to use Knative Gateway API channel:

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
