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

   Replace `{username}` in `service.yaml` with your DockerHub username:
   
   
  ```yaml
  apiVersion: serving.knative.dev/v1alpha1
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

Testing the gRPC service uses the gRPC client built into the container.

1. Fetch the created ingress hostname and IP.

   ```shell
   # Put the ingress IP into an environment variable.
   export SERVICE_IP=$(kubectl get svc istio-ingressgateway --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*].ip}")
   ```

1. Use the containerized client to send message streams to the gRPC server (replacing
   `{username}`):

   ```shell
   docker run --rm -it {username}/grpc-ping-go \
     /client \
     -server_addr="${SERVICE_IP}:80" \
     -server_host_override="grpc-ping.default.example.com" \
     -insecure
   ```

  The arguments after the container tag `{username}/grpc-ping-go` replace the container's default entrypoint which starts the server with a command that starts the gRPC client.
  