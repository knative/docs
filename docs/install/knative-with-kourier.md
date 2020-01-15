---
title: "Installing Knative with Kourier"
linkTitle: "Kourier Ingress and Knative"
weight: 15
type: "docs"
---

[Kourier](https://github.com/3scale/kourier) is an open-source lightweight Knative Ingress based on Envoy. It's been designed for Knative, without requiring any additional custom resource definitions (CRDs).

This guide walks you through the installation of the latest version of Knative
with Kourier as the ingress.

## Before you Begin

Knative requires a Kubernetes cluster v1.14 or newer, as well as a compatible `kubectl`. This guide assumes that you have already [created a Kubernetes cluster](https://kubernetes.io/docs/setup/) and are using
bash in a Mac or Linux environment.

## Install Knative

Let's do a core install of Knative Serving with the released yaml templates:

1.  To install Knative, first install the CRDs by running the following `kubectl apply`
    command. This prevents race conditions during the install, which cause intermittent errors:

        kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving-crds.yaml

1.  To complete the install of Knative and its dependencies, next run the
    following `kubectl apply` command:

        kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving-core.yaml

1.  Monitor the Knative Serving namespace and wait until all of the pods come up with a
    `STATUS` of `Running`:

    ```
    kubectl get pods -w -n knative-serving
    ```


## Install Kourier

Knative default installation uses Istio to handle internal and external traffic. If you are just interested in exposing Knative applications to the external network, a service mesh adds overhead and increases the system complexity. Kourier provides a way to expose your Knative application in a more simple and lightweight way.

You can install Kourier with `kubectl`:

```
kubectl apply \
  --filename https://raw.githubusercontent.com/3scale/kourier/master/deploy/kourier-knative.yaml
```

## Configuring the Knative ingress class

Kourier only exposes ingresses that have the "kourier" ingress class. By default Knative annotates all the ingresses for Istio but you can change that by patching the "config-network" configmap as follows: 

```
kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
```

## Configuring DNS

Installing Kourier will create a Kubernetes Service with type `LoadBalancer`.
This may take some time to get an IP address assigned, during this process, it
will appear as `<pending>`.  You must wait for this IP address to be assigned
before DNS may be set up.

To get the external IP address, use the following command:

```
kubectl get svc kourier -n kourier-system

NAME         TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
kourier      LoadBalancer   10.43.242.100  172.22.0.2      80:31828/TCP   19m

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
  172.22.0.2.xip.io: ""
```

## Deploying an Application

Now that Kourier is running and Knative is configured properly, you can go ahead and create your first Knative application:

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

1. Send a request

   `Knative Service`s are exposed via a `Host` header assigned by Knative. By
   default, Knative will assign the `Host`:
   `{service-name}.{namespace}.{the domain we have setup above}`.  You can see this
   with:

   ```
   $ kubectl get ksvc helloworld-go
   NAME            URL                                                LATESTCREATED         LATESTREADY           READY     REASON
   helloworld-go   http://helloworld-go.default.172.22.0.2.xip.io   helloworld-go-ps7lp   helloworld-go-ps7lp   True
   ```

   You can send a request to the `helloworld-go` service with curl
   using the `URL` given above:

   ```
   $ curl http://helloworld-go.default.172.22.0.2.xip.io

   Hello Go Sample v1!
   ```

Congratulations! You have successfully installed Knative with Kourier to manage and route your serverless applications!

## What's next

- Try the
  [Getting Started with App Deployment guide](../serving/getting-started-knative-app.md)
  for Knative serving.
- Get started with Knative Eventing by walking through one of the
  [Eventing Samples](../eventing/samples/).
