# Cloud Events - Rust

A simple web app written in Rust using [Actix web](https://github.com/actix/actix-web)
that can receive CloudEvents. It supports running in two modes:

1. The default mode has the app reply to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working for the Knative Eventing `Broker` concept.
   The input event is modified assigning a new source and type attribute.

2. `K_SINK` mode has the app send events to the destination encoded in
   `$K_SINK`, which is useful to demonstrate how folks can synthesize events to
   send to a Service or Broker when not initiated by a Broker invocation (e.g.
   implementing an event source).
   The input event is modified assigning a new source and type attribute.

The application uses `$K_SINK` mode when the environment variable is nonempty.
An unset or empty `K_SINK` selects reply mode. Both binary and structured
CloudEvents v1.0 HTTP requests are supported; reply events use binary encoding.

Use the checked-in [application](src/main.rs), [Dockerfile](Dockerfile), and
[Service manifest](service.yaml) rather than recreating them from this guide.
Clone the repository to build and deploy the sample:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-rust
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured.  See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- No host Rust installation is required. The multi-stage Dockerfile uses stable
  Rust **1.99.1**, Actix Web **4.17**, and the official CloudEvents SDK **0.9**.
  It builds a static musl binary from source for the selected target platform,
  runs formatting and Clippy, then copies the binary and CA
  certificates into a non-root `scratch` image.

## Build and deploy the sample

Build and push an image for your cluster's architecture:

```bash
# Choose linux/amd64 instead for an x86-64 cluster.
docker buildx build --platform linux/arm64 -t "<image>" --push .
```

If your builder supports both platforms, publish a multi-architecture image:

```bash
docker buildx build --platform linux/arm64,linux/amd64 -t "<image>" --push .
```

Each platform is compiled from source; no prebuilt host binary is copied. To
build locally without publishing, run `docker build -t cloudevents-rust .`.
The build uses `Cargo.lock` with `--locked`. To run the language checks directly
with a local Rust 1.99.1 toolchain, use:

```bash
cargo fmt --check
cargo clippy --locked --release --all-targets -- -D warnings
```

### yaml

To deploy the Knative Service, edit [service.yaml](service.yaml) and replace
`docker.io/slinkydeveloper/cloudevents-rust` with your deployed image name. Then run:

```bash
kubectl apply -f service.yaml
```


### kn

If using `kn` to deploy:

```bash
kn service create cloudevents-rust --image=<image>
```

## Testing the sample

Get the URL for your Service with:

 ```bash
 $ kubectl get ksvc
 NAME                URL                                            LATESTCREATED             LATESTREADY               READY   REASON
 cloudevents-rust    http://cloudevents-rust.sslip.io                 cloudevents-rust-vl8fq    cloudevents-rust-vl8fq    True
 ```

Then send a CloudEvent to it with:

 ```bash
 $ curl \
    -X POST -v \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: http://curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-id: 123-abc"  \
    -d '{"name":"Dave"}' \
    http://cloudevents-rust.sslip.io
 ```

You can also send CloudEvents spawning a temporary curl pod in your cluster with:

 ```bash
$ kubectl run curl \
    --image=curlimages/curl --rm=true --restart=Never -ti -- \
    -X POST -v \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: http://curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-id: 123-abc"  \
    -d '{"name":"Dave"}' \
    http://cloudevents-rust.default.svc
 ```

You'll get as result:

 ```bash
> POST / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.69.1
> Accept: */*
> content-type: application/json
> ce-specversion: 1.0
> ce-source: http://curl-command
> ce-type: curl.demo
> ce-id: 123-abc
> Content-Length: 15
>
< HTTP/1.1 200 OK
< content-length: 15
< content-type: application/json
< ce-specversion: 1.0
< ce-id: 123-abc
< ce-type: dev.knative.docs.sample
< ce-source: https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-rust
< date: Sat, 23 May 2020 09:00:01 GMT
<
{"name":"Dave"}
 ```

### Forwarding events with `K_SINK`

To forward events rather than return them, configure `K_SINK` with the HTTP URL
of a receiving Service or Broker (see the commented environment configuration in
`service.yaml`). The receiver gets the same event ID and data with the source
and type shown above. A successful delivery returns HTTP `202 Accepted` with an
empty body to the caller, not a reply CloudEvent. A failed delivery returns HTTP
`500 Internal Server Error`. Sink requests have a 30-second timeout. An empty
`K_SINK` behaves like an unset variable and returns the reply event instead.

The server listens on all interfaces on `PORT` (default `8080`; invalid values
fall back to the default). On Knative, configure the container's
`ports[].containerPort` (for example `8081`); Knative injects `PORT` automatically.
Do not set the reserved `PORT` environment variable yourself or use Knative's
reserved port `9090`. Outside Knative, you can set `PORT` directly. `RUST_LOG` can
override the default `info` logging level. Missing or malformed CloudEvents
return HTTP `400 Bad Request`.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service:

### yaml

```bash
kubectl delete --filename service.yaml
```

### kn

```bash
kn service delete cloudevents-rust
```
