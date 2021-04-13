# Basics of Traffic Splitting
The last super power :rocket: of Knative Serving we'll go over is traffic splitting.

Splitting traffic is useful for a number of very common modern infrastructure needs, such as <a href= "https://martinfowler.com/bliki/BlueGreenDeployment.html" target="blank_">blue/green deployments</a> and <a href="https://martinfowler.com/bliki/CanaryRelease.html" target="blank_">canary deployments</a>. Bringing these industry standards to bear on Kubernetes is **as simple as a single CLI command on Knative** or YAML tweak, let's see how!

## What are revisions?
Knative Serving splits traffic between different `Revisions` of a Knative Service. You can think of a `Revision` as a stateless, autoscaling snapshot-in-time of application code and configuration. A new `Revision` will get created each and every time you make changes to your Knative Service.

You may have noticed that when your Knative Service was created, Knative returned both a URL and a 'latest revision' for your Service. But what happens if we make a change to our service?


## Creating a new Revision
Instead of "world," let's have our Knative Service "hello" greet "Knative." You can accomplish this by using the `kn` CLI or by editing the YAML file you made earlier.

=== "kn"

    ``` bash
    kn service update hello --env TARGET=Knative
    ```

=== "YAML"

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
    ```
    Once you've edited your existing YAML file:
    ``` bash
    kubectl apply -f hello.yaml
    ```

As before, Knative spits out some helpful information to the CLI:
```bash
Service hello created to latest revision <revision-name> is available at URL:
<service-url>
```

Notice, since we are updating an existing Knative Service, the URL doesn't change, but your `Revision` should have incremented by one (something like "hello-xxxxx-2").

Let's ping our Knative Service again to see the change:
```
curl <service-url>
```

**The output should be:**
```
Hello Knative!
```

## Splitting Traffic between Revisions
Remember when I said that a `Revision` was a "stateless, autoscaling snapshot-in-time of application code and configuration?" You may at this point be wondering, "where did 'Hello world!' go?"

We can easily see a list of our existing revisions with the `kn` CLI:


=== "kn"

    ```bash
    kn get revisions
    ```

=== "kubectl"
     Though the following example doesn't cover it, you can peak under the hood to Kubernetes to see the revisions as Kubernetes sees them.  
    ```bash
    kubectl get revisions
    ```

    **The output should be:**
```bash
NAME            SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-xxxxx-2   hello     100%             2            10m   3 OK / 4     True    
hello-xxxxx-1   hello                      1            17h   3 OK / 4     True    
```

The column most relevant for our purposes is "TRAFFIC". It looks like 100% of traffic is going to our latest `Revision` (hello-xxxxx-2) "Hello Knative!" and 0% of traffic is going to the `Revision` we configured first (hello-xxxxx-1), "Hello world!"

By default, when Knative creates a brand new Service it directs 100% of traffic to `@latest`, and updates the pointer `@latest` with the most recent `Revision` when we make a change to our Service. **We can change this default behavior by using specifying how much traffic we want each of our `Revisions` to receive.**

=== "kn"

    ```bash
    kn service update hello \
    --traffic hello-xxxxx-1=50 \
    --traffic hello-xxxxx-2=50
    ```
    or (these commands do the same thing for our purposes)
    ```bash
    kn service update hello \
    --traffic hello-xxxxx-1=50 \
    --traffic @latest=50
    ```
    `@latest` will always point to our "latest" `Revision` which, at the moment, is `hello-xxxxx-2`.

=== "YAML"

    ``` bash
    apiVersion: serving.knative.dev/v1
    kind: Route
    metadata:
      name: route-hello
    spec:
      traffic:
      - revisionName: hello-xxxxx-1
      - percent: 50
      - revisionName: hello-xxxxx-2
        percent: 50
    ```
    Once you've edited your existing YAML file:
    ``` bash
    kubectl apply -f hello.yaml
    ```

Now when we curl our Knative Service URL...
```bash
[...] curl <service-url>
Hello Knative!
[...] curl <service-url>
Hello world!
```

Congratulations, :tada: you've successfully split traffic between 2 different `Revisions`. Up next, Knative Eventing!
