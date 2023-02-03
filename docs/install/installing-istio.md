# Installing Istio for Knative

This guide walks you through manually installing and customizing Istio for use
with Knative.

If your cloud platform offers a managed Istio installation, we recommend
installing Istio that way, unless you need to customize your
installation.

## Before you begin

You need:

- A Kubernetes cluster created.
- [`istioctl`](https://istio.io/docs/setup/install/istioctl/) installed.
- [Knative Serving](../install/README.md) installed (can also be installed after the Istio).

## Supported Istio versions

You can view the latest tested Istio version on the [Knative Net Istio releases page](https://github.com/knative-sandbox/net-istio/releases).

## Installing Istio

When you install Istio, there are a few options depending on your goals. For a
basic Istio installation suitable for most Knative use cases, follow the
[Basic installation with istioctl](#basic-installation-with-istioctl) instructions. If you're familiar with
Istio and know what kind of installation you want, read through the options and
choose the installation that suits your needs.

### Basic installation with istioctl
1. You can easily install and customize your Istio installation with `istioctl`.

    ```sh
    istioctl install -y
    ```

1. To integrate Istio with Knative Serving install the Knative Istio controller by running the command:

     ```bash
     kubectl apply -f {{ artifact(repo="net-istio",file="net-istio.yaml")}}
     ```

    !!! hint
        Make sure to also install [Knative Serving](../install/yaml-install/serving/install-serving-with-yaml.md) and [configure DNS](../install/yaml-install/serving/install-serving-with-yaml.md#configure-dns).


### Forming a service mesh
The Istio service mesh provides a few benefits:

- Allows you to turn on [mutual TLS][1], which secures service-to-service
  traffic within the cluster.

- Allows you to use the [Istio authorization policy][2], controlling the access
  to each Knative service based on Istio service roles.

If you want to use Istio as a service mesh, you must make sure that istio sidecars
are injected to all `pods` that should be part of the service mesh. There are two ways to achieve this:

- Use [automatic sidecar injection][3] and set the `istio-injection=enabled` label on all `namespaces`
  that should be part of the service-mesh

- Use [manual sidecar injection][4] on all `pods` that should be part of the service-mesh


### Using Istio mTLS feature with Knative
Since there are some networking communications between knative-serving namespace
and the namespace where your services running on, you need additional
preparations for mTLS enabled environment.

!!! note
    It is strongly recommended to use [automatic sidecar injection][3]
    to avoid manually injection sidecars to all `pods` in `knative-serving`.

1. Enable sidecar injection on `knative-serving` system namespace.

    ```bash
    kubectl label namespace knative-serving istio-injection=enabled
    ```

1. Set `PeerAuthentication` to `PERMISSIVE` on knative-serving system namespace
by creating a YAML file using the following template:

    ```bash
    apiVersion: "security.istio.io/v1beta1"
    kind: "PeerAuthentication"
    metadata:
      name: "default"
      namespace: "knative-serving"
    spec:
      mtls:
        mode: PERMISSIVE
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.


## Configuring the installation

### Updating the `config-istio` configmap to use a non-default local gateway

If you create a custom service and deployment for local gateway with a name other than `knative-local-gateway`, you
need to update gateway configmap `config-istio` under the `knative-serving` namespace.

1. Edit the `config-istio` configmap:

    ```bash
    kubectl edit configmap config-istio -n knative-serving
    ```

2. Replace the `local-gateway.knative-serving.knative-local-gateway` field with the custom service. As an example, if you name both
the service and deployment `custom-local-gateway` under the namespace `istio-system`, it should be updated to:

    ```
    custom-local-gateway.istio-system.svc.cluster.local
    ```

As an example, if both the custom service and deployment are labeled with `custom: custom-local-gateway`, not the default
`istio: knative-local-gateway`, you must update gateway instance `knative-local-gateway` in the `knative-serving` namespace:

```bash
kubectl edit gateway knative-local-gateway -n knative-serving
```

Replace the label selector with the label of your service:

```
istio: knative-local-gateway
```

For the service mentioned earlier, it should be updated to:

```
custom: custom-local-gateway
```

If there is a change in service ports (compared to that of
`knative-local-gateway`), update the port info in the gateway accordingly.


## Verifying your Istio installation

View the status of your Istio installation to make sure the installation was
successful. You can use `istioctl` to verify the installation:

```bash
istioctl verify-install
```


## Istio resources

- For the official Istio installation guide, see the
  [Istio Kubernetes Getting Started Guide](https://istio.io/docs/setup/kubernetes/).

- For the full list of available configs when installing Istio with `istioctl`, see
  the
  [Istio Installation Options reference](https://istio.io/docs/setup/install/istioctl/).

## Clean up Istio

See the [Uninstall Istio](https://istio.io/docs/setup/install/istioctl/#uninstall-istio).

## What's next

- View the [Knative Serving documentation](../serving/README.md).
- Try some Knative Serving [code samples](../samples/README.md).

[1]: https://istio.io/docs/concepts/security/#mutual-tls-authentication
[2]: https://istio.io/docs/tasks/security/authz-http/
[3]:
https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#automatic-sidecar-injection
[4]:
  https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#manual-sidecar-injection
