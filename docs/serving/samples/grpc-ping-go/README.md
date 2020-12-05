A [gRPC](https://grpc.io) server written in Go.

This sample can be used to try out gRPC, HTTP/2, and custom port configuration
in a knative service.

The container image is built with two binaries: the server and the client.
This is done for ease of testing and is not a recommended practice
for production containers.

## Prerequisites

- [Install the latest version of Knative Serving](../../../install/README.md).

- Install [docker](https://www.docker.com/).

- A [Docker Hub account](https://hub.docker.com) to which you can upload the sample's container image.

## Build and Deploy the sample code

1. Download a copy of the code:

  ```shell
  git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
  cd knative-docs/docs/serving/samples/grpc-ping-go
  ```

2. Use Docker to build a container image for this service and push to Docker Hub.

  Replace `{username}` with your Docker Hub username then run the commands:

  ```shell
  # Build the container on your local machine.
  docker build --tag "{username}/grpc-ping-go" .

  # Push the container to docker registry.
  docker push "{username}/grpc-ping-go"
  ```

3. Update the `service.yaml` file in the project to reference the published image from step 1.

   Replace `{username}` in `service.yaml` with your Docker Hub user name:
   
   
  ```yaml
  apiVersion: serving.knative.dev/v1
  kind: Service
  metadata:
    name: grpc-ping
    namespace: default
  spec:
    template:
      spec:
        containers:
        - image: docker.io/{username}/grpc-ping-go
          ports:
            - name: h2c
              containerPort: 8080
  ``` 

4. Use `kubectl` to deploy the service.

  ```shell
  kubectl apply --filename service.yaml
  ```

  Response:

  ```shell
  service "grpc-ping" created
  ```

## Exploring

Once deployed, you can inspect the created resources with `kubectl` commands:

```shell
# This will show the Knative service that we created:
kubectl get ksvc --output yaml

# This will show the Route, created by the service:
kubectl get route --output yaml

# This will show the Configuration, created by the service:
kubectl get configurations --output yaml

# This will show the Revision, created by the Configuration:
kubectl get revisions --output yaml
```

## Testing the service

Testing the gRPC service requires using a gRPC client built from the same
protobuf definition used by the server.

The Dockerfile builds the client binary. To run the client you will use the
same container image deployed for the server with an override to the
entrypoint command to use the client binary instead of the server binary.

Replace `{username}` with your Docker Hub user name and run the command:

```shell
docker run --rm {username}/grpc-ping-go \
  /client \
  -server_addr="grpc-ping.default.1.2.3.4.xip.io:80" \
  -insecure
```

The arguments after the container tag `{username}/grpc-ping-go` are used
instead of the entrypoint command defined in the Dockerfile `CMD` statement.
  
