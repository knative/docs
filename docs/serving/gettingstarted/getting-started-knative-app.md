---
title: "Getting Started with App Deployment"
linkTitle: "Getting started"
weight: 01
type: "docs"
aliases:
  - /docs/install/getting-started-knative-app/
---

This guide shows you how to deploy an app using Knative, then interact with it
using cURL requests.

## Before you begin

You need:

- A Kubernetes cluster with [Knative installed](../install/README.md).
- An image of the app that you'd like to deploy available on a container
  registry. The image of the sample app used in this guide is available on
  Google Container Registry.

## Sample application

This guide demonstrates the basic workflow for deploying the
[Hello World sample app (Go)](../serving/samples/hello-world/helloworld-go) from the 
[Google Container Registry](https://cloud.google.com/container-registry/docs/pushing-and-pulling).
You can use these steps as a guide for deploying your own container images from other
registries like [Docker Hub](https://docs.docker.com/docker-hub/repos/).

To deploy a local container image, you need to disable image tag resolution by running the following command:

```bash
# Set to dev.local/local-image when deploying local container images
docker tag local-image dev.local/local-image
```

[Learn more about image tag resolution.](./tag-resolution.md)

The Hello World sample app reads in an `env` variable, `TARGET`, from the
configuration `.yaml` file, then prints "Hello World: \${TARGET}!". If `TARGET`
isn't defined, it will print "NOT SPECIFIED".

## Configuring your deployment

To deploy an app using Knative, you need a configuration `.yaml` file that
defines a Service. For more information about the Service object, see the
[Resource Types documentation](https://github.com/knative/serving/blob/master/docs/spec/overview.md#service).

This configuration file specifies metadata about the application, points to the
hosted image of the app for deployment, and allows the deployment to be
configured. For more information about what configuration options are available,
see the
[Serving spec documentation](https://github.com/knative/serving/blob/master/docs/spec/spec.md).

Create a new file named `service.yaml`, then copy and paste the following
content into it:

```yaml
apiVersion: serving.knative.dev/v1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-samples/helloworld-go # The URL to the image of the app
          env:
            - name: TARGET # The environment variable printed out by the sample app
              value: "Go Sample v1"
```

If you want to deploy the sample app, leave the config file as-is. If you're
deploying an image of your own app, update the name of the app and the URL of
the image accordingly.

## Deploying your app

From the directory where the new `service.yaml` file was created, apply the
configuration:

```bash
kubectl apply --filename service.yaml
```

Now that your service is created, Knative will perform the following steps:

- Create a new immutable revision for this version of the app.
- Perform network programming to create a route, ingress, service, and load
  balancer for your app.
- Automatically scale your pods up and down based on traffic, including to zero
  active pods.

### Interacting with your app

To see if your app has been deployed successfully, you need the URL created by Knative.

1. To find the URL for your service, enter:

   ```shell
   kubectl get ksvc helloworld-go
   ```

   The command will return the following:

   ```shell
   NAME            URL                                                LATESTCREATED         LATESTREADY           READY   REASON
   helloworld-go   http://helloworld-go.default.34.83.80.117.xip.io   helloworld-go-96dtk   helloworld-go-96dtk   True
   ```

   > Note: If your URL includes `example.com` then consult the setup instructions for
   > configuring DNS (e.g. with `xip.io`), or [using a Custom Domain](../serving/using-a-custom-domain.md).

   If you changed the name from `helloworld-go` to something else when creating
   the `.yaml` file, replace `helloworld-go` in the above commands with the name
   you entered.

1. Now you can make a request to your app and see the results. Replace
   the URL with the one returned by the command in the previous step.

   ```shell
   # curl http://helloworld-go.default.34.83.80.117.xip.io
   Hello World: Go Sample v1!
   ```

   If you deployed your own app, you might want to customize this cURL request
   to interact with your application.

   It can take a few seconds for Knative to scale up your application and return
   a response.

   > Note: Add `-v` option to get more detail if the `curl` command failed.

You've successfully deployed your first application using Knative!

## Cleaning up

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```

Alternatively, delete the service by name:

```shell
kubectl delete kservice helloworld-go
```
