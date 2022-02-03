# Configuring private Services

By default, Services deployed through Knative are published to an external IP
address, making them public Services on a public IP address and with a public URL.

Knative provides two ways to enable private services which are only available
inside the cluster:

1. To make all Knative Services private, change the default domain to
   `svc.cluster.local` by [editing the `config-domain` ConfigMap](https://github.com/knative/serving/blob/main/config/core/configmaps/domain.yaml). This changes all Services deployed through Knative to only be published to the cluster.
1. To make an individual Service private, the Service or Route can be
   labelled with `networking.knative.dev/visibility=cluster-local` so that it is not published to the external gateway.

## Using the cluster-local label

To configure a Knative Service so that it is only available on the cluster-local network, and not on the public internet, you can apply the
`networking.knative.dev/visibility=cluster-local` label to a Knative Service, a route or a Kubernetes Service object.

- To label a Knative Service:

    ```bash
    kubectl label kservice ${KSVC_NAME} networking.knative.dev/visibility=cluster-local
    ```

    By labeling the Kubernetes Service you can restrict visibility in a more
    fine-grained way. See [Traffic management](../traffic-management.md) for information about tagged routes.

- To label a Route when the Route is used directly without a Knative Service:

    ```bash
    kubectl label route ${ROUTE_NAME} networking.knative.dev/visibility=cluster-local
    ```

- To label a Kubernetes Service:

    ```bash
    kubectl label service ${SERVICE_NAME} networking.knative.dev/visibility=cluster-local
    ```

### Example

You can deploy the [Hello World sample](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-go) and then convert it to be an cluster-local Service by labelling the Service:

```bash
kubectl label kservice helloworld-go networking.knative.dev/visibility=cluster-local
```

You can then verify that the change has been made by verifying the URL for the
`helloworld-go` Service:

```bash
kubectl get kservice helloworld-go

NAME            URL                                              LATESTCREATED         LATESTREADY           READY   REASON
helloworld-go   http://helloworld-go.default.svc.cluster.local   helloworld-go-2bz5l   helloworld-go-2bz5l   True
```

The Service returns the a URL with the `svc.cluster.local` domain, indicating
the Service is only available in the cluster-local network.
