# Deploying your first Knative Service
!!! tip
    Hit ++"."++ on your keyboard to move forward in the tutorial. Use ++","++ to go back at any time.

==**In this tutorial, you will deploy a "Hello world" service.**==
This service will accept an environment variable, `TARGET`, and print "`Hello ${TARGET}!`."

For those of you familiar with other **source-to-url** tools, this may seem familiar. However, since our "Hello world" Service is being deployed as a Knative Service, it gets some **super powers (scale-to-zero, traffic-splitting) out of the box** :rocket:.

## Knative Service: "Hello world!"
=== "kn"

    ``` bash
    kn service create hello \
    --image gcr.io/knative-samples/helloworld-go \
    --port 8080 \
    --env TARGET=World \
    --revision-name=world
    ```

    ??? question "Why did I pass in `revision-name`?"
        Note the name "world" which you passed in as "revision-name," naming your `Revisions` will help you to more easily identify them, but don't worry, you'll learn more about `Revisions` later.

=== "YAML"

    ``` bash
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: hello
    spec:
      template:
        metadata:
          # This is the name of our new "Revision," it must follow the convention {service-name}-{revision-name}
          name: hello-world
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
              ports:
                - containerPort: 8080
              env:
                - name: TARGET
                  value: "World"
    ```
    Once you've created your YAML file (named something like "hello.yaml"):
    ``` bash
    kubectl apply -f hello.yaml
    ```
    ??? question "Why did I pass in the second name, `hello-world`?"
        Note the name "hello-world" which you passed in under "metadata" in your YAML file. Naming your `Revisions` will help you to more easily identify them, but don't worry if this if a bit confusing now, you'll learn more about `Revisions` later.



==**Expected output:**==
```{ .bash .no-copy }
Service hello created to latest revision 'hello-world' is available at URL:
http://hello.default.127.0.0.1.nip.io
```

## Run your Knative Service
```
curl http://hello.default.127.0.0.1.nip.io
```

==**Expected output:**==
```{ .bash .no-copy }
Hello World!
```

Congratulations :tada:, you've just created your first Knative Service!
