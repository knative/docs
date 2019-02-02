
A simple gRPC server written in Go that you can use for testing.

This sample requires knative/serving 0.4 or later.

## Prerequisites

1. [Install Knative](https://github.com/knative/docs/blob/master/install/)
1. Install [docker](https://www.docker.com/)

## Build and run the gRPC server

First, build and publish the gRPC server to DockerHub (replacing `{username}`):

```shell
# Build and publish the container, run from the root directory.
docker build \
  --tag "docker.io/{username}/grpc-ping-go" \
  --file=serving/samples/grpc-ping-go/Dockerfile .
docker push "docker.io/{username}/grpc-ping-go"
```

Next, replace `{username}` in `sample.yaml` with your DockerHub username, and
apply the yaml.

```shell
kubectl apply --filename serving/samples/grpc-ping-go/sample.yaml
```

## Use the client to stream messages to the gRPC server

1. Fetch the created ingress hostname and IP.

```shell
# Put the Host name into an environment variable.
export SERVICE_HOST=`kubectl get route grpc-ping --output jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
export SERVICE_IP=`kubectl get svc istio-ingressgateway --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

1. Use the client to send message streams to the gRPC server (replacing
   `{username}`)

```shell
docker run -ti --entrypoint=/client docker.io/{username}/grpc-ping-go \
  -server_addr="${SERVICE_IP}:80" \
  -server_host_override="${SERVICE_HOST}" \
  -insecure
```
