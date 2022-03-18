## Deploying your first Knative Service

**In this tutorial, you will deploy a ["Hello world"](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-go) service.**

This service will accept an environment variable, `TARGET`, and print `"Hello ${TARGET}!."`

Since our "Hello world" Service is being deployed as a Knative Service, not a Kubernetes Service, it gets some super powers out of the box 🚀.

## Knative Service: "Hello world!"

```sh
kn service create hello \
--image gcr.io/knative-samples/helloworld-go \
--port 8080 \
--env TARGET=World \
--revision-name=world
```{{execute}}


> **Why did I pass in revision-name?**
> Note the name "world" which you passed in as "revision-name," naming your Revisions will help you to more easily identify them, but don't worry, you'll learn more about Revisions later.

**Expected output:**
`Service hello created to latest revision 'hello-world' is available at URL:
http://hello.default.example.com`

## Ping your Knative Service
Run this command:
`curl -H "Host: hello.default.example.com" $externalIP`{{execute}}

**Expected output:**
`Hello World!`

Congratulations 🎉, you've just created your first Knative Service. Up next, Autoscaling!
