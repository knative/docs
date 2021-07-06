# Installing Knative Serving using YAML files

This topic describes how to install Knative Serving by applying YAML files using the `kubectl` CLI.

--8<-- "prerequisites.md"

## Install the Knative Serving component

To install the Knative Serving component:

1. Install the required custom resources by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-crds.yaml")}}
    ```

1. Install the core components of Knative Serving by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-core.yaml")}}
    ```

    !!! info
        For information about the YAML files in Knative Serving, see [Knative Serving installation files](./serving-installation-files.md).

## Install a networking layer

The tabs below expand to show instructions for installing a networking layer.
Follow the procedure for the networking layer of your choice:

<!-- TODO: Link to document/diagram describing what is a networking layer.  -->
<!-- This indentation is important for things to render properly. -->

=== "Kourier (Choose this if you are not sure)"

    The following commands install Kourier and enable its Knative integration.

    1. Install the Knative Kourier controller by running the command:
    ```bash
    kubectl apply -f {{ artifact(repo="net-kourier",file="kourier.yaml")}}
    ```

    1. Configure Knative Serving to use Kourier by default by running the command:
      ```bash
      kubectl patch configmap/config-network \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
      ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl --namespace kourier-system get service kourier
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.


=== "Ambassador"

    The following commands install Ambassador and enable its Knative integration.

    1. Create a namespace in which to install Ambassador by running the command:

        ```bash
        kubectl create namespace ambassador
        ```

    1. Install Ambassador by running the command:

        ```bash
        kubectl apply --namespace ambassador \
          -f https://getambassador.io/yaml/ambassador/ambassador-crds.yaml \
          -f https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml \
          -f https://getambassador.io/yaml/ambassador/ambassador-service.yaml
        ```

    1. Give Ambassador the required permissions by running the command:

        ```bash
        kubectl patch clusterrolebinding ambassador -p '{"subjects":[{"kind": "ServiceAccount", "name": "ambassador", "namespace": "ambassador"}]}'
        ```

    1. Enable Knative support in Ambassador by running the command:

        ```bash
        kubectl set env --namespace ambassador  deployments/ambassador AMBASSADOR_KNATIVE_SUPPORT=true
        ```

    1. Configure Knative Serving to use Ambassador by default by running the command:

        ```bash
        kubectl patch configmap/config-network \
          --namespace knative-serving \
          --type merge \
          --patch '{"data":{"ingress.class":"ambassador.ingress.networking.knative.dev"}}'
        ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl --namespace ambassador get service ambassador
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.


=== "Contour"

    The following commands install Contour and enable its Knative integration.

    1. Install a properly configured Contour by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-contour",file="contour.yaml")}}
        ```
        <!-- TODO(https://github.com/knative-sandbox/net-contour/issues/11): We need a guide on how to use/modify a pre-existing install. -->

    1. Install the Knative Contour controller by running the command:
      ```bash
      kubectl apply -f {{ artifact(repo="net-contour",file="net-contour.yaml")}}
      ```

    1. Configure Knative Serving to use Contour by default by running the command:
      ```bash
      kubectl patch configmap/config-network \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'
      ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl --namespace contour-external get service envoy
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.


