# Installing Knative Serving using YAML files

This topic describes how to install Knative Serving by applying YAML files using the `kubectl` CLI.

--8<-- "prerequisites.md"

## Install the Serving component

To install the serving component:

1. Install the required custom resources:

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-crds.yaml")}}
    ```

1. Install the core components of Knative Serving:

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-core.yaml")}}
    ```

    !!! info
        For information about the YAML files in Knative Serving, see [Description Tables for YAML Files](./serving-installation-files.md).

## Install a networking layer

The tabs below expand to show instructions for installing a networking layer.
Follow the procedure for the networking layer of your choice:

<!-- TODO: Link to document/diagram describing what is a networking layer.  -->
<!-- This indentation is important for things to render properly. -->

=== "Kourier (Choose this if you are not sure)"

    The following commands install Kourier and enable its Knative integration.

    1. Install the Knative Kourier controller:
    ```bash
    kubectl apply -f {{ artifact(repo="net-kourier",file="kourier.yaml")}}
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

        !!! tip
            Save this to use in the `Configure DNS` section.


=== "Ambassador"

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

        !!! tip
            Save this to use in the `Configure DNS` section.


=== "Contour"

    The following commands install Contour and enable its Knative integration.

    1. Install a properly configured Contour:

        ```bash
        kubectl apply -f {{ artifact(repo="net-contour",file="contour.yaml")}}
        ```
        <!-- TODO(https://github.com/knative-sandbox/net-contour/issues/11): We need a guide on how to use/modify a pre-existing install. -->

    1. Install the Knative Contour controller:
      ```bash
      kubectl apply -f {{ artifact(repo="net-contour",file="net-contour.yaml")}}
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

        !!! tip
            Save this to use in the `Configure DNS` section.


=== "Istio"

    The following commands install Istio and enable its Knative integration.

    1. Install a properly configured Istio ([Advanced installation](../installing-istio.md))

        ```bash
        kubectl apply -l knative.dev/crd-install=true -f {{ artifact(repo="net-istio",file="istio.yaml")}}
        kubectl apply -f {{ artifact(repo="net-istio",file="istio.yaml")}}
        ```

    1. Install the Knative Istio controller:

        ```bash
        kubectl apply -f {{ artifact(repo="net-istio",file="net-istio.yaml")}}
        ```

    1. Fetch the External IP or CNAME:

        ```bash
        kubectl --namespace istio-system get service istio-ingressgateway
        ```

        !!! tip
            Save this to use in the `Configure DNS` section.

## Verify the installation

!!! success "Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`:"

    ```{ .bash .no-copy }
    kubectl get pods --namespace knative-serving
    ```

{% include "dns.md" %}

## Install optional Serving extensions

The tabs below expand to show instructions for installing each Serving extension.

=== "HPA autoscaling"

    Knative also supports the use of the Kubernetes Horizontal Pod Autoscaler (HPA)
    for driving autoscaling decisions. The following command will install the
    components needed to support HPA-class autoscaling:

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-hpa.yaml")}}
    ```

    <!-- TODO(https://github.com/knative/docs/issues/2152): Link to a more in-depth guide on HPA-class autoscaling -->

=== "TLS with cert-manager"

    Knative supports automatically provisioning TLS certificates via
    [cert-manager](https://cert-manager.io/docs/). The following commands will
    install the components needed to support the provisioning of TLS certificates
    via cert-manager.

    1. First, install [cert-manager version `v1.0.0` or higher](../../../../serving/installing-cert-manager)

    1. Next, install the component that integrates Knative with `cert-manager`:

        ```bash
        kubectl apply -f {{ artifact(repo="net-certmanager",file="release.yaml")}}
        ```

    1. Now configure Knative to
      [automatically configure TLS certificates](../../../../serving/using-auto-tls).

=== "TLS via HTTP01"

    Knative supports automatically provisioning TLS certificates using Encrypt HTTP01 challenges. The following commands will install the components needed to support TLS.

    1. Install the `net-http01` controller:

        ```bash
        kubectl apply -f {{ artifact(repo="net-http01",file="release.yaml")}}
        ```

    2. Configure the `certificate.class` to use this certificate type:

        ```bash
        kubectl patch configmap/config-network \
          --namespace knative-serving \
          --type merge \
          --patch '{"data":{"certificate.class":"net-http01.certificate.networking.knative.dev"}}'
        ```

    3. Enable auto-TLS.

        ```bash
        kubectl patch configmap/config-network \
          --namespace knative-serving \
          --type merge \
          --patch '{"data":{"autoTLS":"Enabled"}}'
        ```


=== "TLS wildcard support"

    If you are using a Certificate implementation that supports provisioning
    wildcard certificates (e.g. cert-manager with a DNS01 issuer), then the most
    efficient way to provision certificates is with the namespace wildcard
    certificate controller. The following command will install the components needed
    to provision wildcard certificates in each namespace:

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-nscert.yaml")}}
    ```

    !!! warning
        Note this will not work with HTTP01 either via cert-manager or the net-http01
        options.

=== "DomainMapping CRD"

    The `DomainMapping` CRD allows a user to map a Domain Name that they own to a specific Knative Service.

    ```bash
    kubectl apply -f {{ artifact(repo="serving",file="serving-domainmapping-crds.yaml")}}
    kubectl apply -f {{ artifact(repo="serving",file="serving-domainmapping.yaml")}}
    ```
