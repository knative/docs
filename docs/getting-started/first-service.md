# Getting Started with Knative Serving

**In this tutorial, we are going to use [KonK](konk.dev) to deploy a "Hello world" Service!**

This service will accept an environment variable, `TARGET`, and print "`Hello $TARGET`", since our "Hello world" Service is being deployed as a Knative Service, it gets some super powers (scale-to-zero, traffic-splitting) out of the box :rocket:.

## Deploying a your first Knative Service: "Hello world!"
=== "kn"

    ``` bash
    kn service create hello \
    --image gcr.io/knative-samples/helloworld-go \
    --port 8080 \
    --env TARGET=world
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
                  value: "world"
    ```

#### Expected Output
After Knative has successfully created your service, you should see the following:
```
Service 'hello' created to latest revision '{REVISION_NAME}' is available at URL:
{SERVICE_URL}
```
#### Testing your deployment

```
curl $SERVICE_URL
```

**The output should be:**
```
Hello world!
```

## Up Next
Congratulations, you've just created your first Knative Service! :tada: Next, we'll take a look at Autoscaling, click "Next" 
