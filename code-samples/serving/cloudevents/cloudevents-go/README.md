# Cloud Events - Go

A simple web app written in Go that can receive and send Cloud Events that you
can use for testing. It supports running in two modes:

1. The default mode has the app reply to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working for the Knative Eventing `Broker` concept.

2. `K_SINK` mode has the app send events to the destination encoded in
   `$K_SINK`, which is useful to demonstrate how folks can synthesize events to
   send to a Service or Broker when not initiated by a Broker invocation (e.g.
   implementing an event source)

The application will use `$K_SINK`-mode whenever the environment variable has a
non-empty value. An unset or empty `K_SINK` selects reply mode.

Use the checked-in [application source](cloudevents.go), [Dockerfile](Dockerfile),
and [Service manifest](service.yaml) to build and deploy the app. Download a
working copy of the sample with:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-go
```

For the Eventing Hello World learning scenario, use the
[Broker/Trigger tutorial](eventing/README.md), which demonstrates filtered input
and routed replies.

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Build and deploy

Replace `{username}` below and in [service.yaml](service.yaml) with your registry
namespace. From the sample directory, build and push with Docker:

```bash
docker buildx build --platform linux/arm64,linux/amd64 \
  -t "docker.io/{username}/cloudevents-go" --push .
kubectl apply -f service.yaml
kubectl wait --for=condition=Ready ksvc/cloudevents-go --timeout=180s
```

For a local run without publishing:

```bash
docker build -t cloudevents-go:local .
docker run --rm -p 8080:8080 cloudevents-go:local
```

Send the example event below to `http://localhost:8080/` instead of the Service URL.

## Testing the sample

Get the URL for your Service with:

```bash
$ kubectl get ksvc
NAME             URL                                            LATESTCREATED          LATESTREADY            READY   REASON
cloudevents-go   http://cloudevents-go.default.1.2.3.4.sslip.io   cloudevents-go-ss5pj   cloudevents-go-ss5pj   True
```

Then send a cloud event to it with:

```bash
$ curl -X POST \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-id: 123-abc"  \
    -d '{"name":"Dave"}' \
    http://cloudevents-go.default.1.2.3.4.sslip.io
```

You will get back:

```bash
{"message":"Hello, Dave"}
```

The response is a CloudEvent in binary HTTP mode: the JSON above is its data,
and the `ce-*` response headers contain its context attributes. Use `curl -i` to
inspect these headers. The application listens on port `8080` by default; set
`PORT` to use a different port when running locally.

### Sending the response to a sink

To send the generated event to another service instead of returning it in the
HTTP response, set `K_SINK` to the destination URL. For example:

Using the `kn` CLI:

```bash
kn service update cloudevents-go --env K_SINK=http://your-sink.example.com
```

Send the same input event again. On successful delivery, the application returns
an empty successful HTTP response, and the sink receives a CloudEvent with type
`dev.knative.docs.sample` and data `{"message":"Hello, Dave"}`. Delivery failures
are returned to the caller as unsuccessful HTTP responses.

To restore reply mode:

```bash
kn service update cloudevents-go --env K_SINK-
```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
