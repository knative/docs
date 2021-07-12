# Installing Knative Serving using YAML files

{% include "prerequisites.md" %}
{% include "serving-networking-layers.md" %}

## Procedure

To install Knative Serving:

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

## Verify the installation

!!! success
    Monitor the Knative components until all of the components display `Running` or
    `Completed` beneath `STATUS`:

    ```bash
    kubectl get pods -n knative-serving
    ```
    <!--TODO: shoe sample output-->

<!-- These are snippets from the docs/snippets directory -->
{% include "dns.md" %}
{% include "real-dns-yaml.md" %}
{% include "temporary-dns.md" %}

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
