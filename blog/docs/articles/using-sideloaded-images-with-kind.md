---
title: Using Sideloaded Images with Kind
linkTitle: Using-Sideloaded -Images-with-Kind
author: "Ed Jung"
date: 2022-05-26
description: How to use sideloaded images with Knative on Kind
type: "blog"
---

Once you've setup a kind Knative cluster with the [`quickstart` plugin](https://github.com/knative-sandbox/kn-plugin-quickstart), you may want to try it with images from your developer environment, without an image registry.

This document walks through these steps:

* sideloading an image into kind
* creating a Knative service that uses the sideloaded image

## Pre-Requisities

This tutorial assumes you have cluster running as from [Getting Started with Knative](https://knative.dev/docs/getting-started/),
 and will sideload the helloworld-go image, but you may substitute your own image.


## Sideload Your Image into the Cluster

1. Pull the hello-world-go image into you local dev environment.

  ```
  docker pull gcr.io/knative-samples/helloworld-go
  ```

2. Rename this image using a host name of `dev.local`, `kind.local`, or `ko.local`. Knative will skip tag resolution for these special names by default.

  ```
docker tag gcr.io/knative-samples/helloworld-go dev.local/helloworld-go
  ```

  (*Note: To use other host names in your images, you will need to manually configure Knative to skip resolution for those names. See* [`registries-skipping-tag-resolving`](https://knative.dev/docs/serving/configuration/deployment/#skipping-tag-resolution))


3. Sideload the image into the cluster using `kind`

  ```
kind load docker-image --name knative dev.local/helloworld-go
  ```

4. [Optional] Check that it exists in the cluster.

  ```
docker exec -it knative-control-plane crictl images | grep helloworld
  ```

# Create the Knative Service

1. Create the service with an image pull policy of `Never` or `IfNotPresent`


  ```
kn service create dev.local/helloworld-go --pull-policy Never --env TARGET=world

  ```



3. Check the service to make sure it's ready.

  ```
kubectl get ksvc
  ```

