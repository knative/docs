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


=== "Real DNS"

    To configure DNS for Knative, take the External IP
    or CNAME from setting up networking, and configure it with your DNS provider as
    follows:

    - If the networking layer produced an External IP address, then configure a
      wildcard `A` record for the domain:

      ```
      # Here knative.example.com is the domain suffix for your cluster
      *.knative.example.com == A 35.233.41.212
      ```

    - If the networking layer produced a CNAME, then configure a CNAME record for the domain:

      ```
      # Here knative.example.com is the domain suffix for your cluster
      *.knative.example.com == CNAME a317a278525d111e89f272a164fd35fb-1510370581.eu-central-1.elb.amazonaws.com
      ```

    Once your DNS provider has been configured, add the following section into your existing Serving CR, and apply it:

    ```yaml
    # Replace knative.example.com with your domain suffix
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      config:
        domain:
          "knative.example.com": ""
      ...
    ```

=== "Temporary DNS"

    If you are using `curl` to access the sample applications, or your own Knative app, and are unable to use the "Magic DNS (sslip.io)" or "Real DNS" methods, there is a temporary approach. This is useful for those who wish to evaluate Knative without altering their DNS configuration, as per the "Real DNS" method, or cannot use the "Magic DNS" method due to using,
    for example, minikube locally or IPv6 clusters.

    To access your application using `curl` using this method:

    1. After starting your application, get the URL of your application:
      ```bash
      kubectl get ksvc
      ```
      The output should be similar to:
      ```bash
      NAME            URL                                        LATESTCREATED         LATESTREADY           READY   REASON
      helloworld-go   http://helloworld-go.default.example.com   helloworld-go-vqjlf   helloworld-go-vqjlf   True
      ```

    1. Instruct `curl` to connect to the External IP or CNAME defined by the
      networking layer in section 3 above, and use the `-H "Host:"` command-line
      option to specify the Knative application's host name.

      For example, if the networking layer defines your External IP and port to be `http://192.168.39.228:32198` and you wish to access the above `helloworld-go` application, use:

      ```bash
      curl -H "Host: helloworld-go.default.example.com" http://192.168.39.228:32198
      ```
      In the case of the provided `helloworld-go` sample application, using the default configuration, the output is:

      ```
      Hello Go Sample v1!
      ```

    Refer to the "Real DNS" method for a permanent solution.
