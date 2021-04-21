---
title: "Installing Knative Serving using YAML files"
linkTitle: "Install Serving using YAML"
weight: 02
type: "docs"
showlandingtoc: "false"
---

This topic describes how to install Knative Serving by applying YAML files using the `kubectl` CLI.


## Prerequisites

Before installation, you must meet the prerequisites.
See [Knative Prerequisites](./prerequisites).


## Install the Serving component

To install the serving component:

1. Install the required custom resources:

   ```bash
   kubectl apply -f {{< artifact repo="serving" file="serving-crds.yaml" >}}
   ```

1. Install the core components of Knative Serving:

   ```bash
   kubectl apply -f {{< artifact repo="serving" file="serving-core.yaml" >}}
   ```
For information about the YAML files in the Knative Serving and Eventing releases, see
[Installation files](./installation-files).


## Install a networking layer

The tabs below expand to show instructions for installing a networking layer.
Follow the procedure for the networking layer of your choice:

<!-- TODO: Link to document/diagram describing what is a networking layer.  -->
<!-- This indentation is important for things to render properly. -->

   {{< tabs name="serving_networking" default="Kourier" >}}
   {{% tab name="Ambassador" %}}

The following commands install Ambassador and enable its Knative integration.

1. Create a namespace to install Ambassador in:

   ```bash
   kubectl create namespace ambassador
   ```

1. Install Ambassador:

   ```bash
   kubectl apply --namespace ambassador \
     -f https://getambassador.io/yaml/ambassador/ambassador-crds.yaml \
     -f https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml \
     -f https://getambassador.io/yaml/ambassador/ambassador-service.yaml
   ```

1. Give Ambassador the required permissions:

   ```bash
   kubectl patch clusterrolebinding ambassador -p '{"subjects":[{"kind": "ServiceAccount", "name": "ambassador", "namespace": "ambassador"}]}'
   ```

1. Enable Knative support in Ambassador:

   ```bash
   kubectl set env --namespace ambassador  deployments/ambassador AMBASSADOR_KNATIVE_SUPPORT=true
   ```

1. To configure Knative Serving to use Ambassador by default:

   ```bash
   kubectl patch configmap/config-network \
     --namespace knative-serving \
     --type merge \
     --patch '{"data":{"ingress.class":"ambassador.ingress.networking.knative.dev"}}'
   ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace ambassador get service ambassador
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Contour" %}}

The following commands install Contour and enable its Knative integration.

1. Install a properly configured Contour:

   ```bash
   kubectl apply -f {{< artifact repo="net-contour" file="contour.yaml" >}}
   ```
<!-- TODO(https://github.com/knative-sandbox/net-contour/issues/11): We need a guide on how to use/modify a pre-existing install. -->

1. Install the Knative Contour controller:

   ```bash
   kubectl apply -f {{< artifact repo="net-contour" file="net-contour.yaml" >}}
   ```

1. To configure Knative Serving to use Contour by default:

   ```bash
   kubectl patch configmap/config-network \
     --namespace knative-serving \
     --type merge \
     --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'
   ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace contour-external get service envoy
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Gloo" %}}

