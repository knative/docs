---
title: "Setting up custom ingress gateway"
linkTitle: "Configuring the ingress gateway"
weight: 55
type: "docs"
---

# Setting up custom ingress gateway

Knative uses a shared ingress Gateway to serve all incoming traffic within
Knative service mesh, which is the `knative-ingress-gateway` Gateway under
the `knative-serving` namespace. By default, we use Istio gateway service
`istio-ingressgateway` under `istio-system` namespace as its underlying service.
You can replace the service and the gateway with that of your own as follows.

## Replace the default `istio-ingressgateway` service

### Step 1: Create the gateway service and deployment instance

You'll need to create the gateway service and deployment instance to handle
traffic first. Let's say you customized the default `istio-ingressgateway` to
`custom-ingressgateway` as follows.

```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  components:
    ingressGateways:
      - name: custom-ingressgateway
        enabled: true
        namespace: custom-ns
        label:
          istio: custom-gateway
```

### Step 2: Update the Knative gateway

Update gateway instance `knative-ingress-gateway` under `knative-serving`
namespace:

```bash
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

### Step 3: Update the gateway ConfigMap

Update gateway configmap `config-istio` under `knative-serving`
namespace:

```bash
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

## Replace the knative-ingress-gateway gateway

We customized the gateway service so far, but we may also want to use our own gateway.
We can replace the default gateway with our own gateway with following steps.

### Step 1: Create the gateway

Let's say you replace the default `knative-ingress-gateway` gateway with
`knative-custom-gateway` in `custom-ns`.
First, we create the `knative-custom-gateway` gateway.

```
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: knative-custom-gateway
  namespace: custom-ns
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
EOF
```

!!! note
    Replace the label selector `istio: ingressgateway` with the label of your service.

### Step 2: Update Gateway Configmap

Update gateway configmap `config-istio` under `knative-serving`
namespace:

```bash
kubectl edit configmap config-istio -n knative-serving
```

Replace the `gateway.knative-serving.knative-ingress-gateway` field with
the customized gateway.

```
gateway.knative-serving.knative-ingress-gateway: "istio-ingressgateway.istio-system.svc.cluster.local"
```

For the gateway above, it should be updated to:

```
gateway.custom-ns.knative-custom-gateway: "istio-ingressgateway.istio-system.svc.cluster.local"
```

The configuration format should be `gateway.GATEWAY_NAMESPACE.GATEWAY_NAME`.
The `GATEWAY_NAMESPACE` is optional. when it is omitted, the system will search for
the gateway in the serving system namespace `knative-serving`.
