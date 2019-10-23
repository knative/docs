---
title: "Installing Knative with Ambassador"
linkTitle: "Ambassador API Gatway and Knative"
weight: 15
type: "docs"
---

[Ambassador](https://www.getambassador.io/) is a popular Kubernetes-native,
open-source API gateway built on [Envoy Proxy](https://www.envoyproxy.io/).

This guide walks you through the installation of the latest version of Knative
using pre-built images.

## Before you Begin

Knative requires a Kubernetes cluster v1.14 or newer, as well as a compatible
`kubectl`.

This guide assumes that you have already
[created a Kubernetes cluster](https://kubernetes.io/docs/setup/) and are using
bash in a Mac or Linux environment.

## Install Knative

First, let's install Knative to manage our serverless applications.

The following commands install all available Knative components as well as the
standard set of observability plugins. To customize your Knative installation,
see Performing a Custom Knative Installation.

1.  To install Knative, first install the CRDs by running the following
    `kubectl apply` command. This prevents race conditions during the install,
    which cause intermittent errors:

        kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving-crds.yaml

2.  To complete the install of Knative and its dependencies, next run the
    following `kubectl apply` command:

        kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving-core.yaml

3.  Monitor the Knative namespaces and wait until all of the pods come up with a
    `STATUS` of `Running`:

    ```
    kubectl get pods -w --all-namespaces
    ```

## Install Ambassador

Knative was originally built using Istio to handle cluster networking. While the
Istio gateway provides the functionality needed to serve requests to your
application, installing a service mesh just to handle north-south traffic
carries some operational overhead with it. Ambassador provides a way to get
traffic to your Knative application without the overhead or complexity of a full
service mesh.

You can install Ambassador with `kubectl`:

```
kubectl apply \
  --filename https://getambassador.io/yaml/ambassador/ambassador-knative.yaml \
  --filename https://getambassador.io/yaml/ambassador/ambassador-service.yaml
```

## Configuring DNS

Installing Ambassador will create a Kubernetes Service with type `LoadBalancer`.
This may take some time to get an IP address assigned, during this process it
will appear as `<pending>`. You must wait for this IP address to be assigned
before DNS may be set up.

Get this external IP address with:

```
$ kubectl get svc ambassador

NAME         TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
ambassador   LoadBalancer   10.59.246.30   35.229.120.99   80:32073/TCP   13m

```

This external IP can be used with your DNS provider with a wildcard `A` record;
however, for a basic functioning DNS setup (not suitable for production!) this
external IP address can be added to the `config-domain` ConfigMap in
`knative-serving`. You can edit this with the following command:

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
  35.229.120.99.xip.io: ""
```

## Deploying an Application

Now that Knative and Ambassador are running, you can use them to manage and
route traffic to a serverless application.

1. Create a `Knative Service`

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

2. Send a request

   `Knative Service`s are exposed via a `Host` header assigned by Knative. By
   default, Knative will assign the `Host`:
   `{service-name}.{namespace}.{the domain we setup above}`. You can see this
   with:

   ```
   $ kubectl get ksvc helloworld-go
   NAME            URL                                                LATESTCREATED         LATESTREADY           READY     REASON
   helloworld-go   http://helloworld-go.default.34.83.124.52.xip.io   helloworld-go-nwblj   helloworld-go-nwblj   True
   ```

   You can send a request to the `helloworld-go` service with curl using the
   `URL` given above:

   ```
   $ curl http://helloworld-go.default.34.83.124.52.xip.io

   Hello Go Sample v1!
   ```

Congratulations! You have successfully installed Knative with Ambassador to
manage and route to serverless applications!

## What's next

- Try the
  [Getting Started with App Deployment guide](../serving/getting-started-knative-app/)
  for Knative serving.
- Get started with Knative Eventing by walking through one of the
  [Eventing Samples](../eventing/samples/).
