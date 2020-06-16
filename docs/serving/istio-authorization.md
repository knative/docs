---
title: "Knative application under the strict authorization policy"
weight: 25
type: "docs"
---

When you deployed app to Knative Serving, serving system pods such as activator and autoscaler access to your app.
Hence, you have to allow the requests to your app when you configure security features such as istio authorization policy.

> Tip: This example assumes that your application enabled istio sidecar injection.
>
> ```
> $ kubectl create namespace serving-tests
> $ kubectl label namespace serving-tests istio-injection=enabled
> ```
> The following policy example does not work without sidecar injection.

For example, the following authorization policy denies all requests to workloads in namespace serving-tests.

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

Then, the following policy allows the request to `/` for your application.

```
$ cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-app
  namespace: serving-tests
spec:
  action: ALLOW
  rules:
  - to:
    - operation:
        paths:
        - /     # The path for your application.
EOF
```

It generally works with Kubernetes application, but it does not work with Knative application.

```
$ kn service create hello-example --image=gcr.io/knative-samples/helloworld-go
$ curl http://hello-example.default.52.76.125.95.nip.io
(hang up)
```

To access your application, you need to configure "whitelist" for the requests from system pods.
There are several solutions but this section is going to explain two typical solutions
[Allow access from system pods by paths](#allow-access-from-system-pods-by-paths) and
[Allow access from system pods by namespace](#allow-access-from-system-pods-by-namespace).

### Allow access from system pods by paths

Knative system pods access to your applcation by using the following paths.

- `/metrics`
- `/health`

The /metrics path allows the autoscaler pod to collect metrics.
The /health path allows system pods to probe the service."

You can add the `/metrics` and `/health` paths to the AuthorizationPolicy as shown in the example:

```
$ cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: whitelist-by-paths
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

### Allow access from system pods by namespace

You can allow access for all pods in the `knative-serving` namespace, as shown in the example:

```
$ cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: whitelist-by-namespace
  namespace: serving-tests
spec:
  action: ALLOW
  rules:
  - from:
    - source:
       namespaces: ["knative-serving"]
  rules:
  - to:
    - operation:
        paths:
        - /     # The path for your application.
EOF
```
