## Configure DNS

You can configure DNS to prevent the need to run curl commands with a host header.

The tabs below expand to show instructions for configuring DNS.
Follow the procedure for the DNS of your choice:

=== "Magic DNS (sslip.io)"

    Knative provides a Kubernetes Job called `default-domain` that configures Knative Serving to use <a href="http://sslip.io">sslip.io</a> as the default DNS suffix.

    ```bash
    kubectl apply -f {{artifact(repo="serving",file="serving-default-domain.yaml")}}
    ```

    !!! warning
        This will only work if the cluster `LoadBalancer` Service exposes an
        IPv4 address or hostname, so it will not work with IPv6 clusters or local setups
        like minikube unless [`minikube tunnel`](https://minikube.sigs.k8s.io/docs/commands/tunnel/)
        is running.

        In these cases, see the "Real DNS" or "Temporary DNS" tabs.
