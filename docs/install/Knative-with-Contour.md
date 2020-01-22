---
title: "Knative Install using Contour on a Kubernetes Cluster"
linkTitle: "Contour"
weight: 10
type: "docs"
---

Learn how to deploy Contour and Knative to your Kubernetes cluster.

[Contour](https://projectcontour.io/) is an open source Kubernetes ingress controller providing the control plane for the Envoy edge and service proxy.

## Before you begin

Knative requires a Kubernetes cluster v1.15 or newer, as well as a compatible
`kubectl`.  This guide assumes that you've already created a Kubernetes cluster,
and that you are using bash in a Mac or Linux environment; some commands will
need to be adjusted for use in a Windows environment.

## Installing Knative Serving

First, let's install Knative to manage our serverless applications.

The following commands install the Knative Serving components:

1.  To install Knative, first install the CRDs by running the following `kubectl apply`
    command. This prevents race conditions during the install, which cause intermittent errors:

        kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving-crds.yaml

1.  To complete the install of Knative and its dependencies, next run the
    following `kubectl apply` command:

        kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving-core.yaml

1.  Monitor the `knative-serving` namespaces and wait until all of the pods come up with a
    `STATUS` of `Running`:

    ```
    kubectl get pods -w --all-namespaces
    ```

### Installing Contour for Knative

Contour is installed in the namespace `projectcontour` with an additional controller in `knative-serving` to bridge the two.

To install Contour, enter the following command:

        kubectl apply --filename https://raw.githubusercontent.com/knative/serving/{{< version >}}/third_party/contour-latest/contour.yaml


To configure Knative Serving to use Contour, add the following key to
the `config-network` config map in `knative-serving`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-network
  namespace: knative-serving
data:
  ingress.class: contour.ingress.networking.knative.dev
```

Enter the following command to add the key:

        kubectl edit --namespace knative-serving config-network



## Configuring DNS

Knative dispatches to different services based on their hostname, so it greatly
simplifies things to have DNS properly configured. For this, we must look up the
external IP address that Contour received. This can be done with the following command:

```
$ kubectl get svc -n projectcontour
NAME               TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE
contour-external   ClusterIP      10.3.2.96     <none>          8001/TCP                     29d
contour-internal   ClusterIP      10.3.9.254    <none>          8001/TCP                     29d
envoy-external     LoadBalancer   10.3.12.166   35.235.99.116   80:31093/TCP,443:31196/TCP   29d
envoy-internal     ClusterIP      10.3.11.69    <none>          80/TCP                       29d
```


This external IP can be used with your DNS provider with a wildcard `A` record;
however, for a basic functioning DNS setup (not suitable for production!) this
external IP address can be used with `xip.io` in the `config-domain` ConfigMap
in `knative-serving`. Enter the following command to edit the ConfigMap:


```
kubectl edit cm config-domain --namespace knative-serving
```

Given the external IP above, change the content to:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
data:
  # xip.io is a "magic" DNS provider, which resolves all DNS lookups for:
  # *.{ip}.xip.io to {ip}.
  35.235.99.116.xip.io: ""
```


## Running Knative apps

Now that your cluster has Contour and Knative installed, you can run serverless applications with Knative.

Let's deploy an app to test that everything is set up correctly:


1. Create a `Knative Service`.

   For this demo, a simple helloworld application written in go will be used.
   Copy the YAML below to a file called `helloworld-go.yaml` and apply it with
   `kubectl`

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-go
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: gcr.io/knative-samples/helloworld-go
             env:
               - name: TARGET
                 value: Go Sample v1
   ```

   ```
   kubectl apply -f helloworld-go.yaml
   ```

1. Send a request

   **Knative Services** are exposed via the *Host* header assigned by Knative. By
   default, Knative will use the header `Host`:
   `{service-name}.{namespace}.{the domain we setup above}`. You can see this with:

   ```
   $ kubectl get ksvc helloworld-go
   NAME            URL                                                 LATESTCREATED         LATESTREADY           READY     REASON
   helloworld-go   http://helloworld-go.default.35.235.99.116.xip.io   helloworld-go-nwblj   helloworld-go-nwblj   True
   ```

   You can send a request to the `helloworld-go` service with curl using the `URL` given above:

   ```
   $ curl http://helloworld-go.default.35.235.99.116.xip.io

   Hello Go Sample v1!
   ```

You have successfully installed Knative with Contour to manage and route to serverless applications!

## What's next

Now that your cluster has Knative installed, you can see what Knative has to
offer.

Learn more about deploying apps to Knative with the
[Getting Started with Knative App Deployment](../serving/getting-started-knative-app.md)
guide.

To get started with Knative Eventing, pick one of the
[Eventing Samples](../eventing/samples/) to walk through.
