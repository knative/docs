---
title: "Installing Istio for Knative"
linkTitle: "Ambassador API Gatway and Knative"
weight: 15
type: "docs"
---

[Ambassador](https://www.getambassador.io/) is a popular, Kubernetes native,
 open-source API gateway and the most popular distrbution of 
 [Envoy Proxy](https://www.envoyproxy.io/).

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

## Install Ambassador

Knative was originally built using Istio to handle cluster networking. While 
the Istio gateway provides the functionality we need to serve requests to our 
application, needing to install a service mesh to handle north-south traffic 
brings some operational overhead. Ambassador provides a way to get traffic to 
your Knative application without the overhead of a full service mesh.

You can easily install Ambassador as your ingress controller using two 
`kubectl` commands:

```
kubectl apply -f https://getambassador.io/yaml/ambassador/ambassador-knative.yaml
kubectl apply -f https://getambassador.io/yaml/ambassador/ambassador-service.yaml
```

Ambassador will watch for and create routes based off of Knative 
`ClusterIngress` resources. These will then be accessible over the external IP 
address of the Ambassador service we just created.

Get this external IP address and save it in a variable named `AMBASSADOR_IP`

```
$ kubectl get svc ambassador

NAME         TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
ambassador   LoadBalancer   10.59.246.30   35.229.120.99   80:32073/TCP   13m

$ AMBASSADOR_IP=35.229.120.99
```

## Install Knative

Now that we have Ambassador installed to handle ingress to our serverless 
applications we need to install Knative to manage them.

The following commands install all available Knative components as well as the 
standard set of observability plugins. To customize your Knative installation, 
see Performing a Custom Knative Installation.

1. To install Knative, first install the CRDs by running the `kubectl apply` 
command once with the `-l knative.dev/crd-install=true` flag. This prevents 
race conditions during the install, which cause intermittent errors:

    ```
    kubectl apply -l knative.dev/crd-install=true \
    --filename https://github.com/knative/serving/releases/download/v0.7.1/serving.yaml \
    --filename https://github.com/knative/build/releases/download/v0.7.1/build.yaml \
    --filename https://github.com/knative/serving/releases/download/v0.7.1/monitoring.yaml
    ```
2. To complete the install of Knative and it's dependencies, run the 
`kubectl apply` command again, this time without the 
`-l knative.dev/crd-install=true`:

    ```
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.1 serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager \
    --filename https://github.com/knative/build/releases/download/v0.7.1/build.yaml \
    --filename https://github.com/knative/serving/releases/download/v0.7.1/monitoring.yaml
    ```
   > **Notes**:
   >
   > - By default, the Knative Serving component installation (`serving.yaml`)
   >   includes a controller for
   >   [enabling automatic TLS certificate provisioning](../serving/using-auto-tls.md).
   >   If you do intend on immediately enabling auto certificates in Knative,
   >   you can remove the
   >   `--selector networking.knative.dev/certificate-provider!=cert-manager`
   >   statement to install the controller. Otherwise, you can choose to install
   >   the auto certificates feature and controller at a later time.

3. Monitor the Knative namespaces and wait until all of the pods come up with
 a `STATUS` of `Running`:

    ```
    kubectl get pods -w --all-namespaces
    ```

## Deploying an Application

Now that we have Knative and Ambassador running, we can use them to manage and 
route traffic to a serverless application.

1. Create a `Knative Service`

   For this demo, we will use a simple helloworld application written in go. 
   Copy the YAML below to a file called `helloworld-go.yaml` and apply it 
   with `kubectl`

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

    `Knative Service`s are exposed via a `Host` header assigned by Knative. 
    By default, Knative will assign the 
    `Host`: `{service-name}.{namespace}.example.com`. You can verify this by 
    checking the `EXTERNAL-IP` of the `helloworld-go` service we created above.

    ```
    $ kubectl get service helloworld-go

    NAME            TYPE           CLUSTER-IP   EXTERNAL-IP                         PORT(S)   AGE
    helloworld-go   ExternalName   <none>       helloworld-go.default.example.com   <none>    32m
    ```

    Ambassador will use this `Host` header to route requests to the correct 
    service. We can send a request to the `helloworld-go` service with curl 
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
- Take a look at the rest of what 
  [Knative has to offer](https://knative.dev/docs/index.html)


