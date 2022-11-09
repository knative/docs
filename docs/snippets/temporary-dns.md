=== "Temporary DNS"

    If you are using `curl` to access the sample applications, or your own Knative app, and are unable to use the "Magic DNS (sslip.io)" or "Real DNS" methods, there is a temporary approach. This is useful for those who wish to evaluate Knative without altering their DNS configuration, as per the "Real DNS" method, or cannot use the "Magic DNS" method due to using,
    for example, minikube locally or IPv6 clusters.

    To access your application using `curl` using this method:

    1. Configure Knative to use a domain reachable from outside the cluster:
      ```bash
      kubectl patch configmap/config-domain \
            --namespace knative-serving \
            --type merge \
            --patch '{"data":{"example.com":""}}'
      ```

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
       networking layer mentioned in section 3, and use the `-H "Host:"` command-line
       option to specify the Knative application's host name.
       For example, if the networking layer defines your External IP and port to be `http://192.168.39.228:32198` and you wish to access the `helloworld-go` application mentioned earlier, use:
       ```bash
       curl -H "Host: helloworld-go.default.example.com" http://192.168.39.228:32198
       ```
       In the case of the provided `helloworld-go` sample application, using the default configuration, the output is:
       ```
       Hello Go Sample v1!
       ```
       Refer to the "Real DNS" method for a permanent solution.
