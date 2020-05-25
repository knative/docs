---
title: "Setting up custom ingress gateway"
linkTitle: "Configuring the ingress gateway"
weight: 55
type: "docs"
---

Knative uses a shared ingress Gateway to serve all incoming traffic within
Knative service mesh, which is the `knative-ingress-gateway` Gateway under
`knative-serving` namespace. By default, we use Istio gateway service
`istio-ingressgateway` under `istio-system` namespace as its underlying service.
You can replace the service with that of your own as follows.

## Step 1: Create Gateway Service and Deployment Instance

You'll need to create the gateway service and deployment instance to handle
traffic first. Let's say you customized the default `istio-ingressgateway` to
`custom-ingressgateway` as follows.

```yaml
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
      - name: custom-ingressgateway
        enabled: true
        namespace: custom-ns
        label:
          istio: custom-gateway
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
```

## Step 2: Update Knative Gateway

Update gateway instance `knative-ingress-gateway` under `knative-serving`
namespace:

```shell
kubectl edit gateway knative-ingress-gateway -n knative-serving
```

Replace the label selector with the label of your service:

```
istio: ingressgateway
```

For the service above, it should be updated to:

```
istio: custom-gateway
```

If there is a change in service ports (compared with that of
`istio-ingressgateway`), update the port info in the gateway accordingly.

## Step 3: Update Gateway Configmap

Update gateway configmap `config-istio` under `knative-serving`
namespace:

```shell
kubectl edit configmap config-istio -n knative-serving
```

Replace the `istio-ingressgateway.istio-system.svc.cluster.local` field with
the fully qualified url of your service.

```
gateway.knative-serving.knative-ingress-gateway: "istio-ingressgateway.istio-system.svc.cluster.local"
```

For the service above, it should be updated to:

```
gateway.knative-serving.knative-ingress-gateway: custom-ingressgateway.custom-ns.svc.cluster.local
```
