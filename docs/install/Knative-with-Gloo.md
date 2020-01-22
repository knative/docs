---
title: "Knative Install using Gloo on a Kubernetes Cluster"
linkTitle: "Gloo"
weight: 10
type: "docs"
---

Learn how to deploy Gloo and Knative to your Kubernetes cluster using the Gloo command line tool `glooctl`.
 

[Gloo](https://docs.solo.io/gloo/latest/) is a popular open-source Envoy control plane and API gateway built for Kubernetes (and other platforms). 

Gloo provides a complete gateway replacement for Istio and supports the full Knative Ingress spec. Choose Gloo if you don't require a service mesh in your cluster and want a lightweight alternative that requires less resource usage and operational overhead.

## Before you begin

Knative requires a Kubernetes cluster v1.15 or newer, as well as a compatible
`kubectl`. This guide assumes that you've already created a Kubernetes cluster
which you're comfortable installing _alpha_ software on.

This guide assumes you are using bash in a Mac or Linux environment; some commands will need to be adjusted for use in a Windows environment.

## Installing Glooctl

Gloo's CLI tool `glooctl` makes it easy to install both Gloo and Knative without the need to use [Helm](https://helm.sh) or multiple manifests.  Let's go ahead and download `glooctl`:

```shell
curl -sL https://run.solo.io/gloo/install | sh
```

Alternatively, you can download the Gloo CLI directly via
[the github releases](https://github.com/solo-io/gloo/releases) page.

Next, add `glooctl` to your path with:

```shell
export PATH=$HOME/.gloo/bin:$PATH
```

Verify the CLI is installed and running correctly with:

```shell
glooctl version
```

### Deploying Gloo and Knative to your cluster

Finally, install Gloo and Knative in a single command with `glooctl`:

```shell
glooctl install knative
```

The `glooctl install knative` command can be customized with a variety of options:
- use `--install-knative-version` to set the installed version of Knative Serving (defaults to `0.8.0`)
- use `--install-build` to install Knative Build
- use `--install-eventing` to install Knative Eventing
- use `--dry-run` to produce the kubernetes YAML that would be applied to your cluster rather than applying.
- use `--install-knative=false` to only install Gloo without installing Knative components. This can be used if you wish to install Knative independently of Gloo.

See https://github.com/solo-io/gloo/blob/master/docs/cli/glooctl_install_knative.md for the full list of available options for installing Knative with `glooctl`

> Note: `glooctl` generates a manifest which can be piped to stdout or a file using the `--dry-run` flag. Alternatively,
Gloo can be installed via its [Helm Chart](https://docs.solo.io/gloo/latest/installation/gateway/kubernetes/#installing-on-kubernetes-with-helm), which will permit fine-grained configuration of installation parameters.

Monitor the Gloo and Knative components until each one shows a `STATUS` of `Running` or `Completed`:

```shell
kubectl get pods --namespace gloo-system
kubectl get pods --namespace knative-serving
```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> commands to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

Now you can deploy an app using your freshly installed Knative environment.

## Configuring DNS

Knative dispatches to different services based on their hostname, so it greatly
simplifies things to have DNS properly configured. For this, we must look up the
external IP address that Gloo received. This can be done with the following command:

```
$ kubectl get svc -ngloo-system
NAME                     TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)                      AGE
gloo                     ClusterIP      10.0.11.200   <none>         9977/TCP                     9m50s
knative-external-proxy   LoadBalancer   10.0.15.230   34.83.80.117   80:30351/TCP,443:30157/TCP   9m50s
knative-internal-proxy   ClusterIP      10.0.7.102    <none>         80/TCP,443/TCP               9m50s
```


This external IP can be used with your DNS provider with a wildcard `A` record;
however, for a basic functioning DNS setup (not suitable for production!) this
external IP address can be used with `xip.io` in the `config-domain` ConfigMap
in `knative-serving`. You can edit this with the following command:

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
  34.83.80.117.xip.io: ""
```


## Running Knative apps

Now that your cluster has Gloo & Knative installed, you can run serverless applications with Knative.

Let's deploy an app to test that everything is set up correctly:


1. Next, create a `Knative Service`

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

   **Knative Services** are exposed via the *Host* header assigned by Knative. By
   default, Knative will use the header `Host`:
   `{service-name}.{namespace}.{the domain we setup above}`. You can see this with:

   ```
   $ kubectl get ksvc helloworld-go
   NAME            URL                                                LATESTCREATED         LATESTREADY           READY     REASON
   helloworld-go   http://helloworld-go.default.34.83.80.117.xip.io   helloworld-go-nwblj   helloworld-go-nwblj   True
   ```

   You can send a request to the `helloworld-go` service with curl using the `URL` given above:

   ```
   $ curl http://helloworld-go.default.34.83.124.52.xip.io

   Hello Go Sample v1!
   ```

Congratulations! You have successfully installed Knative with Gloo to manage and route to serverless applications!

## What's next

Now that your cluster has Knative installed, you can see what Knative has to
offer.

Learn more about deploying apps to Knative with the
[Getting Started with Knative App Deployment](../serving/getting-started-knative-app.md)
guide.

To get started with Knative Eventing, pick one of the
[Eventing Samples](../eventing/samples/) to walk through.
