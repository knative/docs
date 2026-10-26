# Cloud Events - Java and Spring

A simple web app using Java 25 LTS, Spring Boot 4.0.9 and Spring Cloud Function
5.0.5 that can receive CloudEvents. The build uses Maven 3.9.16 and Jib 3.5.2,
with public release dependencies from Maven Central (no snapshot or milestone
repositories). It supports running in two modes:

1. The default mode has the app reply to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working with the Knative Eventing `Broker` concept. The
   input event is modified assigning a new source and type attribute.

2. `K_SINK` mode has the app send events to the destination encoded in
   `$K_SINK`, which is useful to demonstrate how folks can synthesize events to
   send to a Service or Broker when not initiated by a Broker invocation (e.g.
   implementing an event source). The input event is modified assigning a new
   source and type attribute.

The application will use `$K_SINK`-mode whenever the environment variable is
non-empty. If it is unset or empty, the application replies to the request.
Both modes accept binary and structured JSON CloudEvents. Output events use
binary HTTP encoding, with a new ID, source
`https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-spring`,
and type `org.knative.examples.cloudevents.spring.Response`. JSON object data
(including additional and nested fields) is preserved in both modes.

## HTTP contract

- Send `POST /` with a JSON object in binary CloudEvents 1.0 or structured
  `application/cloudevents+json` format. Header names are case-insensitive;
  structured content types may include a charset.
- A binary event must include `ce-specversion: 1.0`, `ce-id`, `ce-source` and
  `ce-type`. Structured events require the corresponding attributes and an
  object-valued `data` field. Ordinary JSON without any event headers is also
  accepted and wrapped in a new response event.
- Empty/malformed JSON, partial or unsupported-version events and non-object
  data return `400 Bad Request`. Requests larger than 1 MiB return `413`;
  methods other than POST return `405`.
- The default port is 8080. Knative's `PORT` environment variable selects another
  port; Spring's `SERVER_PORT` can also explicitly override it.

Use the checked-in [application](src/main/java/org/knative/examples/cloudevents/spring/CloudEventSampleApplication.java),
[HTTP validation](src/main/java/org/knative/examples/cloudevents/spring/HttpHeaderFilter.java),
[runtime configuration](src/main/resources/application.properties),
[Maven build](pom.xml), and [Knative Service manifest](service.yaml). Clone a working copy:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-spring
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured.  See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- A Java 25 JDK and Maven 3.9.16 installed to compile the application.
  Alternatively, run Maven commands in the `maven:3.9.16-eclipse-temurin-25`
  Docker image with this sample mounted as the working directory.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Build and deploy the sample

First compile and package the application:

```bash
mvn clean package
```

To build and push the image, run (replace `<image_name>` with a registry image
you can push to):

```bash
mvn compile jib:build -Dimage=<image_name>
```

For a local image without a registry push, use:

```bash
mvn compile jib:buildTar -Dimage=cloudevents-spring:local
docker load -i target/jib-image.tar
```

Jib uses the Eclipse Temurin 25 JRE image and targets Linux amd64 by default.
For a native arm64 image, add `-Dimage.architecture=arm64` to the Jib command.
Local images must also be loaded into the Kubernetes node's image store (loading
into host Docker alone is not enough); configure `imagePullPolicy: IfNotPresent`
when using an already-loaded local image.

To deploy the Knative Service, edit the checked-in [service.yaml](service.yaml) and replace `<image>`
with the deployed image name. Then run:

```bash
kubectl apply -f service.yaml
```

## Testing the sample

Wait for the Service to become ready, then get its URL:

```bash
kubectl wait --for=condition=Ready ksvc/cloudevents-spring --timeout=180s
SERVICE_URL=$(kubectl get ksvc cloudevents-spring -o jsonpath='{.status.url}')
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
    http://cloudevents-spring.default.svc
```

In default reply mode, you'll see a response like this (the generated event ID
will vary):

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
< ce-specversion: 1.0
< ce-id: d93cabfa-0a9b-4500-9a45-21791d132490
< ce-source: https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-spring
< ce-type: org.knative.examples.cloudevents.spring.Response
< content-type: application/json
<
{"name":"Dave"}
```

## Testing forwarding with K_SINK

Set `K_SINK` to a reachable HTTP endpoint that accepts CloudEvents. For example,
if an event receiver Service is named `event-receiver` in the `default` namespace:

```bash
kubectl patch ksvc cloudevents-spring --type=json -p='[
  {"op":"add","path":"/spec/template/spec/containers/0/env","value":[
    {"name":"K_SINK","value":"http://event-receiver.default.svc"}
  ]}
]'
kubectl wait --for=condition=Ready ksvc/cloudevents-spring --timeout=180s
```

Repeat the same curl request. The application forwards the event payload to the
sink with the new CloudEvent ID, source, and type described above. After a
successful delivery, the caller receives `202 Accepted` with an empty body and
no response CloudEvent headers. Check the receiver to verify the forwarded event;
the empty response alone does not show its contents. A sink HTTP failure must
propagate as a server error to the caller rather than being acknowledged as a
successful delivery. Sink connections have a 5-second connection timeout and a
10-second read timeout. Inbound authorization and other arbitrary HTTP headers
are not copied to the sink; only the newly generated event attributes and JSON
payload are sent.

To return to reply mode:

```bash
kubectl patch ksvc cloudevents-spring --type=json -p='[
  {"op":"remove","path":"/spec/template/spec/containers/0/env"}
]'
kubectl wait --for=condition=Ready ksvc/cloudevents-spring --timeout=180s
```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service:

### yaml

```bash
kubectl delete --filename service.yaml
```


### kn

```bash
kn service delete cloudevents-spring
```
