---
title: "Enabling requests to Knative services when additional authorization policies are enabled"
weight: 25
type: "docs"
---

Knative Serving system pods, such as the activator and autoscaler components, require access to your deployed Knative services.
If you have configured additional security features, such as Istio's authorization policy, you must enable access to your Knative service for these system pods.

## Before you begin

You must meet the following prerequisites to use Istio AuthorizationPolicy:

- [Istio must be used for your Knative Ingress](https://knative.dev/docs/install/any-kubernetes-cluster/#installing-the-serving-component).
- [Istio sidecar injection must be enabled](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/).

## Enabling Istio AuthorizationPolicy

For example, the following authorization policy denies all requests to workloads in namespace `serving-tests`.

```
$ cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: deny-all
  namespace: serving-tests
spec:
  {}
EOF
```

In addition to allowing your application path, you'll need to configure Istio AuthorizationPolicy
to allow health checking and metrics collection to your applications from system pods.
You can allow access from system pods [by paths](#allow-access-from-system-pods-by-paths).

## Allowing access from system pods by paths

Knative system pods access your application using the following paths:

- `/metrics`
- `/healthz`

The `/metrics` path allows the autoscaler pod to collect metrics.
The `/healthz` path allows system pods to probe the service.

You can add the `/metrics` and `/healthz` paths to the AuthorizationPolicy as shown in the example:

```
$ cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allowlist-by-paths
  namespace: serving-tests
spec:
  action: ALLOW
  rules:
  - to:
    - operation:
        paths:
        - /metrics   # The path to collect metrics by system pod.
        - /healthz   # The path to probe by system pod.
EOF
```