_For a detailed guide on Gloo integration, see
[Installing Gloo for Knative](https://docs.solo.io/gloo/latest/installation/knative/)
in the Gloo documentation._

The following commands install Gloo and enable its Knative integration.

1. Make sure `glooctl` is installed (version 1.3.x and higher recommended):

   ```bash
   glooctl version
   ```

   If it is not installed, you can install the latest version using:

   ```bash
   curl -sL https://run.solo.io/gloo/install | sh
   export PATH=$HOME/.gloo/bin:$PATH
   ```

   Or following the
   [Gloo CLI install instructions](https://docs.solo.io/gloo/latest/installation/knative/#install-command-line-tool-cli).

1. Install Gloo and the Knative integration:

   ```bash
   glooctl install knative --install-knative=false
   ```

1. Fetch the External IP or CNAME:

   ```bash
   glooctl proxy url --name knative-external-proxy
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Istio" %}}

The following commands install Istio and enable its Knative integration.

1. Install a properly configured Istio ([Advanced installation](./installing-istio.md))

   ```bash
   kubectl apply -f {{< artifact repo="net-istio" file="istio.yaml" >}}
   ```


1. Install the Knative Istio controller:

   ```bash
   kubectl apply -f {{< artifact repo="net-istio" file="net-istio.yaml" >}}
   ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace istio-system get service istio-ingressgateway
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Kong" %}}

The following commands install Kong and enable its Knative integration.

1. Install Kong Ingress Controller:

   ```bash
   kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/0.9.x/deploy/single/all-in-one-dbless.yaml
   ```

1. To configure Knative Serving to use Kong by default:

   ```bash
   kubectl patch configmap/config-network \
     --namespace knative-serving \
     --type merge \
     --patch '{"data":{"ingress.class":"kong"}}'
   ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace kong get service kong-proxy
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Kourier" %}}

The following commands install Kourier and enable its Knative integration.

1. Install the Knative Kourier controller:

   ```bash
   kubectl apply -f {{< artifact repo="net-kourier" file="kourier.yaml" >}}
   ```

1. To configure Knative Serving to use Kourier by default:

   ```bash
   kubectl patch configmap/config-network \
     --namespace knative-serving \
     --type merge \
     --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
   ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace kourier-system get service kourier
   ```

   Save this for configuring DNS below.

{{< /tab >}} {{< /tabs >}}


## Verify the installation

Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`:

```bash
kubectl get pods --namespace knative-serving
```


## Configure DNS

You can configure DNS to prevent the need to run curl commands with a host header.

The tabs below expand to show instructions for configuring DNS.
Follow the procedure for the DNS of your choice:

<!-- This indentation is important for things to render properly. -->

   {{< tabs name="serving_dns" default="Magic DNS (xip.io)" >}}
   {{% tab name="Magic DNS (xip.io)" %}}

We ship a simple Kubernetes Job called "default domain" that will (see caveats)
configure Knative Serving to use <a href="http://xip.io">xip.io</a> as the
default DNS suffix.

```bash
kubectl apply -f {{< artifact repo="serving" file="serving-default-domain.yaml" >}}
```

**Caveat**: This will only work if the cluster LoadBalancer service exposes an
IPv4 address or hostname, so it will not work with IPv6 clusters or local setups
like Minikube. For these, see "Real DNS" or "Temporary DNS".

{{< /tab >}}

{{% tab name="Real DNS" %}}

To configure DNS for Knative, take the External IP
or CNAME from setting up networking, and configure it with your DNS provider as
follows:

- If the networking layer produced an External IP address, then configure a
  wildcard `A` record for the domain:

  ```
  # Here knative.example.com is the domain suffix for your cluster
  *.knative.example.com == A 35.233.41.212
  ```

- If the networking layer produced a CNAME, then configure a CNAME record for
  the domain:

  ```
  # Here knative.example.com is the domain suffix for your cluster
  *.knative.example.com == CNAME a317a278525d111e89f272a164fd35fb-1510370581.eu-central-1.elb.amazonaws.com
  ```

Once your DNS provider has been configured, direct Knative to use that domain:

```bash
# Replace knative.example.com with your domain suffix
kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"knative.example.com":""}}'
```

{{< /tab >}}

    {{% tab name="Temporary DNS" %}}

If you are using `curl` to access the sample
applications, or your own Knative app, and are unable to use the "Magic DNS
(xip.io)" or "Real DNS" methods, there is a temporary approach. This is useful
for those who wish to evaluate Knative without altering their DNS configuration,
as per the "Real DNS" method, or cannot use the "Magic DNS" method due to using,
for example, minikube locally or IPv6 clusters.

To access your application using `curl` using this method:

1. After starting your application, get the URL of your application:

   ```bash
   kubectl get ksvc
   ```

   The output should be similar to:

   ```bash
   NAME            URL                                        LATESTCREATED         LATESTREADY           READY   REASON
   helloworld-go   http://helloworld-go.default.example.com   helloworld-go-vqjlf   helloworld-go-vqjlf   True
   ```

1. Instruct `curl` to connect to the External IP or CNAME defined by the
   networking layer in section 3 above, and use the `-H "Host:"` command-line
   option to specify the Knative application's host name. For example, if the
   networking layer defines your External IP and port to be
   `http://192.168.39.228:32198` and you wish to access the above
   `helloworld-go` application, use:

   ```bash
   curl -H "Host: helloworld-go.default.example.com" http://192.168.39.228:32198
   ```

   In the case of the provided `helloworld-go` sample application, the output
   should, using the default configuration, be:

   ```
   Hello Go Sample v1!
   ```

Refer to the "Real DNS" method for a permanent solution.

    {{< /tab >}} {{< /tabs >}}


## Next steps

After installing Knative Serving:

- [Installing Knative Eventing using YAML files](./install-eventing-with-yaml)

- To add optional enhancements to your installation, see [Installing optional extensions](./install-extensions).

- To easily interact with Knative services, [install the `kn` CLI](/docs/client/install-kn).