=== "Gloo"

    !!! tip
        For a detailed guide on Gloo integration, see
        [Installing Gloo for Knative](https://docs.solo.io/gloo/latest/installation/knative/)
        in the Gloo documentation.

    The following commands install Gloo and enable its Knative integration.

    1. Ensure `glooctl` is installed by running the command:

        ```bash
        glooctl version
        ```

        v1.3.x or later is recommended.
        If it is not installed, you can install the latest version by running the command:
        ```bash
        curl -sL https://run.solo.io/gloo/install | sh
        export PATH=$HOME/.gloo/bin:$PATH
        ```

        or by following the
        [Gloo CLI install instructions](https://docs.solo.io/gloo/latest/installation/knative/#install-command-line-tool-cli) in the Gloo documentation.

    1. Install Gloo and the Knative integration by running the command:
      ```bash
      glooctl install knative --install-knative=false
      ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        glooctl proxy url --name knative-external-proxy
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.


=== "Istio"

    The following commands install Istio and enable its Knative integration.

    1. Install a properly configured Istio by following the
    [Advanced Istio installation](../installing-istio.md) instructions or by running the command:

        ```bash
        kubectl apply -l knative.dev/crd-install=true -f {{ artifact(repo="net-istio",file="istio.yaml")}}
        kubectl apply -f {{ artifact(repo="net-istio",file="istio.yaml")}}
        ```

    1. Install the Knative Istio controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-istio",file="net-istio.yaml")}}
        ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl --namespace istio-system get service istio-ingressgateway
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.

## Verify the installation

!!! success
    Monitor the Knative components until all of the components display `Running` or
    `Completed` beneath `STATUS`:

    ```bash
    kubectl get pods --namespace knative-serving
    ```


## Configure DNS

You can configure DNS to prevent the need to run curl commands with a host header.

The tabs below expand to show instructions for configuring DNS.
Follow the procedure for the DNS of your choice:

<!-- This indentation is important for things to render properly. -->

=== "Magic DNS (xip.io)"

    If the cluster LoadBalancer service doesn't expose an IPv4 address or hostname, such as with
    IPv6 clusters or local setups such as minikube, Magic DNS won't work.
    Follow the Real DNS or Temporary DNS steps instead.

    * If the cluster LoadBalancer service exposes an IPv4 address or hostname, use a simple
    Kubernetes Job called `serving-default-domain` that configures Knative Serving to use
    [xip.io](http://xip.io) as the default DNS suffix by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="serving",file="serving-default-domain.yaml")}}
        ```


=== "Real DNS"

    To configure DNS for Knative, take the External IP address
    or CNAME from setting up networking, and configure it with your DNS provider as
    follows:

    1. If the networking layer produced an External IP address, then configure a
      wildcard `A` record for the domain by running the command:

        ```bash
        *.<domain-suffix> == A 35.233.41.212
        ```
        Where `<domain-suffix>` is the domain suffix for your cluster

    1. If the networking layer produced a CNAME, then configure a CNAME record for the domain by running the command:

        ```bash
        *.<domain-suffix> == CNAME a317a278525d111e89f272a164fd35fb-1510370581.eu-central-1.elb.amazonaws.com
        ```
        Where `<domain-suffix>` is the domain suffix for your cluster

    1. After your DNS provider is configured, direct Knative to use that domain by running the command:

        ```bash
        kubectl patch configmap/config-domain \
          --namespace knative-serving \
          --type merge \
          --patch '{"data":{"<domain-suffix>":""}}'
        ```
        Where `<domain-suffix>` is the domain suffix for your cluster

=== "Temporary DNS"

    If you are using `curl` to access the sample applications or your own Knative app, and are
    unable to use the Magic DNS (xip.io) or Real DNS methods, you can use a temporary approach.

    See the Real DNS method for a permanent solution.

    Temporary DNS is useful for evaluating Knative without altering the DNS configuration, as in the
    Real DNS method, or cannot use the Magic DNS method due to using, for example, minikube locally
    or IPv6 clusters.

    To access your application using `curl` using this method:

    1. After starting your application, get the URL of your application by running the command:

        ```bash
        kubectl get ksvc
        ```

        !!! success "Verify the output"

            ```bash
            NAME            URL                                        LATESTCREATED         LATESTREADY           READY   REASON
            helloworld-go   http://helloworld-go.default.example.com   helloworld-go-vqjlf   helloworld-go-vqjlf   True
            ```

    1. Instruct `curl` to connect to the External IP address or CNAME defined by the
      networking layer in section 3 above, and use the `-H "Host:"` command-line
      option to specify the Knative application's hostname.

      For example, if the networking layer defines your External IP address and port to be
      `http://192.168.39.228:32198` and you wish to access the above `helloworld-go` application,
      run the command:

        ```bash
        curl -H "Host: helloworld-go.default.example.com" http://192.168.39.228:32198
        ```

        !!! success "Verify the output"
            In the case of the provided `helloworld-go` sample application, when using the default configuration the output is:

            ```
            Hello Go Sample v1!
            ```

## Install optional Serving extensions

The tabs below expand to show instructions for installing each Serving extension.

=== "HPA autoscaling"

    Knative also supports the use of the Kubernetes Horizontal Pod Autoscaler (HPA)
    for driving autoscaling decisions.

    * Install the components needed to support HPA-class autoscaling by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="serving",file="serving-hpa.yaml")}}
        ```

    <!-- TODO(https://github.com/knative/docs/issues/2152): Link to a more in-depth guide on HPA-class autoscaling -->

=== "TLS with cert-manager"

    Knative supports automatically provisioning TLS certificates through
    [cert-manager](https://cert-manager.io/docs/). The following commands
    install the components needed to support the provisioning of TLS certificates
    through cert-manager.

    1. Install [cert-manager version v1.0.0 or later](../../../../serving/installing-cert-manager).

    1. Install the component that integrates Knative with `cert-manager` by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-certmanager",file="release.yaml")}}
        ```

    1. Configure Knative to automatically configure TLS certificates by following the steps in
    [Enabling automatic TLS certificate provisioning](../../../../serving/using-auto-tls).

=== "TLS with HTTP01"

    Knative supports automatically provisioning TLS certificates using Encrypt HTTP01 challenges. The following commands install the components needed to support TLS.

    1. Install the `net-http01` controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-http01",file="release.yaml")}}
        ```

    2. Configure the `certificate.class` to use this certificate type by running the command:

        ```bash
        kubectl patch configmap/config-network \
          --namespace knative-serving \
          --type merge \
          --patch '{"data":{"certificate.class":"net-http01.certificate.networking.knative.dev"}}'
        ```

    3. Enable auto-TLS by running the command:

        ```bash
        kubectl patch configmap/config-network \
          --namespace knative-serving \
          --type merge \
          --patch '{"data":{"autoTLS":"Enabled"}}'
        ```


=== "TLS wildcard support"

    !!! warning
        TLS wildcard support does not work with HTTP01.

    If you are using a certificate implementation that supports provisioning
    wildcard certificates (for example, cert-manager with a DNS01 issuer) then the most
    efficient way to provision certificates is with the namespace wildcard
    certificate controller.

    * Install the components needed to provision wildcard certificates in each namespace by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="serving",file="serving-nscert.yaml")}}
        ```


=== "DomainMapping CRD"

    The `DomainMapping` CRD allows a user to map a domain name that they own to a specific Knative Service.

    * Apply the `DomainMapping` CRD by running the commands:

        ```bash
        kubectl apply -f {{ artifact(repo="serving",file="serving-domainmapping-crds.yaml")}}
        kubectl apply -f {{ artifact(repo="serving",file="serving-domainmapping.yaml")}}
        ```
