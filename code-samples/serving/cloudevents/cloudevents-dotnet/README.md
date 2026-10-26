# Cloud Events - .NET

A simple web app written in ASP.NET and C# that can receive and send Cloud Events that you
can use for testing. It supports running in two modes:

1. The default mode has the app reply to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working for the Knative Eventing `Broker` concept.

2. `K_SINK` mode has the app send events to the destination encoded in
   `$K_SINK`, which is useful to demonstrate how folks can synthesize events to
   send to a Service or Broker when not initiated by a Broker invocation (e.g.
   implementing an event source)

The application uses `$K_SINK` mode when the environment variable is nonempty.
An absent or empty `K_SINK` selects reply mode.

This sample targets **.NET 10 LTS** and **CloudNative.CloudEvents 2.9.0**, using
the SDK's System.Text.Json formatter for both binary and structured CloudEvents
v1.0. See the [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)
and [CloudEvents .NET SDK](https://github.com/cloudevents/sdk-csharp).

Clone the checked-in sample and use its existing source and deployment files:


```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-dotnet
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## The sample code

1. In [`Controllers/CloudEventsController.cs`](Controllers/CloudEventsController.cs), you will see two key functions for the
   different modes of operation:

   ```csharp
   private async Task<IActionResult> ReceiveAndSend(CloudEvent response) {
     // This is called whenever an event is received if $K_SINK is set, and sends a new event
     // to the url in $K_SINK.
   }

   private IActionResult ReceiveAndReply(CloudEvent response) {
     // This is called whenever an event is received if $K_SINK is NOT set, and it replies with
     // the new event instead.
   }
   ```

1. The [`Dockerfile`](Dockerfile) pulls in the
   dependencies and builds an ASP.NET container based on Alpine. You can build
   and push this to your registry of choice via:

   ```bash
   # Build and push the container on your local machine.
   docker buildx build --platform linux/arm64,linux/amd64 -t "<image>" --push .
   ```

1. In the checked-in [`service.yaml`](service.yaml), take the `<image>` name and insert it
   into the `image:` field.

   ```bash
   kubectl apply -f service.yaml
   ```

The official .NET 10 Alpine images support both arm64 and amd64. The runtime
image runs as the built-in non-root application user.

## Testing locally with Docker

Build and run without pushing an image or using a cluster:

```bash
docker buildx build --load -t cloudevents-dotnet .
docker run --rm -p 8080:8080 cloudevents-dotnet
```

Send the request below to `http://localhost:8080`. The response is a structured
CloudEvent whose `data.message` is `Hello, Dave`. Structured JSON requests using
`Content-Type: application/cloudevents+json` are also supported.

The image listens on port **8080** by default. Set `ASPNETCORE_URLS` to change
the listening address (for example `-e ASPNETCORE_URLS=http://+:8091` with
`-p 8091:8091`); this app does not read `PORT`. The service manifest explicitly
sets `ASPNETCORE_URLS=http://*:8080`.

To test forwarding, additionally set `-e K_SINK=http://<reachable-host>:<port>`
to a receiver reachable from the container. The receiver gets a structured
CloudEvent; the app returns the receiver's status and body rather than the event,
including non-success statuses. Connection failures return HTTP 502; a sink
request exceeding the 10-second timeout returns HTTP 504.

Requests to `/` must be valid CloudEvents with JSON object data and a nonempty
string `name`. Malformed JSON, missing required event attributes, or missing or
invalid `name` return HTTP 400. `POST /echo` returns the original event as a
structured CloudEvent, retaining its ID, type, source, and data.

Dependency versions are recorded in the application's
[`packages.lock.json`](packages.lock.json); production builds restore in locked mode.

## Testing the sample

Get the URL for your Service with:

```bash
$ kubectl get ksvc
NAME                 URL                            LATESTCREATED              LATESTREADY                READY   REASON
cloudevents-dotnet   http://cloudevents-dotnet...   cloudevents-dotnet-ss5pj   cloudevents-dotnet-ss5pj   True
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
    <service-URL>
```

Where `<service-URL>` is the URL from the `kubectl get ksvc` command.

You will get back:

```json
{
  "specversion": "1.0",
  "type": "dev.knative.docs.sample",
  "source": "https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-dotnet",
  "id": "d662b6f6-35ff-4b98-bffd-5ae9eee23dab",
  "time": "2020-05-19T01:26:23.3500138Z",
  "datacontenttype": "application/json",
  "data": {
    "message": "Hello, Dave"
  }
}
```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
