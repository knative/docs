---
title: "gRPC server - Go"
#linkTitle: ""
weight: 1
type: "docs"
---

A simple gRPC server written in Go that you can use for testing.

## Prerequisites

- [Install the latest version of Knative Serving](../../../install/README.md).

- Install [docker](https://www.docker.com/).

- Download a copy of the code:

  ```shell
  git clone -b "release-0.7" https://github.com/knative/docs knative-docs
  ```

## Build and run the gRPC server

First, build and publish the gRPC server to DockerHub (replacing `{username}`):

```shell
# Build and publish the container, run from the root directory.
docker build \
  --tag "docker.io/{username}/grpc-ping-go" \
  --file=docs/serving/samples/grpc-ping-go/Dockerfile .
docker push "docker.io/{username}/grpc-ping-go"
```

Next, replace `{username}` in `sample.yaml` with your DockerHub username, and
apply the yaml.

```shell
$EDITOR docs/serving/samples/grpc-ping-go/sample.yaml
kubectl apply --filename docs/serving/samples/grpc-ping-go/sample.yaml
```

## Use the client to stream messages to the gRPC server

1. Fetch the created ingress hostname and IP.

   ```shell
   # Put the ingress IP into an environment variable.
   export SERVICE_IP=`kubectl get svc istio-ingressgateway --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
   ```

1. Use the client to send message streams to the gRPC server (replacing
   `{username}`)

   ```shell
   docker run -ti --entrypoint=/client docker.io/{username}/grpc-ping-go \
     -server_addr="${SERVICE_IP}:80" \
     -server_host_override="grpc-ping.default.example.com" \
     -insecure
   ```
