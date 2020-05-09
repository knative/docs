---
title: "Cloud Events - C#"
linkTitle: "C#"
weight: 1
type: "docs"
---

A simple web app written in C# and ASP.NET Core 3.1 that can receive and
send Cloud Events that you can use for testing. It supports two APIs:

1. `api/events`: Replies to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working for the Knative Eventing `Broker` concept.

2. `api/events/sink`: Sends events to the destination encoded in
   `K_SINK` environment variable, which is useful to demonstrate how folks
   can synthesize events to send to a Service or Broker when not initiated
   by a Broker invocation (e.g. implementing an event source)

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/cloudevents/cloudevents-dotnet
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## The sample code.

1. If you look in `Dockerfile`, you will see a method for pulling in the
   dependencies and building a ASP.NET Core container. You can build
   and push this to your registry of choice via:

   ```shell
   docker build -t <image> .
   docker push <image>
   ```

1. If you look in `service.yaml`, take the `<image>` name above and insert it
   into the `image:` field.

   ```shell
   kubectl apply -f service.yaml
   ```

## Testing the sample

Get the URL for your Service with:

```shell
$ kubectl get ksvc
NAME                 URL                                                LATESTCREATED              LATESTREADY                READY   REASON
cloudevents-dotnet   http://cloudevents-dotnet.default.1.2.3.4.xip.io   cloudevents-dotnet-ss5pj   cloudevents-dotnet-ss5pj   True
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
    http://cloudevents-dotnet.default.1.2.3.4.xip.io/api/events
```

You will get back:

```shell
{"message":"Hello, Dave"}
```

To send a cloud event to another URL, replace the URL in the curl command with
`http://cloudevents-dotnet.default.1.2.3.4.xip.io/api/events/sink`

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
