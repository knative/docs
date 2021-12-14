# Cloud Events - .NET Core

A simple web app written in ASP.NET and C# that can receive and send Cloud Events that you
can use for testing. It supports running in two modes:

1. The default mode has the app reply to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working for the Knative Eventing `Broker` concept.

2. `K_SINK` mode has the app send events to the destination encoded in
   `$K_SINK`, which is useful to demonstrate how folks can synthesize events to
   send to a Service or Broker when not initiated by a Broker invocation (e.g.
   implementing an event source)

The application will use `$K_SINK`-mode whenever the environment variable is
specified.

Do the following the steps to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

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

1. If you look in `controllers\CloudEventsController.cs`, you will see two key functions for the
   different modes of operation:

   ```csharp
   private async Task<IActionResult> ReceiveAndSend(CloudEvent receivedEvent) {
     // This is called whenever an event is received if $K_SINK is set, and sends a new event
     // to the url in $K_SINK.
   }

   private IActionResult ReceiveAndReply(CloudEvent receivedEvent) {
     // This is called whenever an event is received if $K_SINK is NOT set, and it replies with
     // the new event instead.
   }
   ```

1. If you look in `Dockerfile`, you will see a method for pulling in the
   dependencies and building an ASP.NET container based on Alpine. You can build
   and push this to your registry of choice via:

   ```bash
   docker build -t <image> .
   docker push <image>
   ```

1. If you look in `service.yaml`, take the `<image>` name and insert it
   into the `image:` field.

   ```bash
   kubectl apply -f service.yaml
   ```

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
