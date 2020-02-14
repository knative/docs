---
title: "Creating a private cluster-local service"
linkTitle: "Configuring cluster-local services"
weight: 20
type: "docs"
---

By default services deployed through Knative are published to an external IP
address, making them public services on a public IP address and with a
[public URL](./using-a-custom-domain.md).

While this is useful for services that need to be accessible from outside of the
cluster, frequently you may be building a backend service which should not be
available off-cluster.

Knative provides two ways to enable private services which are only available
inside the cluster:

1. To make all services only cluster-local, change the default domain to
   `svc.cluster.local` by
   [editing the `config-domain` config map](./using-a-custom-domain.md). This
   will change all services deployed through Knative to only be published to the
   cluster, none will be available off-cluster.
1. To make an individual service cluster-local, the service or route can be
   labeled in such a way to prevent it from getting published to the external
   gateway.

## Label a service to be cluster-local

To configure a KService to only be available on the cluster-local network (and
not on the public Internet), you can apply the
`serving.knative.dev/visibility=cluster-local` label to the KService, Route or 
Kubernetes Service object.

To label the KService:

```shell
kubectl label kservice ${KSVC_NAME} serving.knative.dev/visibility=cluster-local
```

To label a route:

```shell
kubectl label route ${ROUTE_NAME} serving.knative.dev/visibility=cluster-local
```

To label a Kubernetes service:

```shell
kubectl label route ${SERVICE_NAME} serving.knative.dev/visibility=cluster-local
```

By labeling the Kubernetes service it allows you to restrict visibility in a more
fine-grained way. See [subroutes](./using-subroutes.md) for information about
tagged routes.

For example, you can deploy the [Hello World sample](./samples/hello-world/helloworld-go/README.md)
and then convert it to be an cluster-local service by labeling the service:

```shell
kubectl label kservice helloworld-go serving.knative.dev/visibility=cluster-local
```

You can then verify that the change has been made by verifying the URL for the
helloworld-go service:

```shell
kubectl get ksvc helloworld-go

NAME            URL                                              LATESTCREATED         LATESTREADY           READY   REASON
helloworld-go   http://helloworld-go.default.svc.cluster.local   helloworld-go-2bz5l   helloworld-go-2bz5l   True
```

The service returns the a URL with the `svc.cluster.local` domain, indicating
the service is only available in the cluster local network.
