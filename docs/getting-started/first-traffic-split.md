# Basics of Traffic Splitting
The last super power :rocket: of Knative Serving we'll go over in this tutorial is traffic splitting.

??? question "What are some common traffic splitting use-cases?"
    Splitting traffic is useful for a number of very common modern infrastructure needs, such as **<a href= "https://martinfowler.com/bliki/BlueGreenDeployment.html" target="blank_">blue/green deployments</a> and <a href="https://martinfowler.com/bliki/CanaryRelease.html" target="blank_">canary deployments</a>.** Bringing these industry standards to bear on Kubernetes is **as simple as a single CLI command on Knative** or YAML tweak, let's see how!


## Creating a new Revision
You may have noticed that when you created your Knative Service you assigned it a `revision-name`, "world". When your Service was created, Knative returned both a URL and a 'latest revision' name for your Knative Service. **But what happens if you make a change to your Service?**

??? question "What exactly is a `Revision`?""
    You can think of a <a href="../../serving/#serving-resources" target ="blank_">`Revision` </a> as a stateless, autoscaling snapshot-in-time of application code and configuration.

    A new `Revision` will get created each and every time you make changes to your Knative Service, whether you assign it a name or not. When splitting traffic, Knative splits traffic between different `Revisions` of your Knative Service.

Instead of "world," let's have our Knative Service "hello" greet "Knative."
=== "kn"

    ``` bash
    kn service update hello \
    --env TARGET=Knative \
    --revision-name=knative
    ```

=== "YAML"

    ``` bash
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: hello
    spec:
      template:
        metadata:
          name: knative
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
              ports:
                - containerPort: 8080
              env:
                - name: TARGET
                  value: "Knative"
    ```
    Once you've edited your existing YAML file:
    ``` bash
    kubectl apply -f hello.yaml
    ```

As before, Knative spits out some helpful information to the CLI:
```{ .bash .no-copy }
Service hello created to latest revision 'hello-knative' is available at URL:
http://hello.default.127.0.0.1.nip.io
```

Note, since we are updating an existing Knative Service, the URL doesn't change, but your new `Revision` should have the new name "hello-knative"

Let's ping our Knative Service again to see the change:
```
curl http://hello.default.127.0.0.1.nip.io
```

### Expected Output
```{ .bash .no-copy }
Hello Knative!
```

## Splitting Traffic between Revisions
You may at this point be wondering, "where did 'Hello world!' go?" `Revisions` are a stateless snapshot-in-time of application code and configuration so your "hello-world" `Revision` is still available to you.

We can easily see a list of our existing revisions with the `kn` CLI:


=== "kn"

    ```bash
    kn revisions list
    ```

=== "kubectl"
     Though the following example doesn't cover it, you can peak under the hood to Kubernetes to see the revisions as Kubernetes sees them.  
    ```bash
    kubectl get revisions
    ```

### Expected Output
```{ .bash .no-copy }
NAME            SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-knative   hello     100%             2            30s   3 OK / 4     True    
hello-world     hello                      1            5m    3 OK / 4     True    
```

The column most relevant for our purposes is "TRAFFIC". It looks like 100% of traffic is going to our latest `Revision` ("hello-knative") and 0% of traffic is going to the `Revision` we configured earlier ("hello-world")

By default, when Knative creates a brand new `Revision` it directs 100% of traffic to the latest `Revision` of your service. **We can change this default behavior by specifying how much traffic we want each of our `Revisions` to receive.**

!!! info inline end
    `@latest` will always point to our "latest" `Revision` which, at the moment, is `hello-knative`.
=== "kn"

    ```bash
    kn service update hello \
    --traffic @latest=50 \
    --traffic hello-world=50
    ```

=== "YAML"

    ``` bash
    apiVersion: serving.knative.dev/v1
    kind: Route
    metadata:
      name: route-hello
    spec:
      traffic:
      - revisionName: @latest
      - percent: 50
      - revisionName: hello-world
        percent: 50
    ```
    Once you've edited your existing YAML file:
    ``` bash
    kubectl apply -f hello.yaml
    ```

### Expected Output
Now when we curl our Knative Service URL...
```{ .bash .no-copy }
curl http://hello.default.127.0.0.1.nip.io
Hello Knative!

curl http://hello.default.127.0.0.1.nip.io
Hello World!
```

Congratulations, :tada: you've successfully split traffic between 2 different `Revisions`. Up next, Knative Eventing!
