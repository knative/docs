# Basics of Traffic Splitting
The last super power :rocket: of Knative Serving we'll go over in this tutorial is **traffic splitting**.

??? question "What are some common traffic splitting use-cases?"
    Splitting traffic is useful for a number of very common modern infrastructure needs, such as
    **[blue/green deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html){target=blank_}
    and
    [canary deployments](https://martinfowler.com/bliki/CanaryRelease.html){target=blank_}.**
    Bringing these industry standards to bear on Kubernetes is **as simple as a single CLI command on Knative** or YAML tweak, let's see how!


## Creating a new Revision

A new Revision gets created each and every time you make changes to the configuration of your Knative Service. When splitting traffic, Knative splits traffic between different Revisions of your Knative Service.

??? question "What exactly is a Revision?"
    You can think of a [Revision](../serving/README.md#serving-resources){target=_blank} snapshot-in-time of application code and configuration.

### Create a new Revision

Instead of `TARGET=World` update the environment variable `TARGET` on your Knative Service `hello` to greet "Knative" instead.

=== "kn"

    Deploy the updated version of your Knative Service by running the command:
    ``` bash
    kn service update hello \
    --env TARGET=Knative
    ```

    As before, `kn` prints out some helpful information to the CLI.
    !!! Success "Expected output"
        ```{ .bash .no-copy }
        Service 'hello' created to latest revision 'hello-00002' is available at URL:
        http://hello.default.${LOADBALANCER_IP}.sslip.io
        ```

=== "YAML"
    1. Edit your existing `hello.yaml` file to contain the following:
        ``` bash
        ---
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
                      value: "Knative"
        ```
    1. Deploy the updated version of your Knative Service by running the command:
        ``` bash
        kubectl apply -f hello.yaml
        ```

        !!! Success "Expected output"
            ```{ .bash .no-copy }
            service.serving.knative.dev/hello configured
            ```


Note that since we are updating an existing Knative Service `hello`, the URL doesn't change, but our new Revision should have the new name `hello-00002`.

### Access the new Revision

To see the change, access the Knative Service again on your browser or use `curl` in your terminal:
```bash
echo "Accessing URL $(kn service describe hello -o url)"
curl "$(kn service describe hello -o url)"
```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    Hello Knative!
    ```

## Splitting Traffic

You may at this point be wondering, "where did 'Hello World!' go?" Remember, Revisions are an immutable snapshot-in-time of application code and configuration, so your old `hello-00001` Revision is still available to you.

### List your Revisions

We can easily see a list of our existing Revisions with the `kn` or `kubectl` CLI.

=== "kn"
    View a list of revisions by running the command:
    ```bash
    kn revisions list
    ```
    !!! Success "Expected output"
        ```{ .bash .no-copy }
        NAME            SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
        hello-00002     hello     100%             2            30s   3 OK / 4     True
        hello-00001     hello                      1            5m    3 OK / 4     True
        ```

=== "kubectl"
    View a list of Revisions by running the command:
    ```bash
    kubectl get revisions
    ```
    !!! Success "Expected output"
        ```{ .bash .no-copy }
        NAME          CONFIG NAME   K8S SERVICE NAME   GENERATION   READY   REASON   ACTUAL REPLICAS   DESIRED REPLICAS
        hello-00001   hello                            1            True             0                 0
        hello-00002   hello                            2            True             0                 0
        ```


When running the `kn` command, the column most relevant for our purposes is `TRAFFIC`. We can see that 100% of traffic is going to our latest Revision, `hello-00002`, which is on the row with the highest `GENERATION`.
0% of traffic is going to the Revision we configured earlier, `hello-00001`.

When you create a new Revision of a Knative Service, Knative defaults to directing 100% of traffic to this latest Revision. **We can change this default behavior by specifying how much traffic we want each of our Revisions to receive.**

### Split traffic between Revisions

Lets split traffic between our two Revisions:

=== "kn"
    Run the command:
    ```bash
    kn service update hello \
    --traffic hello-00001=50 \
    --traffic @latest=50
    ```

=== "YAML"
    1. Add the `traffic` section to the bottom of your existing `hello.yaml` file:
        ``` bash
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
                      value: "Knative"
          traffic:
          - latestRevision: true
            percent: 50
          - latestRevision: false
            percent: 50
            revisionName: hello-00001
        ```
    1. Apply the YAML by running the command:
        ``` bash
        kubectl apply -f hello.yaml
        ```

!!! info
    `@latest` will always point to our "latest" Revision which, at the moment, is `hello-00002`.

### Verify the traffic split

To verify that the traffic split has configured correctly, list the revisions again by running the command:
```bash
kn revisions list
```
!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME            SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
    hello-00002     hello     50%              2            10m   3 OK / 4     True
    hello-00001     hello     50%              1            36m   3 OK / 4     True
    ```


Access your Knative Service multiple times in your browser to see the different output being served by each Revision.

Similarly, you can access the Service URL from the terminal multiple times to see the traffic being split between the Revisions.
```bash
echo "Accessing URL $(kn service describe hello -o url)"
curl "$(kn service describe hello -o url)"
```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    Hello Knative!
    Hello World!
    Hello Knative!
    Hello World!
    ```
