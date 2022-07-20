# Deploying a Knative Service

In this tutorial, you will deploy a "Hello world" Knative Service that accepts the environment variable `TARGET` and prints `Hello ${TARGET}!`.

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
