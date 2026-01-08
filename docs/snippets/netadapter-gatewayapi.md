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

1. Configure Knative Serving to use the Knative Gateway API ingress class:

    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"gateway-api.ingress.networking.knative.dev"}}'
    ```

1. Edit the `config-gateway` ConfigMap in the knative-serving namespace to specify gateway resources for external and local traffic. For the `external-gateways` key, specify the value for `name` and for `service` as needed. Do the same for the `local gateways`. The `namespace` should be kept at `knative-serving`.

    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-gateway
      namespace: knative-serving
      labels:
        app.kubernetes.io/component: net-gateway-api
        app.kubernetes.io/name: knative-serving
    data:
      external-gateways: |
        - name: knative-ingress-gateway  # Name of the external Gateway resource
          namespace: knative-serving     # Namespace where the Gateway is deployed
          service: knative-ingress-service.knative-serving.svc.cluster.local  # backing Service FQDN
      local-gateways: |
        - name: knative-local-gateway    # Name of the local Gateway resource
          namespace: knative-serving     # Namespace where the Gateway is deployed
          service: knative-local-service.knative-serving.svc.cluster.local    # backing Service FQDN
    EOF
    ```

1. Verify the `config-gateway` ConfigMap:

    ```bash
    kubectl get configmap config-gateway -n knative-serving -o yaml
    ```

1. Get the external IP address (FQDN) to configure DNS records:

    ```bash
    kubectl get gateway --all-namespaces
    ```

    Look for the external Gateway (`knative-ingress-gateway`) to get status and address for DNS configuration.
