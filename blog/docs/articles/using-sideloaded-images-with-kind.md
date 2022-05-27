---
title: Using Sideloaded Images with Kind
linkTitle: Using-Sideloaded -Images-with-Kind
author: "Ed Jung"
date: 2022-04-30
description: How to use sideloaded images with Knative on Kind
type: "blog"
---

Once you've setup a kind Knative cluster with the [`quickstart` plugin](https://github.com/knative-sandbox/kn-plugin-quickstart), you may want to try it with images from your developer environment, without an image registry.  The Knative tag-to-digest resolution needs to be disabled to make this possible.


This document walks through these steps:

* sideloading an image into kind
* disabling tag resolution
* creating a Knative service that uses the sideloaded image

## Pre-Requisities

It's assumed that you already have a kind cluster with Knative installed.

This tutorial assumes you have cluster running as from [Getting Started with Knative](https://knative.dev/docs/getting-started/),
 and will sideload the helloworld-go image, but you may substitute your own image.


## Sideload Your Image into the Cluster

1. Pull the hello-world-go image into you local dev environment.

  ```
  docker pull gcr.io/knative-samples/helloworld-go
  ```

2. Rename this image for demonstration purposes. Renaming it will make clear that the image is not being
pulled from the public registry.

  ```
docker tag gcr.io/knative-samples/helloworld-go my.example.com/helloworld-go
  ```

3. Load the image into the cluster using `kind`

  ```
kind load docker-image --name knative my.example.com/helloworld-go
  ```

4. [Optional] Check that it exists in the cluster.

  ```
docker exec -it knative-control-plane crictl images | grep helloworld
  ```

## Disable Tag-to-Digest Resolution

1. Get a local copy of the Knative configmap yaml that controls deployment.

  ```
kubectl -n knative-serving get -o yaml configmap config-deployment > config-deployment.yaml
  ```

2. Open this configmap file and add the config for `registries-skipping-tag-resolving`:

  ```
apiVersion: v1
data:
  registries-skipping-tag-resolving: "my.example.com"
...

  ```

3. Save the file and apply it to the kind cluster

  ```
kubectl apply -f config-deployment.yaml
  ```

  New services will now skip tag-to-digest resolution if their image name starts with `my.example.com` and
allow your sideloaded image to be used.

  **Note**: This will not affect existing services because they have already
passed through the tag resolution stage. You will need to create a new revision of those services.


# Create your Knative Service Resource

1. Create the service, either using the `kn` CLI or `kubectl`, with an image pull policy of `Never` or `IfNotPresent`

When using `kn`,
  ```
kn service create my.example.com/helloworld-go --pull-policy never

  ```

If you prefer kubectl, then apply a `service.yaml` with the contents below.

  ```
apiVersion: serving.knative.dev/v1 # Current version of Knative
kind: Service
metadata:
  name: helloworld # The name of the app
  namespace: default # The namespace the app will use
spec:
  template:
    spec:
      containers:
        - image: my.example.com/helloworld-go
          imagePullPolicy: Never
          env:
            - name: TARGET
              value: "there!"
  ```


3. Check the service to make sure it is ready.

  ```
kubectl get ksvc
  ```

