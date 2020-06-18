---
title: "Configuring Istio mTLS on Knative Serving"
linkTitle: "Configuring Istio mTLS on Knative Serving"
date: 2020-06-15
description: "How to configure Istio mTLS on Knative Serving"
type: "blog"
---

Knative Serving has some special network routings. The activator is placed in the middle of networking route. The client requests pass through the ingress gateway. Therefore when you enabled some policy configurations like Istio mTLS, you need to be careful about it. In this post, I will explain 1) the network routing in Knative Service and 2) How to configure Istio mTLS with step by step example.

## Before you begin

This blog post used Istio 1.6.1 and Knative Serving 1.5. With different version, some manifest (e.g. IstioOperator) does not work or you might get different error messages.

## Network routing in Knative Service

### mesh mode vs non-mesh mode

Let's start talking about the networking routing in Knative Serving. The network route depends on istio's sidecar injection (mesh mode) or no-sidecar injection (no-mesh mode).

In no-mesh mode, the access from external and internal both pass through gateways. When the request came from external, ingress gateway forwards the request to activator and then reach out to your application. The internal access is same. A local gateway forwards the request to activator and then reach out to your application.

![no-mesh](/blog/articles/images/no-mesh-network.jpg "External(left) and Internal(right) access in no-mesh mode")

_Figure 1. External(left) and Internal(right) access in no-mesh mode_

In mesh mode, although the external access is same with no-mesh mode, the internal access is different. The internal access does not pass through cluster-local-gateway. Instead, it uses VirtualService's mesh routing internally and reach out to your knative service.

![mesh](/blog/articles/images/mesh-network.jpg "External(left) and Internal(right) access in mesh mode")

_Figure 2. External(left) and Internal(right) access in mesh mode_

When you want to leverage the secure access with mTLS on Knative, you must use mesh mode. But it is important to understand both of them.

### Access from system components to your services

In addition to these network routings, you need to take of some request from serving's system components in knative-serving namespace to your application. As we have already seen, the activator is the one of them. The activator is a kind of reverse proxy to your application from outside. Also autoscaler pod collects metrics information from your service.

Finally, Knative uses webhook. Although it does not access to your applications, Kubernetes which is in out side of istio world accesses to the webhook.

Understanding of these network routing and system access are the key to success of Istio configuration.

## Enabling mTLS on Knative

Let's try to enable mTLS on the cluster step by step.

### Step 1: Enable sidecar injection on system namespace and user namespace

The first step is that enabling sidecar injection on the cluster. As explained above, your knative application pods and knative system pods are communicating each other and so we have to enable sidecar injection on both pods. Although there are several ways to enable it, this post assumed that your IstioOperator sets `values.global.proxy.autoInject=true`.

_e.g `values.global.proxy.autoInject=true` in IstioOperator_

```yaml
kind: IstioOperator
spec:
  values:
    global:
      proxy:
        autoInject: enabled
```

Additionally `enableAutoMtls` is set to `true` in this post.

```yaml
  meshConfig:
    enableAutoMtls: true
```

If you set it to `false`, you need to configuring DestinationRules for each outbound mutual TLS traffic to the service.

The full IstioOperator could be found [here](https://gist.github.com/nak3/1f533b1a8be1bdd891e9b2fd8bebb40a).
By the way, you can install Knative Serving by using [Installing Knative](https://knative.dev/docs/install/any-kubernetes-cluster/) as usual.

Then you can trigger the injection by adding `istio-injection=enabled` label to the system namespace.

_e.g. command to the injection label_

```bash
$ kubectl label namespace knative-serving istio-injection=enabled

$ kubectl get namespace -n knative-serving --show-labels  knative-serving serving-tests
NAME              STATUS   AGE   LABELS
knative-serving   Active   19m   istio-injection=enabled,serving.knative.dev/release=devel
```

As webhook and istio-webhook are accessed by Kubernetes which is non mesh world, let's disable the sidecar injection on them.

```
kubectl patch deployments.apps -n knative-serving webhook -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"false"}}}}}'
kubectl patch deployments.apps -n knative-serving istio-webhook -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"false"}}}}}'
```

You can check your system pods are running with sidecar by the output of `2/2` for `READY` column. If not, please restart pods in knative-serving namespace.

_e.g. command to confirm system pods have sidecar_

```bash
$ kubectl get pod -n knative-serving
NAME                                  READY   STATUS    RESTARTS   AGE
activator-7f77bdbcdb-xh79h            2/2     Running   0          18m
autoscaler-546dd95779-mqtjh           2/2     Running   0          18m
autoscaler-hpa-56b5bf5998-qlp7k       2/2     Running   0          18m
controller-5844b9575d-qqgbg           2/2     Running   0          18m
istio-webhook-5c5c7569fc-hnk4k        1/1     Running   0          18m
networking-istio-59ff77d49f-kglsw     1/1     Running   0          18m
networking-ns-cert-849b87d778-2b9sw   2/2     Running   0          18m
webhook-754f8bc47f-wghnv              1/1     Running   1          17m
```

Please note that networking-istio pod disabled the injection by its manifest.

We need to enable the injection on your application namespace with the same way. The following example uses `serving-tests` namespace for test.

_e.g. command to create user namespace with injection label_

```bash
$ kubectl create namespace serving-tests
$ kubectl label namespace serving-tests istio-injection=enabled
```

### Step 2: Enable STRICT mTLS on entire mesh

To apply mTLS STRICT mode globally, you can create `PeerAuthentication` with name `default` in `istio-system` namespace.

_e.g. command to enable Istio mTLS globally_

```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
  namespace: "istio-system"
spec:
  mtls:
    mode: STRICT
EOF
```

### Step 3: Access to your application

Now you can deploy your Knative application. Let's access to it.

_e.g command to request from another pod to knative app_

```bash
$ kubectl exec  -it $POD -c sleep -- curl -s hello-example.serving-tests.svc.cluster.local
Hello World!
```

## FAQ

### Is it possible to communicate from no sidecar pod to knative service under mTLS?

Yes. From no-sidecar pod to Knative Service passes through cluster-local-gateway as explained in [mesh mode vs non-mesh mode](#mesh-mode-vs-non-mesh-mode). So the access works fine with cluster-local-gateway if you deployed cluster-local-gateway with envoy proxy. That is different behavior from non Knative Service.
