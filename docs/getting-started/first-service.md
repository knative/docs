# Getting Started with Knative Serving

**In this tutorial, we are going to use [KonK](konk.dev) to deploy a "Hello world" Service!**This service will accept an environment variable, `TARGET`, and print "`Hello $TARGET`."

For those of you familiar with other **source-to-url** tools, this may seem familiar. However, since our "Hello world" Service is being deployed as a Knative Service, it gets some **super powers (scale-to-zero, traffic-splitting) out of the box** :rocket:.

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
    Once you've created your YAML file (named something like "hello.yaml"):
    ``` bash
    kubectl apply -f hello.yaml
    ```

#### Expected Output
After Knative has successfully created your service, you should see the following:
```bash
Service hello created to latest revision {REVISION_NAME} is available at URL:
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

Congratulations :tada:, you've just created your first Knative Service!

!!! tip
    Hit "n"++ / "."++ on your keyboard to move forward in the tutorial. Use "p"++ / ","++ to go back at any time.
