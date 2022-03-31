# Deploying your first Knative Service

**In this tutorial, you will deploy a "Hello world" service.**

Since our "Hello world" Service is being deployed as a Knative Service, not a Kubernetes Service, it gets some **super powers out of the box** :rocket:.

## Knative Service: "Hello world!"

First, deploy the Knative Service. This service accepts the environment variable,
`TARGET`, and prints `Hello ${TARGET}!`.

=== "kn"

    Deploy the Service by running the command:

    ```bash
    kn service create hello \
    --image gcr.io/knative-samples/helloworld-go \
    --port 8080 \
    --env TARGET=World
    ```
    !!! Success "Expected output"
        ```{ .bash .no-copy }
        Service hello created to latest revision 'hello-world' is available at URL:
        http://hello.default.${LOADBALANCER_IP}.sslip.io
        ```
        The value of `${LOADBALANCER_IP}` above depends on your type of cluster,
        for `kind` it will be `127.0.0.1` for `minikube` depends on the local tunnel.

=== "YAML"
    1. Copy the following YAML into a file named `hello.yaml`:

        ```yaml
        apiVersion: serving.knative.dev/v1
        kind: Service
        metadata:
          name: hello
        spec:
          template:
            spec:
              containers:
                - image: gcr.io/knative-samples/helloworld-go
                  ports:
                    - containerPort: 8080
                  env:
                    - name: TARGET
                      value: "World"
        ```
    1. Deploy the Knative Service by running the command:

        ```bash
        kubectl apply -f hello.yaml
        ```
        !!! Success "Expected output"
            ```{ .bash .no-copy }
            service.serving.knative.dev/hello created
            ```

## List your Knative Service

To see the URL where your Knative Service is hosted, leverage the `kn` CLI:

=== "kn"
    View a list of Knative services by running the command:
    ```bash
    kn service list
    ```
    !!! Success "Expected output"
        ```bash
        NAME    URL                                                LATEST        AGE   CONDITIONS   READY
        hello   http://hello.default.${LOADBALANCER_IP}.sslip.io   hello-00001   13s   3 OK / 3     True
        ```
=== "kubectl"
    View a list of Knative services by running the command:
    ```bash
    kubectl get ksvc
    ```
    !!! Success "Expected output"
        ```bash
        NAME    URL                                                LATESTCREATED   LATESTREADY   READY   REASON
        hello   http://hello.default.${LOADBALANCER_IP}.sslip.io   hello-00001     hello-00001   True
        ```

## Access your Knative Service

Access your Knative Service by opening the previous URL in your browser or by running the command:

```bash
echo "Accessing URL $(kn service describe hello -o url)"
curl "$(kn service describe hello -o url)"
```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    Hello World!
    ```

??? question "Are you seeing `curl: (6) Could not resolve host: hello.default.${LOADBALANCER_IP}.sslip.io`?"

    In some cases your DNS server may be set up not to resolve `*.sslip.io` addresses. If you encounter this problem, it can be fixed by using a different nameserver to resolve these addresses.

    The exact steps will differ according to your distribution. For example, with Ubuntu derived systems which use `systemd-resolved`, you can add the following entry to the `/etc/systemd/resolved.conf`:

    ```ini
    [Resolve]
    DNS=8.8.8.8
    Domains=~sslip.io.
    ```

    Then simply restart the service with `sudo service systemd-resolved restart`.

    For MacOS users, you can add the DNS and domain using the network settings as explained [here](https://support.apple.com/en-gb/guide/mac-help/mh14127/mac).

Congratulations :tada:, you've just created your first Knative Service. Up next, Autoscaling!
