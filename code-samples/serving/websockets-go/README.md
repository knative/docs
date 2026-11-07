# WebSocket - Go

A simple [WebSocket](https://datatracker.ietf.org/doc/html/rfc6455) server that performs the HTTP upgrade and prints log messages on all standardized WebSocket events, such as `open`, `message`, `close` and `error`. The server is written in Golang and uses the [Gorilla WebSocket](https://github.com/gorilla/websocket) library.


## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [ko](https://github.com/ko-build/ko) or [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## The sample code

The server listens on port `8080` at `/ws`; it does not read environment variables.
Knative reserves the `PORT` environment variable, so do not set it explicitly in
the Service manifest.
It echoes text and binary messages and accepts connections from any origin. This
permissive origin policy is for demonstration only; restrict allowed origins before
using this sample in production.

1. In [`cmd/server/main.go`](cmd/server/main.go), `main` registers
   `handleWebSocket` at `/ws` and starts the HTTP server on port `8080`.
2. In the same file, `handleWebSocket` upgrades the HTTP connection, calls
   `OnOpen`, and reads messages in a goroutine. Each message is passed to
   `OnMessage`; read errors invoke `OnError`, and the deferred `OnClose` closes
   the connection.
3. [`pkg/handlers/handlers.go`](pkg/handlers/handlers.go) contains the callbacks.
   They log connection events and echo each message with its original text or
   binary message type.

## Build the application

Run the build and deployment commands from `code-samples/serving/websockets-go`.

 ### Dockerfile

 * If you look in the [Dockerfile](Dockerfile), you will see a method for building the Go container. You can build and push this to your registry of choice via:
```bash
# Build and push the container on your local machine.
docker buildx build --platform linux/arm64,linux/amd64 -t "<image>" --push .
```

 ### ko

 * You can use `ko` to build and push just the image with:
```bash
ko publish ./cmd/server
```
 However, if you use `ko` for the next step, this is not necessary.

## Deploy the application

 ### yaml (with Dockerfile)
 * If you look in [`config/service.yaml`](config/service.yaml), take the `<image>` name you used earlier and insert it into the `image:` field, then run:
```bash
kubectl apply -f config/service.yaml
```

 ### yaml (with ko)
 * If using `ko` to build and push:
```bash
ko apply -f config/service.yaml
```

## Testing the WebSocket server

Get the URL for your Service with:

   ```bash
   kubectl get ksvc websockets-server
   ```

For example, the Service URL might be
`http://websockets-server.default.svc.cluster.local` (the domain depends on your
cluster configuration). Change `http://` to `ws://` (`https://` to `wss://` for TLS)
and append `/ws` to connect to the URL reported by your cluster.

Alternatively, run a container inside the cluster with the
[wscat](https://github.com/websockets/wscat) CLI and use the Service's cluster-local
address:


   ```bash
   kubectl run --rm -i --tty wscat --image=monotykamary/wscat --restart=Never -- -c ws://websockets-server.default.svc.cluster.local/ws
   ```

Afterward you can chat with the WebSocket server like:

   ```text
   If you don't see a command prompt, try pressing enter.
   Connected (press CTRL+C to quit)
   > Hello
   < Hello
   >
   ```

Knative can scale the application based on concurrent connections. The number of
pods depends on autoscaling settings and traffic, not just the number of clients.

> **NOTE:** The [`autoscaling.knative.dev/target`](https://knative.dev/docs/serving/autoscaling/autoscaling-targets/)
> annotation controls the target concurrency used for scaling.
