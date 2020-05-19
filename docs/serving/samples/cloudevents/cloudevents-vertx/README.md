# Vert.x + CloudEvents + Knative

A simple web app written in Java using Vert.x that can receive CloudEvents.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/cloudevents/cloudevents-vertx
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Build and deploy the sample

To build the image, run:

```shell
mvn compile jib:build -Dimage=<image_name>
```

To deploy the Knative Service, look in the `service.yaml` and replace `<image>` with the deployed image name. Then run:

```shell
kubectl apply -f service.yaml
```

## Testing the sample

Get the URL for your Service with:

```shell
$ kubectl get ksvc
NAME                URL                                            LATESTCREATED             LATESTREADY               READY   REASON
cloudevents-vertx   http://cloudevents-vertx.default.example.com   cloudevents-vertx-86h28   cloudevents-vertx-86h28   True 
```

Then send a cloud event to it with:

```shell
$ kubectl run curl \
    --image=curlimages/curl --rm=true --restart=Never -ti -- \
    -X POST \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: curl-command"  \
    -H "ce-type: curl.demo"  \
    -H "ce-id: 123-abc"  \
    -d '{"name":"Dave"}' \
    http://cloudevents-vertx.default.svc
```

You'll see on the cloudevents-vertx deployed pod:

```shell
Received event: CloudEvent{attributes=Attibutes V1.0 [id=123-abc, source=curl-command, type=curl.demo, datacontenttype=application/json, dataschema=null, subject=null, time=null], data={"name":"Dave"}, extensions={}}
```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
