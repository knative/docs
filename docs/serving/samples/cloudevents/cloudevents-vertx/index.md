---
title: "Cloud Events - Java and Vert.x"
linkTitle: "Java and Vert.x"
weight: 1
type: "docs"
---

A simple web app written in Java using Vert.x that can receive CloudEvents. It
supports running in two modes:

1. The default mode has the app reply to your input events with the output
   event, which is simplest for demonstrating things working in isolation, but
   is also the model for working for the Knative Eventing `Broker` concept. The
   input event is modified assigning a new source and type attribute.

2. `K_SINK` mode has the app send events to the destination encoded in
   `$K_SINK`, which is useful to demonstrate how folks can synthesize events to
   send to a Service or Broker when not initiated by a Broker invocation (e.g.
   implementing an event source). The input event is modified assigning a new
   source and type attribute.

The application will use `$K_SINK`-mode whenever the environment variable is
specified.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/cloudevents/cloudevents-vertx
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Build and deploy the sample

To build the image, run:

```shell
mvn compile jib:build -Dimage=<image_name>
```

{{< tabs name="cloudevents_vertx_deploy" default="kn" >}}
{{% tab name="yaml" %}}

To deploy the Knative Service, look in the `service.yaml` and replace `<image>` with the deployed image name. Then run:

```shell
kubectl apply -f service.yaml
```

{{< /tab >}}
{{% tab name="kn" %}}

If using `kn` to deploy:

```shell
kn service create cloudevents-vertx --image=<image>
```

{{< /tab >}}
{{< /tabs >}}

## Testing the sample

Get the URL for your Service with:

```shell
$ kubectl get ksvc
NAME                URL                                            LATESTCREATED             LATESTREADY               READY   REASON
cloudevents-vertx   http://cloudevents-java.sslip.io                 cloudevents-vertx-86h28   cloudevents-vertx-86h28   True
```

Then send a CloudEvent to it with:

```shell
$ curl \
    -X POST -v \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: http://curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-id: 123-abc"  \
    -d '{"name":"Dave"}' \
    http://cloudevents-java.sslip.io
```

You can also send CloudEvents spawning a temporary curl pod in your cluster
with:

```shell
$ kubectl run curl \
    --image=curlimages/curl --rm=true --restart=Never -ti -- \
    -X POST -v \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: http://curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-id: 123-abc"  \
    -d '{"name":"Dave"}' \
    http://cloudevents-java.default.svc
```

You'll see on the console:

```shell
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
< ce-source: https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-vertx
< ce-type: curl.demo
< content-type: application/json
< content-length: 15
<
{"name":"Dave"}
```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service:

{{< tabs name="cloudevents_vertx_delete" default="kn" >}}
{{% tab name="yaml" %}}

Run:

```shell
kubectl delete --filename service.yaml
```

{{< /tab >}}
{{% tab name="kn" %}}

Run:

```shell
kn service delete cloudevents-vertx
```

{{< /tab >}}
