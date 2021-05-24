# Deploying your first Knative Service
!!! tip
    Hit ++"n"++ / ++"."++ on your keyboard to move forward in the tutorial. Use ++"p"++ / ++","++ to go back at any time.

==**In this tutorial, we are going to deploy a "Hello world" Service!**==
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

=== "YAML"

    ``` bash
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: hello
    spec:
      template:
        metadata:
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

After Knative has successfully created your service, you should see the following:
```{ .bash .no-copy }
Service hello created to latest revision 'hello-world' is available at URL:
http://hello.default.127.0.0.1.nip.io
```

??? question "Why did I pass in `revision-name`?"
    Note that the name "world" which you passed in as "revision-name" is being used to create the `Revision`'s name (`latest revision "hello-world"...`). This will help you to more easily identify this particular `Revision`, but don't worry, we'll talk more about `Revisions` later.

## Run your Knative Service
```
curl http://hello.default.127.0.0.1.nip.io
```

==**Expected output:**==
```{ .bash .no-copy }
Hello World!
```

Congratulations :tada:, you've just created your first Knative Service!
