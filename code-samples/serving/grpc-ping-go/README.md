# gRPC Server - Go

A [gRPC](https://grpc.io) server written in Go.

This sample can be used to try out gRPC, HTTP/2, and custom port configuration
in a Knative Service. The server listens on `PORT` (default `8080`) and uses
plaintext HTTP/2 (h2c). Knative sets `PORT` from the configured `containerPort`;
keep the port name `h2c` when choosing a custom port.

The container image is built with two binaries: the server and the client.
This is done for ease of testing and is not a recommended practice
for production containers.

## Prerequisites

- Install the latest version of Knative Serving. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).

- Install [docker](https://www.docker.com/).

- A [Docker Hub account](https://hub.docker.com) to which you can upload the sample's container image.

## Build and Deploy the sample code

1. Download a copy of the code:

  ```bash
  git clone https://github.com/knative/docs.git knative-docs
  cd knative-docs/code-samples/serving/grpc-ping-go
  ```

2. Use Docker to build a container image for this service and push to Docker Hub.

  Replace `{username}` with your Docker Hub username then run the commands:

  ```bash
  # Build and push the container on your local machine.
  docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/grpc-ping-go" --push .
  ```

3. Update the checked-in [service.yaml](service.yaml) to reference the published
   image from step 2 by replacing `{username}` with your Docker Hub user name.
   Keep its `h2c` port name so Knative forwards plaintext HTTP/2 to the server.

4. Use `kubectl` to deploy the service.

  ```bash
  kubectl apply --filename service.yaml
  ```

  Response:

  ```bash
  service "grpc-ping" created
  ```

## Exploring

Once deployed, you can inspect the created resources with `kubectl` commands:

```bash
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

Get the service URL with `kubectl get ksvc grpc-ping -o jsonpath='{.status.url}'`.
Replace the example hostname below with that URL's hostname and `{username}`
with your Docker Hub user name. For an HTTP endpoint, use port `80` and
`-insecure` (plaintext HTTP/2, not disabled certificate verification). For an
HTTPS endpoint, use port `443` and omit `-insecure` to enable TLS with certificate
verification.

```bash
docker run --rm {username}/grpc-ping-go \
  /client \
  -server_addr="grpc-ping.default.1.2.3.4.sslip.io:80" \
  -insecure
```

The arguments after the container tag `{username}/grpc-ping-go` are used
instead of the default command defined in the Dockerfile `CMD` statement.

A successful run logs `Ping got hello - pong`, followed by 20 `Got pong ...`
responses from the bidirectional streaming RPC.

### Local build

No cluster or registry push is needed for a local smoke test:

```bash
docker build -t grpc-ping-go:local .
docker run -d --name grpc-ping-local grpc-ping-go:local
docker run --rm --network container:grpc-ping-local grpc-ping-go:local /client -insecure
docker rm -f grpc-ping-local
```

To test a custom port locally, add `-e PORT=8081` to the server's `docker run`
command and `-server_addr=127.0.0.1:8081` to the client command.
For a Knative deployment, set `containerPort: 8081` in `service.yaml` instead;
Knative supplies `PORT` automatically.

The source files use the `grpcping` build tag, which the Dockerfile supplies.
