# Cloud Events - Java and Vert.x

A simple web app written in Java using Vert.x that can receive CloudEvents. It
supports running in two modes:

1. The default mode has the app reply to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working for the Knative Eventing `Broker` concept. The
   input event is modified by assigning a new source; its type, ID, and data
   are preserved.

2. `K_SINK` mode has the app send events to the destination encoded in
   `$K_SINK`, which is useful to demonstrate how folks can synthesize events to
   send to a Service or Broker when not initiated by a Broker invocation (e.g.
   implementing an event source). The input event is modified by assigning a
   new source; its type, ID, and data are preserved. A successful sink response
   (any 2xx status) produces an empty `202` response to the caller. A failed
   delivery produces `500` (including a sink timeout after five seconds).

The application uses `$K_SINK` mode when the variable contains a nonblank,
absolute HTTP(S) URL. An absent, empty, or whitespace-only `K_SINK` selects reply
mode. Both binary and JSON structured CloudEvents v1 are accepted; output is
sent in binary mode. Invalid CloudEvents receive `400` without forwarding.

The HTTP server listens on `$PORT`, defaulting to `8080`. Invalid ports or sink
URLs fail startup with a nonzero exit status.

Clone the repository and enter the sample directory:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-vertx
```

Build with [pom.xml](pom.xml) and deploy with [service.yaml](service.yaml).

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured.  See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- Java 21 LTS and [Maven 3.9](https://maven.apache.org/) for the build.
  The image uses the public Eclipse Temurin Java 21 JRE and runs as a non-root user.
- A container registry you can push to and that your cluster can pull from.
  Configure its credentials for Jib as needed. Jib builds and pushes the image
  without requiring a local Docker daemon.

## Build and deploy the sample

This sample uses CloudEvents Java SDK 5.1.0, including the JSON event-format
provider, and the SDK's compatible Vert.x 4.5.28 integration. The
[Vert.x 4 maintenance line is supported until April 2027](https://vertx.io/blog/eclipse-vert-x-4-5-28/).

1. To build and push the image, run:
```bash
mvn clean verify jib:build -Dimage=<image_name>
```
   Replace `<image_name>` with your fully qualified registry image name. The image
   defaults to Linux **arm64**. For an amd64 Docker host or cluster, add
   `-Djib.architecture=amd64` to the Maven build command. Select the architecture
   that matches your cluster.

   For local testing with Docker, build without pushing to a registry:
   ```bash
   mvn clean verify jib:buildTar -Dimage=cloudevents-vertx:local
   docker load -i target/jib-image.tar
   docker run --rm -p 8080:8080 cloudevents-vertx:local
   ```
   Send the event below to `http://localhost:8080` instead of the service URL.

2. Choose one of the following methods to deploy the sample:

 ### yaml
 * To deploy the Knative Service, use [service.yaml](service.yaml) and replace `<image>` with the built image name. Then run:
```bash
kubectl apply -f service.yaml
```

 ### kn
 * If using `kn` to deploy:
```bash
kn service create cloudevents-vertx --image=<image>
```

## Testing the sample

Get the URL for your Service with:

```bash
$ kubectl get ksvc
NAME                URL                                            LATESTCREATED             LATESTREADY               READY   REASON
cloudevents-vertx   http://cloudevents-vertx.default.example.com     cloudevents-vertx-86h28   cloudevents-vertx-86h28   True
```

Use the actual URL reported by your cluster, then send a CloudEvent to it:

```bash
SERVICE_URL=$(kubectl get ksvc cloudevents-vertx -o jsonpath='{.status.url}')
curl \
    -X POST -v \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: http://curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-id: 123-abc"  \
    -d '{"name":"Dave"}' \
    "$SERVICE_URL"
```

You can also send CloudEvents spawning a temporary curl pod in your cluster
with:

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
    http://cloudevents-vertx.default.svc
```

You'll see on the console:

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
< HTTP/1.1 202 Accepted
< ce-specversion: 1.0
< ce-id: 123-abc
< ce-source: https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-vertx
< ce-type: curl.demo
< content-type: application/json
< content-length: 15
<
{"name":"Dave"}
```

### Structured JSON input

The equivalent structured CloudEvent produces the same binary response:

```bash
curl -i "$SERVICE_URL" \
  -H 'content-type: application/cloudevents+json' \
  -d '{"specversion":"1.0","source":"http://curl-command","type":"curl.demo","id":"123-abc","datacontenttype":"application/json","data":{"name":"Dave"}}'
```

### Forwarding to a sink

To enable sink mode, set `K_SINK` to the destination URL, for example:

```bash
kn service update cloudevents-vertx --env K_SINK=http://my-sink.default.svc.cluster.local
```

Replace the URL with a reachable service or Broker that accepts CloudEvents.
Send the same test event again. The sink receives the transformed event and the
caller receives `202` with an empty body, rather than the event shown above.
For local Docker testing, pass `-e K_SINK=<sink-url>` to `docker run`.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service:

### yaml

```bash
kubectl delete --filename service.yaml
```

### kn

```bash
kn service delete cloudevents-vertx
```
