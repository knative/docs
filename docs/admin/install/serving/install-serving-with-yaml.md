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

{% include "dns.md" %}

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

    1. Install the net-http01 controller by running the command:

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

