# Cloud Events - Node.js

A simple web app written in Node.js that can receive and send Cloud Events that you
can use for testing. It supports running in two modes:

1. The default mode has the app reply to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working for the Knative Eventing `Broker` concept.

2. `K_SINK` mode has the app send events to the destination encoded in
   `$K_SINK`, which is useful to demonstrate how folks can synthesize events to
   send to a Service or Broker when not initiated by a Broker invocation (e.g.
   implementing an event source)

The application uses `$K_SINK`-mode when the environment variable is nonempty;
when it is absent or empty, the application replies with the event. `PORT` defaults to `8080` and can be overridden when running locally.
On Knative, set the container's `ports[].containerPort` to change the listening
port (for example, `8081`); Knative injects `PORT`, so do not set it explicitly.
Events without a `name` in their data produce `{"message":"Hello, nameless"}`;
the event's `data` is optional.

Clone the sample's checked-in source, then build and deploy it to your cluster:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-nodejs
```

## Before you begin

- Node.js 24 LTS for local development (the Dockerfile uses Node.js 24.22.1).
- A Kubernetes cluster with Knative installed and DNS configured.  See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## The Sample Code

In [index.js](index.js), you will see two key functions for the different modes
of operation:

   ```js
   const receiveAndSend = (cloudEvent, res) => {
     // This is called whenever an event is received if $K_SINK is set, and sends a new event
     // to the url in $K_SINK.
   }

   const receiveAndReply = (cloudEvent, res) => {
     // This is called whenever an event is received if $K_SINK is NOT set, and it replies with
     // the new event instead.
   }
   ```

## Development checks

Install the locked dependencies with `npm ci`, then run `npm run lint`.
Development-only tools are excluded from the production image.

This sample uses CloudEvents SDK 10 and Express 5. The lockfile overrides the SDK's
transitive `uuid` dependency to the compatible CommonJS 11.x line to avoid
[GHSA-w5hq-g745-h8pq](https://github.com/advisories/GHSA-w5hq-g745-h8pq).
The production container runs Node directly as the non-root `node` user.

## Build and Deploy the Application

The checked-in [Dockerfile](Dockerfile) installs the dependencies using npm.
You can build and push this to your registry of choice via:

 ```bash
 # Build and push the container on your local machine.
 docker buildx build --platform linux/arm64,linux/amd64 -t "<image>" --push .
 ```

### yaml

 To deploy the Knative service, edit [service.yaml](service.yaml) and replace `<registry/repository/image:tag>` with the image you have just created.

 ```bash
 kubectl apply -f service.yaml
 ```

### kn

To deploy using the `kn` CLI:

```bash
kn service create cloudevents-nodejs --image=<image>
```

## Testing the sample

Get the URL for your Service with:

```bash
$ kubectl get ksvc
NAME                 URL                                                LATESTCREATED              LATESTREADY                READY   REASON
cloudevents-nodejs   http://cloudevents-nodejs.default.1.2.3.4.sslip.io   cloudevents-nodejs-ss5pj   cloudevents-nodejs-ss5pj   True
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
    http://cloudevents-nodejs.default.1.2.3.4.sslip.io
```

You will get back:

```bash
{"message":"Hello, Dave"}
```

The HTTP 200 response is a binary-mode CloudEvent: the body above contains the
event data, and the `ce-specversion`, `ce-id`, `ce-source`, and `ce-type` response
headers contain its attributes. The response type is `dev.knative.docs.sample`.
The app also accepts structured-mode requests with
`Content-Type: application/cloudevents+json`. Invalid events receive HTTP 415.

### Send to a sink

To forward the generated event instead of returning it, uncomment the `K_SINK`
environment variable in `service.yaml`, set its value to your destination URL,
and apply the manifest again. With `kn`, use:

```bash
kn service update cloudevents-nodejs --env K_SINK=http://your-sink.default.svc.cluster.local
```

Send the same request above. In this mode the app returns HTTP 202 with an empty
body, and sends the greeting as a binary-mode CloudEvent to `K_SINK`. Check the
sink's received events and the app logs to confirm delivery. The acknowledgment
is sent before delivery completes; delivery errors are logged, not retried.
HTTP non-2xx responses, network errors, and the 10-second outbound request timeout
are reported as delivery failures. A 202 acknowledgment does not guarantee that
the sink accepted the event.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service.

### yaml

 ```bash
kubectl delete --filename service.yaml
```

### kn

```bash
kn service delete cloudevents-nodejs
```
