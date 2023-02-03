# Installing Knative Serving using YAML files

This topic describes how to install Knative Serving by applying YAML files using the `kubectl` CLI.

--8<-- "prerequisites.md"
--8<-- "security-prereqs-images.md"

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
        For information about the YAML files in Knative Serving, see [Knative Serving installation files](serving-installation-files.md).

## Install a networking layer

The following tabs expand to show instructions for installing a networking layer.
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
        --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
      ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl --namespace kourier-system get service kourier
        ```

        !!! tip
            Save this to use in the following [Configure DNS](#configure-dns) section.


=== "Istio"

    The following commands install Istio and enable its Knative integration.

    1. Install a properly configured Istio by following the
    [Advanced Istio installation](../../installing-istio.md) instructions or by running the command:

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
            Save this to use in the following [Configure DNS](#configure-dns) section.


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
        --patch '{"data":{"ingress-class":"contour.ingress.networking.knative.dev"}}'
      ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl --namespace contour-external get service envoy
        ```

        !!! tip
            Save this to use in the following [Configure DNS](#configure-dns) section.


## Verify the installation

!!! success
    Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`.
    You can do this by running the following command and inspecting the output:

    ```bash
    kubectl get pods -n knative-serving
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                                      READY   STATUS    RESTARTS   AGE
    3scale-kourier-control-54cc54cc58-mmdgq   1/1     Running   0          81s
    activator-67656dcbbb-8mftq                1/1     Running   0          97s
    autoscaler-df6856b64-5h4lc                1/1     Running   0          97s
    controller-788796f49d-4x6pm               1/1     Running   0          97s
    domain-mapping-65f58c79dc-9cw6d           1/1     Running   0          97s
    domainmapping-webhook-cc646465c-jnwbz     1/1     Running   0          97s
    webhook-859796bc7-8n5g2                   1/1     Running   0          96s
    ```

## Configure DNS
<!-- These are snippets from the docs/snippets directory -->
{% include "dns.md" %}
{% include "real-dns-yaml.md" %}
{% include "temporary-dns.md" %}

## Install optional Serving extensions

The following tabs expand to show instructions for installing each Serving extension.

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

    1. Install [cert-manager version v1.0.0 or later](../../installing-cert-manager.md).

    1. Install the component that integrates Knative with `cert-manager` by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-certmanager",file="release.yaml")}}
        ```

    1. Configure Knative to automatically configure TLS certificates by following the steps in
    [Enabling automatic TLS certificate provisioning](../../../serving/using-auto-tls.md).

=== "TLS with HTTP01"

    Knative supports automatically provisioning TLS certificates using Encrypt HTTP01 challenges. The following commands install the components needed to support TLS.

    1. Install the net-http01 controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-http01",file="release.yaml")}}
        ```

    2. Configure the `certificate-class` to use this certificate type by running the command:

        ```bash
        kubectl patch configmap/config-network \
          --namespace knative-serving \
          --type merge \
          --patch '{"data":{"certificate-class":"net-http01.certificate.networking.knative.dev"}}'
        ```

    3. Enable autoTLS by running the command:

        ```bash
        kubectl patch configmap/config-network \
          --namespace knative-serving \
          --type merge \
          --patch '{"data":{"auto-tls":"Enabled"}}'
        ```
