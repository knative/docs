<!-- Referenced by:
- install/operator/knative-with-operators.md
- install/yaml-install/serving/install-serving-with-yaml.md
-->
You can configure DNS to avoid specifying the host header in curl commands, or to access the content with a web browser.

The following tabs show instructions for configuring DNS. Follow the procedure for the DNS of your choice:

=== "Magic DNS (sslip.io)"

    Knative provides a Kubernetes Job called `default-domain` that configures Knative Serving to use [sslip.io](http://sslip.io) as the default DNS suffix.

    ```bash
    kubectl apply -f {{artifact(repo="serving",file="serving-default-domain.yaml")}}
    ```

    This configuration works only if the cluster `LoadBalancer` Service exposes an IPv4 address or hostname. It does not work with IPv6 clusters or local setups such as minikube unless the [`minikube tunnel`](https://minikube.sigs.k8s.io/docs/commands/tunnel/) is running.

