---
title: "Knative Install using Gloo on a Kubernetes Cluster"
linkTitle: "Gloo"
weight: 10
type: "docs"
---

Learn how to deploy Gloo and Knative to your Kubernetes cluster using the Gloo command line tool `glooctl`.
 

[Gloo](https://gloo.solo.io) is a popular open-source Envoy control plane and API gateway built for Kubernetes (and other platforms). 

Gloo provides a complete gateway replacement for Istio and supports the full Knative Ingress spec. Choose Gloo as a lightweight option that requires less resource usage and operational overhead compared to Istio.

## Before you begin

Knative requires a Kubernetes cluster v1.11 or newer with the
[MutatingAdmissionWebhook admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#how-do-i-turn-on-an-admission-controller)
enabled. `kubectl` v1.10 is also required. This guide assumes that you've
already created a Kubernetes cluster which you're comfortable installing _alpha_
software on.

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
glooctl --version
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
Gloo can be installed via its [Helm Chart](https://gloo.solo.io/installation/gateway/kubernetes/#installing-on-kubernetes-with-helm), which will permit fine-grained configuration of installation parameters.

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

## Running Knative apps

Now that your cluster has Gloo & Knative installed, you can run serverless applications with Knative.

Let's deploy an app to test that everything is set up correctly:


1. Next, create a `Knative Service`

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

   **Knative Services** are exposed via the *Host* header assigned by Knative. By
   default, Knative will use the header `Host`:
   `{service-name}.{namespace}.example.com`. You can discover the appropriate *Host* header by checking the URL Knative has assigned to the `helloworld-go` service created above.

   ```
   $ kubectl get ksvc helloworld-go -n default  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```
  
   ```
   NAME            URL
   helloworld-go   http://helloworld-go.default.example.com
   ```

   Gloo uses the `Host` header to route requests to the correct
   service. You can send a request to the `helloworld-go` service with curl
   using the `Host` and `$GATEWAY_URL` from above:

   ```
   $ curl -H "Host: helloworld-go.default.example.com" $(glooctl proxy url --name knative-external-proxy)
   ```
  
   ```
   Hello Go Sample v1!
   ```

Congratulations! You have successfully installed Knative with Gloo to manage and route to serverless applications!

> Note that when following other Knative tutorials, you'll need to connect to the Gloo Gateway rather than the Istio Gateway when the tutorials prompts doing so.

To get the URL of the Gloo Gateway, run

```bash
export GATEWAY_URL=$(glooctl proxy url --name knative-external-proxy)

echo $GATEWAY_URL
http://192.168.99.230:31864
```

To send requests to your service:

```bash
export GATEWAY_URL=$(glooctl proxy url --name knative-external-proxy)

curl -H "Host: helloworld-go.myproject.example.com" $GATEWAY_URL
```

## What's next

Now that your cluster has Knative installed, you can see what Knative has to
offer.

Learn more about deploying apps to Knative with the
[Getting Started with Knative App Deployment](./getting-started-knative-app.md)
guide.

To get started with Knative Eventing, pick one of the
[Eventing Samples](../eventing/samples/) to walk through.
