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

The application will use `$K_SINK`-mode whenever the environment variable is
specified.

Do the following steps to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-nodejs
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured.  See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## The Sample Code

In the `index.js` file, you will see two key functions for the different modes
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

## Build and Deploy the Application

In the `Dockerfile`, you can see how the dependencies are installed using npm.
You can build and push this to your registry of choice via:

 ```bash
 docker build -t <image> .
 docker push <image>
 ```

### yaml

 To deploy the Knative service, edit the `service.yaml` file and replace `<registry/repository/image:tag>` with the image you have just created.

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
