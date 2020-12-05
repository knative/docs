---
title: "Cloud Events - Go"
linkTitle: "Go"
weight: 1
type: "docs"
---

A simple web app written in Go that can receive and send Cloud Events that you
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

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/cloudevents/cloudevents-go
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## The sample code.

1. If you look in `cloudevents.go`, you will see two key functions for the
   different modes of operation:

   ```go
   func (recv *Receiver) ReceiveAndSend(ctx context.Context, event cloudevents.Event) cloudevents.Result {
     // This is called whenever an event is received if $K_SINK is set, and sends a new event
     // to the url in $K_SINK.
   }

   func (recv *Receiver) ReceiveAndReply(ctx context.Context, event cloudevents.Event)  (*cloudevents.Event, cloudevents.Result) {
     // This is called whenever an event is received if $K_SINK is NOT set, and it replies with
     // the new event instead.
   }
   ```

1. Choose how you would like to build the application:

   {{< tabs name="cloudevents_go_build" default="Dockerfile" >}}
   {{% tab name="Dockerfile" %}}

   If you look in `Dockerfile`, you will see a method for pulling in the
   dependencies and building a small Go container based on Alpine. You can build
   and push this to your registry of choice via:

   ```shell
   docker build -t <image> .
   docker push <image>
   ```

   {{< /tab >}}
   {{% tab name="ko" %}}

   You can use [`ko`](https://github.com/google/ko) to build and push just the image with:

   ```shell
   ko publish github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-go
   ```

   However, if you use `ko` for the next step, this is not necessary.

   {{< /tab >}}
   {{< /tabs >}}

1. Choose how you would like to deploy the application:

   {{< tabs name="cloudevents_go_deploy" default="kn (with Dockerfile)" >}}
   {{% tab name="yaml (with Dockerfile)" %}}

   If you look in `service.yaml`, take the `<image>` name above and insert it
   into the `image:` field, then run:

   ```shell
   kubectl apply -f service.yaml
   ```

   {{< /tab >}}
   {{% tab name="yaml (with ko)" %}}

   If using `ko` to build and push:

   ```shell
   ko apply -f service.yaml
   ```

   {{< /tab >}}
   {{% tab name="kn (with Dockerfile)" %}}

   If using `kn` to deploy:

   ```shell
   kn service create cloudevents-go --image=<IMAGE>
   ```

   {{< /tab >}}
   {{% tab name="kn (with ko)" %}}

   You can compose `kn` and `ko` to build and deploy with a single step using:

   ```shell
   kn service create cloudevents-go --image=$(ko publish github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-go)
   ```

   {{< /tab >}}
   {{< /tabs >}}


## Testing the sample

Get the URL for your Service with:

```shell
$ kubectl get ksvc
NAME             URL                                            LATESTCREATED          LATESTREADY            READY   REASON
cloudevents-go   http://cloudevents-go.default.1.2.3.4.xip.io   cloudevents-go-ss5pj   cloudevents-go-ss5pj   True
```

Then send a cloud event to it with:

```shell
$ curl -X POST \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-id: 123-abc"  \
    -d '{"name":"Dave"}' \
    http://cloudevents-go.default.1.2.3.4.xip.io
```

You will get back:

```shell
{"message":"Hello, Dave"}
```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
