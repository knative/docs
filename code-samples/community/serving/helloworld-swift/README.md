# Hello World - Swift

A small HTTP app built with [Swift 6.4.1](https://www.swift.org/install/) and
[Hummingbird 2.28.0](https://github.com/hummingbird-project/hummingbird/releases/tag/2.28.0).
It returns an HTML page containing "Hello ${TARGET}". `TARGET` defaults to
`World`; an explicitly empty `TARGET` produces an empty name. `PORT` defaults to
`8080` and must be an integer from 1 through 65535. The server binds to
`0.0.0.0`, so Knative can reach it.

GET and POST `/` return `Content-Type: text/html` and this exact response when
`TARGET=Swift`:

```html
<html><meta charset="UTF-8"><body>Hello Swift</body></html>
```

## Prerequisites

- A Kubernetes cluster with Knative Serving and DNS configured. See the
  [Knative installation instructions](https://knative.dev/docs/install/).
- Docker and a container registry account for publishing your image.

The official `swift:6.4.1-noble` builder and `swift:6.4.1-noble-slim` runtime
images support both `linux/arm64` and `linux/amd64`. They use Ubuntu 24.04 LTS.
The runtime image contains the matching Swift runtime without the compiler;
the application runs as an unprivileged numeric user. Use a platform matching
your cluster nodes, or publish both architectures with buildx.

## Using the sample code

Clone the repository and work in `code-samples/community/serving/helloworld-swift`.

- [Package.swift](Package.swift) declares the executable and HTTP dependency. [Package.resolved](Package.resolved) locks dependency revisions.
- [Greeting.swift](Sources/HelloSwift/Greeting.swift) reads and validates the
  environment and constructs the HTML response.
- [main.swift](Sources/HelloSwift/main.swift) registers GET/POST routes and
  starts Hummingbird on `0.0.0.0` with the configured port.
- [Dockerfile](Dockerfile) builds the app and its unprivileged runtime image.
- [service.yaml](service.yaml) deploys the application with `TARGET=Swift`.
  Replace its `{username}` image placeholder before deploying.

## Testing locally

Build the final runtime image with the locked Swift toolchain:

```bash
docker build -t helloworld-swift .
docker run --rm -p 127.0.0.1:8080:8080 -e TARGET=Swift helloworld-swift
```

In another terminal:

```bash
curl http://127.0.0.1:8080/
# <html><meta charset="UTF-8"><body>Hello Swift</body></html>
```

To exercise a custom port, use `-e PORT=9090 -p 127.0.0.1:9090:9090`. Omit
`TARGET` to get `Hello World`; use `-e TARGET=` to test an empty name. Invalid
`PORT` values cause startup to fail instead of silently listening elsewhere.
Missing paths return HTTP 404 using Hummingbird's default error response.

## Building and deploying the sample

1. Build and push for your cluster's architecture. For a registry image that
   supports both native platforms, use:

   ```bash
   docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-swift" --push .
   ```

1. Ensure `service.yaml` references the image you published, then deploy:

   ```bash
   kubectl apply --filename service.yaml
   kubectl wait --for=condition=Ready ksvc/helloworld-swift --timeout=180s
   ```

   Knative creates an immutable Revision, programs the route and ingress, and
   automatically scales the application (including to zero).

1. Find the actual URL:

   ```bash
   kubectl get ksvc helloworld-swift --output=custom-columns=NAME:.metadata.name,URL:.status.url
   # NAME               URL
   # helloworld-swift   http://helloworld-swift.default.1.2.3.4.sslip.io
   ```

1. Request the returned URL (replace the example URL with yours):

   ```bash
   curl http://helloworld-swift.default.1.2.3.4.sslip.io
   # <html><meta charset="UTF-8"><body>Hello Swift</body></html>
   ```

## Removing the sample app deployment

```bash
kubectl delete --filename service.yaml
```
