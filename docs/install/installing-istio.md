---
title: "Installing Istio for Knative"
weight: 15
type: "docs"
---

This guide walks you through manually installing and customizing Istio for use
with Knative.

If your cloud platform offers a managed Istio installation, we recommend
installing Istio that way, unless you need the ability to customize your
installation. If your cloud platform offers a managed Istio installation, the
[install guide](./README.md) for your specific platform will have those
instructions.

## Before you begin

You need:

- A Kubernetes cluster created.
- [`istioctl`](https://istio.io/docs/setup/install/istioctl/) (v1.5.4 or later) installed.

## Installing Istio

When you install Istio, there are a few options depending on your goals. For a
basic Istio installation suitable for most Knative use cases, follow the
[Installing Istio without sidecar injection](#installing-istio-without-sidecar-injection)
instructions. If you're familiar with Istio and know what kind of installation
you want, read through the options and choose the installation that suits your
needs.

You can easily customize your Istio installation with `istioctl`. The below sections
cover a few useful Istio configurations and their benefits.

### Choosing an Istio installation

You can install Istio with or without a service mesh:

- [Installing Istio without sidecar injection](#installing-istio-without-sidecar-injection)(Recommended
     default installation)

- [Installing Istio with sidecar injection](#installing-istio-with-sidecar-injection)

If you want to get up and running with Knative quickly, we recommend installing
Istio without automatic sidecar injection. This install is also recommended for
users who don't need the Istio service mesh, or who want to enable the service
mesh by [manually injecting the Istio sidecars][1].

#### Installing Istio without sidecar injection

Enter the following command to install Istio:

```shell
cat << EOF > ./istio-minimal-operator.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      proxy:
        autoInject: disabled
      useMCP: false
      # The third-party-jwt is not enabled on all k8s.
      # See: https://istio.io/docs/ops/best-practices/security/#configure-third-party-service-account-tokens
      jwtPolicy: first-party-jwt

  addonComponents:
    pilot:
      enabled: true
    prometheus:
      enabled: false

  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
      - name: cluster-local-gateway
        enabled: true
        label:
          istio: cluster-local-gateway
          app: cluster-local-gateway
        k8s:
          service:
            type: ClusterIP
            ports:
            - port: 15020
              name: status-port
            - port: 80
              name: http2
            - port: 443
              name: https
EOF

istioctl manifest apply -f istio-minimal-operator.yaml
```

#### Installing Istio with sidecar injection

If you want to enable the Istio service mesh, you must enable [automatic sidecar
injection][2]. The Istio service mesh provides a few benefits:

- Allows you to turn on [mutual TLS][3], which secures service-to-service
  traffic within the cluster.

- Allows you to use the [Istio authorization policy][4], controlling the access
  to each Knative service based on Istio service roles.

To automatic sidecar injection, set `autoInject: enabled` in addition to above
operator configuration.

```
    global:
      proxy:
        autoInject: enabled
```

#### Using Istio mTLS feature

Since there are some networking communications between knative-serving namespace
and the namespace where your services running on, you need additional
preparations for mTLS enabled environment.

- Enable sidecar container on `knative-serving` system namespace.

```bash
kubectl label namespace knative-serving istio-injection=enabled
```

- Set `PeerAuthentication` to `PERMISSIVE` on knative-serving system namespace.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
  namespace: "knative-serving"
spec:
  mtls:
    mode: PERMISSIVE
EOF
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

- [Install Knative](./README.md).
- Try the
  [Getting Started with App Deployment guide](../serving/getting-started-knative-app.md)
  for Knative serving.

[1]:
  https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#manual-sidecar-injection
[2]:
  https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#automatic-sidecar-injection
[3]: https://istio.io/docs/concepts/security/#mutual-tls-authentication
[4]: https://istio.io/docs/tasks/security/authz-http/
