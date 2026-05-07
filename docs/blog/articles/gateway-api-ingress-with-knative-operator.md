---
title: "Managing Gateway API ingress with the Knative Operator"
linkTitle: "Managing Gateway API ingress with the Knative Operator"
author: "kahirokunn"
author handle: https://github.com/kahirokunn
date: 2026-05-07
description: "How to use the Knative Operator to manage Knative Serving with Gateway API ingress"
type: "blog"
---

# Managing Gateway API ingress with the Knative Operator

**Author: [kahirokunn](https://github.com/kahirokunn)**

_In this blog post you will learn how to use the Knative Operator to manage Knative Serving with Gateway API ingress._

Starting with Knative v1.22, the Knative Operator supports `net-gateway-api` as an ingress option for Knative Serving. If your platform already standardizes on Kubernetes Gateway API resources such as `GatewayClass`, `Gateway`, and `HTTPRoute`, you can now keep the Knative ingress choice and gateway configuration together in the Operator-managed `KnativeServing` custom resource.

Gateway API support in Knative is currently in beta. You must install a Gateway API implementation in your cluster before using `net-gateway-api`. Knative currently tests `net-gateway-api` against the Istio, Contour, and Envoy Gateway implementations. For tested versions, see the `net-gateway-api` [test version documentation](https://github.com/knative-extensions/net-gateway-api/blob/release-1.22/docs/test-version.md).

## What the Operator manages

The Operator does not replace your Gateway API implementation. It works with a Gateway API controller in the cluster, such as Istio, Contour, or Envoy Gateway, and with `Gateway` resources that Knative can use.

The Operator manages the Knative side of the installation. It installs the `net-gateway-api` networking layer, sets the Knative Serving ingress class, and passes gateway configuration into the `config-gateway` ConfigMap through the `KnativeServing` CR.

At a minimum, the `KnativeServing` CR needs to enable the Gateway API networking plugin and set the Serving ingress class:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  ingress:
    gateway-api:
      enabled: true
  config:
    network:
      ingress-class: "gateway-api.ingress.networking.knative.dev"
```

This tells the Operator to install the Gateway API networking plugin and configure Knative Serving to use it. It does not install a Gateway API implementation, and it relies on the default Gateway names unless you configure `spec.config.gateway`.

If `spec.config.gateway` is omitted, `net-gateway-api` falls back to its built-in Istio-oriented gateway names: `istio-system/knative-gateway` for external traffic and `istio-system/knative-local-gateway` for cluster-local traffic. That is only useful when your Gateway API implementation provides those resources. For Envoy Gateway, Contour, or custom Gateway names, configure the gateways explicitly.

## Configure gateways for your environment

Most clusters need more than the minimal ingress selection. Knative also needs to know which external and local gateways it should use.

The `spec.config.gateway` field maps to Knative's `config-gateway` ConfigMap. The values should match the `GatewayClass`, `Gateway`, and Service resources created by your Gateway API implementation.

The following example uses Envoy Gateway with one external gateway and one local gateway. This keeps external and cluster-local traffic on separate Gateway resources:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  ingress:
    gateway-api:
      enabled: true
  config:
    network:
      ingress-class: "gateway-api.ingress.networking.knative.dev"
    gateway:
      external-gateways: |
        - class: eg-external
          gateway: eg-external/eg-external
          service: eg-external/knative-external
          supported-features:
          - HTTPRouteRequestTimeout
      local-gateways: |
        - class: eg-internal
          gateway: eg-internal/eg-internal
          service: eg-internal/knative-internal
          supported-features:
          - HTTPRouteRequestTimeout
    domain:
      example.com: ""
```

## External and local gateways

The external and local gateway settings serve different traffic paths. `external-gateways` is used for routes that should be reachable from outside the cluster. `local-gateways` is used for cluster-local routes, where the Gateway implementation should expose an internal Service such as `ClusterIP`.

Keeping those Gateway resources separate gives platform teams a clearer boundary between public ingress and private in-cluster traffic. In the Envoy Gateway example above, `eg-external/knative-external` is the externally reachable Service, while `eg-internal/knative-internal` is the internal Service for local traffic.

## Verify the route

After applying the `KnativeServing` manifest and waiting for the Operator to finish reconciling Knative Serving, deploy a sample Knative Service and send traffic through the external Gateway. The command below uses `eg-external/knative-external` from the Envoy Gateway configuration above:

```bash
kubectl apply -f - <<'EOF'
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
spec:
  template:
    spec:
      containers:
      - image: gcr.io/knative-samples/helloworld-go
        env:
        - name: TARGET
          value: Go Sample v1
EOF

export LB_IP=$(kubectl -n eg-external get svc knative-external \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -H "Host: helloworld-go.default.example.com" "http://$LB_IP"
```

The response should look like this:

```bash
Hello Go Sample v1!
```

## Conclusion

Gateway API ingress can now be declared as part of the Operator-managed Serving installation, while platform teams keep control over the Gateway API implementation that fits their clusters. Knative Serving, ingress selection, gateway references, and domain configuration can all be reviewed and applied as one `KnativeServing` resource.

For more details, see the [Gateway API tab in the Knative Operator installation documentation](https://knative.dev/docs/install/operator/knative-with-operators/#__tabbed_1_4) and the [KnativeServing CR configuration documentation](https://knative.dev/docs/install/operator/configuring-serving-cr/#configure-the-gateway-api-ingress).
