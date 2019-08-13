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

Knative requires a Kubernetes cluster v1.11 or newer with the
[MutatingAdmissionWebhook admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#how-do-i-turn-on-an-admission-controller)
enabled.

`kubectl` v1.10 is also required.

This guide assumes that you have already
[created a Kubernetes cluster](https://kubernetes.io/docs/setup/) and are using
bash in a Mac or Linux environment.

## Install Knative

First, let's install Knative to manage our serverless applications.

The following commands install all available Knative components as well as the
standard set of observability plugins. To customize your Knative installation,
see Performing a Custom Knative Installation.

1.  To install Knative, first install the CRDs by running the `kubectl apply`
    command once with the `-l knative.dev/crd-install=true` flag. This prevents
    race conditions during the install, which cause intermittent errors:

        kubectl apply -l knative.dev/crd-install=true \
        --filename https://github.com/knative/serving/releases/download/v0.7.1/serving.yaml \
                --filename https://github.com/knative/serving/releases/download/v0.7.1/monitoring.yaml

2.  To complete the install of Knative and it's dependencies, run the
    `kubectl apply` command again, this time without the
    `-l knative.dev/crd-install=true`:

        kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.1 serving.yaml \
                --filename https://github.com/knative/serving/releases/download/v0.7.1/monitoring.yaml

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
kubectl apply -f https://getambassador.io/yaml/ambassador/ambassador-knative.yaml
kubectl apply -f https://getambassador.io/yaml/ambassador/ambassador-service.yaml
```

Ambassador will watch for and create routes based off of Knative
`ClusterIngress` resources. These will then be accessible over the external IP
address of the Ambassador service you just created.

Get this external IP address and save it in a variable named `AMBASSADOR_IP`

```
$ kubectl get svc ambassador

NAME         TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
ambassador   LoadBalancer   10.59.246.30   35.229.120.99   80:32073/TCP   13m

$ AMBASSADOR_IP=35.229.120.99
```

## Deploying an Application

Now that Knative and Ambassador are running, you can use them to manage and
route traffic to a serverless application.

1. Create a `Knative Service`

   For this demo, a simple helloworld application written in go will be used.
   Copy the YAML below to a file called `helloworld-go.yaml` and apply it with
   `kubectl`

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
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
   `{service-name}.{namespace}.example.com`. You can verify this by checking the
   `EXTERNAL-IP` of the `helloworld-go` service created above.

   ```
   $ kubectl get service helloworld-go

   NAME            TYPE           CLUSTER-IP   EXTERNAL-IP                         PORT(S)   AGE
   helloworld-go   ExternalName   <none>       helloworld-go.default.example.com   <none>    32m
   ```

   Ambassador will use this `Host` header to route requests to the correct
   service. You can send a request to the `helloworld-go` service with curl
   using the `Host` and `AMBASSADOR_IP` from above:

   ```
   $ curl -H "Host: helloworld-go.default.example.com" $AMBASSADOR_IP

   Hello Go Sample v1!
   ```

Congratulations! You have successfully installed Knative with Ambassador to
manage and route to serverless applications!

## What's next

- Try the
  [Getting Started with App Deployment guide](./getting-started-knative-app/)
  for Knative serving.
- Get started with Knative Eventing by walking through one of the
  [Eventing Samples](../eventing/samples/).
- [Install Cert-Manager](../serving/installing-cert-manager.md) if you want to use the
  [automatic TLS cert provisioning feature](../serving/using-auto-tls.md).
