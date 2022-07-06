# TLS with HTTP01

Knative supports automatically provisioning TLS certificates using Encrypt HTTP01 challenges. The following commands install the components needed to support TLS.

1. Install the net-http01 controller by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="net-http01",file="release.yaml")}}
    ```

2. Configure the `certificate-class` to use this certificate type by running the command:

    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"certificate-class":"net-http01.certificate.networking.knative.dev"}}'
    ```

3. Enable autoTLS by running the command:

    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"auto-tls":"Enabled"}}'
    ```
