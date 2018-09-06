# gRPC Ping

A simple gRPC server written in Go that you can use for testing.

This sample is dependent on [this issue](https://github.com/knative/serving/issues/1047) to be complete.

## Prerequisites

1. [Install Knative](https://github.com/knative/docs/blob/master/install/README.md)
1. Install [docker](https://www.docker.com/)

## Build and run the gRPC server

Build and run the gRPC server. This command will build the server and use `kubectl` to apply the configuration.

1. Build and push the image:
   ```
   REPO="gcr.io/<your-project-here>"

   # Build and publish the container, run from the root directory.
   docker build \
     --tag "${REPO}/serving/samples/grpc-ping-go" \
     --file=serving/samples/grpc-ping-go/Dockerfile .
   docker push "${REPO}/serving/samples/grpc-ping-go"
   ```
2. Replace the image references in `serving/samples/grpc-ping-go/sample.yaml`
   with our published image:
   * Manually replace:

     `image: github.com/knative/docs/serving/samples/grpc-ping-go` with `image: <YOUR_CONTAINER_REGISTRY>/serving/samples/grpc-ping-go`

    Or

   * Run this command:
     ```
     perl -pi -e "s@github.com/knative/docs@${REPO}@g" serving/samples/grpc-ping-go/sample.yaml
     ```

3. Deploy the Knative sample
   ```
   kubectl apply -f serving/samples/grpc-ping-go/sample.yaml
   ```

## Use the client to stream messages to the gRPC server

1. Fetch the created ingress hostname and IP.

```
# Put the Host name into an environment variable.
export SERVICE_HOST=`kubectl get route grpc-ping -o jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

1. Use the client to send message streams to the gRPC server

```
go run -tags=grpcping ./serving/samples/grpc-ping-go/client/client.go -server_addr="$SERVICE_IP:80" -server_host_override="$SERVICE_HOST"
```
