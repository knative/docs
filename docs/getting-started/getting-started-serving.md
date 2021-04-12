# Getting Started w/ Knative Serving

In this tutorial, we are going to use KonK to deploy a "Hello World" Service! This service will accept an environment variable, `TARGET`, and print "Hello $TARGET"

Since our "Hello World" Service is being deployed as a Knative Service, it gets some super powers out of the box :rocket: (which we'll talk about later).

## Deploying a "Hello World" Service
=== "kn"

    ``` bash
    kn service create hello \
    --image gcr.io/knative-samples/helloworld-go \
    --port 8080 \
    --env TARGET=Knative
    ```

=== "YAML"

    ``` bash
    kubectl apply -f -
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

### Testing our deployment
```
curl $SERVICE_URL
```

!!! tip
    Where `$SERVICE_URL` is the URL that got returned to you after you created your service

The output should be:
```
Hello Knative!
```

## Updating our deployment

=== "kn"

    ``` bash
    kn service update hello-example \
    --env TARGET=Serving
    ```

=== "YAML"

    ``` bash
    kubectl apply -f -
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
                  value: "Serving"
    ```

### Re-testing our deployment
```bash
curl $SERVICE_URL
```

The output should be:
``` bash
Hello Serving!
```


## Autoscaling in action

Check the Knative pods that scaled from zero
```
kubectl get pod -l serving.knative.dev/service=hello
```

The output should be:
```
NAME                                     READY   STATUS    RESTARTS   AGE
hello-r4vz7-deployment-c5d4b88f7-ks95l   2/2     Running   0          7s
```

Try the service `url` on your browser (command works on Linux and macOS)
``` bash
open $SERVICE_URL
```

You can watch the pods and see how they scale down to zero after http traffic stops to the url
```
kubectl get pod -l serving.knative.dev/service=hello -w
```

The output should look like this:
```
NAME                                     READY   STATUS
hello-r4vz7-deployment-c5d4b88f7-ks95l   2/2     Running
hello-r4vz7-deployment-c5d4b88f7-ks95l   2/2     Terminating
hello-r4vz7-deployment-c5d4b88f7-ks95l   1/2     Terminating
hello-r4vz7-deployment-c5d4b88f7-ks95l   0/2     Terminating
```

Try to access the url again, and you will see a new pod running again.
```
NAME                                     READY   STATUS
hello-r4vz7-deployment-c5d4b88f7-rr8cd   0/2     Pending
hello-r4vz7-deployment-c5d4b88f7-rr8cd   0/2     ContainerCreating
hello-r4vz7-deployment-c5d4b88f7-rr8cd   1/2     Running
hello-r4vz7-deployment-c5d4b88f7-rr8cd   2/2     Running
```

Some people call this **Serverless** 🎉 🌮 🔥
