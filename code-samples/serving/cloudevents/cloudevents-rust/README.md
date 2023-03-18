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

The application will use `$K_SINK`-mode whenever the environment variable is
specified.

Do the following steps to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-rust
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured.  See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- This guide uses Rust `musl` toolchain to build the image in order to create
  really small docker images. To install the Rust toolchain: [`rustup`](https://rustup.rs/).
  To install musl support: [MUSL support for fully static binaries](https://doc.rust-lang.org/edition-guide/rust-2018/platform-and-target-support/musl-support-for-fully-static-binaries.html).

## Build and deploy the sample

To build the binary, run:

```bash
cargo build --target x86_64-unknown-linux-musl --release
```

This will build a statically linked binary, in order to create an image from scratch. Now build the docker image:

```bash
docker build -t <image> .
```
### yaml

To deploy the Knative Service, look in the `service.yaml` and replace `<image>` with the deployed image name. Then run:

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
