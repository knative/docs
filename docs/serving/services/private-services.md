---
title: "Creating a private service"
linkTitle: "Configuring private services"
weight: 03
type: "docs"
aliases:
  - /docs/serving/cluster-local-route
---

# Creating a private service

By default services deployed through Knative are published to an external IP
address, making them public services on a public IP address and with a public URL.

While this is useful for services that need to be accessible from outside of the
cluster, frequently you may be building a back-end service which should not be
available from outside of the cluster.

Knative provides three ways to enable private services which are only available
inside the cluster:

1. To make all services private, change the default domain to
   `svc.cluster.local` by
   [editing the `config-domain` ConfigMap](../using-a-custom-domain.md). This
   changes all services deployed through Knative to only be published to the
   cluster.
1. To make an individual service private, the service or route can be
   labelled so that it is not published to the external gateway.
1. Use [custom domain mappings](../creating-domain-mappings).

## Label a service to be cluster-local only

To configure a Knative service to only be available on the cluster-local network, and not on the public internet, you can apply the
`networking.knative.dev/visibility=cluster-local` label to a Knative service, a route or a Kubernetes service object.

- To label a Knative service:

    ```shell
    kubectl label kservice ${KSVC_NAME} networking.knative.dev/visibility=cluster-local
    ```

    By labeling the Kubernetes service you can restrict visibility in a more
    fine-grained way. See [subroutes](../using-subroutes.md) for information about
    tagged routes.

- To label a route when the route is used directly without a Knative service:

    ```shell
    kubectl label route ${ROUTE_NAME} networking.knative.dev/visibility=cluster-local
    ```

- To label a Kubernetes service:

    ```shell
    kubectl label service ${SERVICE_NAME} networking.knative.dev/visibility=cluster-local
    ```

### Example

You can deploy the [Hello World sample](../samples/hello-world/helloworld-go/) and then convert it to be an cluster-local service by labelling the service:

```shell
kubectl label kservice helloworld-go networking.knative.dev/visibility=cluster-local
```

You can then verify that the change has been made by verifying the URL for the
`helloworld-go` service:

```shell
kubectl get kservice helloworld-go

NAME            URL                                              LATESTCREATED         LATESTREADY           READY   REASON
helloworld-go   http://helloworld-go.default.svc.cluster.local   helloworld-go-2bz5l   helloworld-go-2bz5l   True
```

The service returns the a URL with the `svc.cluster.local` domain, indicating
the service is only available in the cluster local network.
