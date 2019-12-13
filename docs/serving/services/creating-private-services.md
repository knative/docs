---
title: "Creating a cluster-local private Knative Service"
linkTitle: "Creating a cluster-local Service"
weight: 20
type: "docs"
aliases:
  - [/docs/serving/cluster-local-route/]
---

By default, Services deployed through Knative are published to an external IP
address, making them public Services on a public IP address, with a
[public URL](./using-a-custom-domain.md).

While this is useful for Services that need to be accessible from outside of the
cluster, frequently you may be building a backend Service which should not be
available off-cluster.

## Making a Service private

Knative provides two ways to enable private Services which are only available
inside the cluster:

1. To make all Services private, change the default domain to
   `svc.cluster.local` by
   [editing the `config-domain` config map](./using-a-custom-domain.md). This
   will change all Services deployed through Knative to only be published to the
   cluster.
1. To make an individual Service private, the Service or route must be labeled correctly to prevent it from being published to the external gateway.

## Label a Service as private

To configure a Knative Service to only be available on the private network (and
not on the public internet), you can apply the
`serving.knative.dev/visibility=cluster-local` label to the Knative Service or Route
object.

To label the Knative Service, use this command:

```shell
kubectl label kservice ${KSVC_NAME} serving.knative.dev/visibility=cluster-local
```

To label a route, use this command:

```shell
kubectl label route ${ROUTE_NAME} serving.knative.dev/visibility=cluster-local
```

## Hello World example

You can deploy the [Hello World sample](./samples/hello-world/helloworld-go/README.md)
and then convert it to be a private Service by labeling the Service:

```shell
kubectl label kservice helloworld-go serving.knative.dev/visibility=cluster-local
```

You can then verify that the change has been made by verifying the URL for the
`helloworld-go` Service:

```shell
kubectl get ksvc helloworld-go

NAME            URL                                              LATESTCREATED         LATESTREADY           READY   REASON
helloworld-go   http://helloworld-go.default.svc.cluster.local   helloworld-go-2bz5l   helloworld-go-2bz5l   True
```

The Service returns the a URL with the `svc.cluster.local` domain, indicating that the Service is only available in the private network.
