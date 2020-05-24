---
title: "Enabling automatic TLS certificate provisioning"
linkTitle: "Enabling auto TLS certs"
weight: 64
type: "docs"
---

If you install and configure cert-manager, you can configure Knative to
automatically obtain new TLS certificates and renew existing ones for Knative 
Services.
To learn more about using secure connections in Knative, see
[Configuring HTTPS with TLS certificates](./using-a-tls-cert.md).

## Automatic TLS provision mode

Knative supports the following Auto TLS modes:

1.  Using DNS-01 challenge

    In this mode, your cluster needs to be able to talk to your DNS server to verify the ownership of your domain.
    - **Provision Certificate per namespace is supported when using DNS-01 challenge mode.**
      - This is the recommended mode for faster certificate provision.
      - In this mode, a single Certificate will be provisioned per namespace and is reused across the Knative Services within the same namespace.

    - **Provision Certificate per Knative Service is supported when using DNS-01 challenge mode.**
      - This is the recommended mode for better certificate islation between Knative Services.
      - In this mode, a Certificate will be provisioned for each Knative Service.
      - The TLS effective time is longer as it needs Certificate provision for each Knative Service creation.

1.  Using HTTP-01 challenge

    - In this type, your cluster does not need to be able to talk to your DNS server. You just 
    need to map your domain to the IP of the cluser ingress.
    - When using HTTP-01 challenge, **a certificate will be provisioned per Knative Service.** Certificate provision per namespace is not supported when using HTTP-01 challenge. 

## Before you begin

You must meet the following prerequisites to enable auto TLS:

- The following must be installed on your Knative cluter:
  - [Knative Serving](../install/).
  - [Istio with SDS, version 1.3 or higher](../install/installing-istio.md#installing-istio-with-SDS-to-secure-the-ingress-gateway),
    [Contour, version 1.1 or higher](../install/any-kubernetes-cluster.md#installing-the-serving-component),
    or [Gloo, version 0.18.16 or higher](https://docs.solo.io/gloo/latest/installation/knative/).
    Note: Currently, [Ambassador](https://github.com/datawire/ambassador) is unsupported.
  - [cert-manager version `0.12.0` or higher](./installing-cert-manager.md).
- Your Knative cluster must be configured to use a
  [custom domain](./using-a-custom-domain.md).
- Your DNS provider must be setup and configured to your domain.
- If you want to use HTTP-01 challenge, you need to configure your custom 
domain to map to the IP of ingress. You can achieve this by adding a DNS A record to map the domain to the IP according to the instructions of your DNS provider.

## Enabling Auto TLS

To enable support for Auto TLS in Knative:

### Create cert-manager ClusterIssuer

1.  Create and add the `ClusterIssuer` configuration file to your Knative cluster
to define who issues the TLS certificates, how requests are validated,
and which DNS provider validates those requests.

    #### ClusterIssuer for DNS-01 challenge

    Use the cert-manager reference to determine how to configure your
    `ClusterIssuer` file:
    - See the generic
      [`ClusterIssuer` example](https://cert-manager.io/docs/configuration/acme/#creating-a-basic-acme-issuer)
    - Also see the
      [`DNS01` example](https://docs.cert-manager.io/en/latest/tasks/acme/configuring-dns01/index.html)

      **Example**: Cloud DNS `ClusterIssuer` configuration file:

      The following `letsencrypt-issuer` named `ClusterIssuer` file is
      configured for the Let's Encrypt CA and Google Cloud DNS. Under `spec`,
      the Let's Encrypt account info, required `DNS-01` challenge type, and
      Cloud DNS provider info defined. For the complete Google Cloud DNS
      example, see
      [Configuring HTTPS with cert-manager and Google Cloud DNS](./using-cert-manager-on-gcp.md).

      ```shell
      apiVersion: cert-manager.io/v1alpha2
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-dns-issuer
      spec:
        acme:
          server: https://acme-v02.api.letsencrypt.org/directory
          # This will register an issuer with LetsEncrypt.  Replace
          # with your admin email address.
          email: myemail@gmail.com
          privateKeySecretRef:
            # Set privateKeySecretRef to any unused secret name.
            name: letsencrypt-dns-issuer
          solvers:
          - dns01:
              clouddns:
                # Set this to your GCP project-id
                project: $PROJECT_ID
                # Set this to the secret that we publish our service account key
                # in the previous step.
                serviceAccountSecretRef:
                  name: cloud-dns-key
                  key: key.json
      ```

    ####  ClusterIssuer for HTTP-01 challenge

    Run the following command to apply the ClusterIssuer for HTT01 challenge:

    ```shell
    kubectl apply -f - <<EOF
    apiVersion: cert-manager.io/v1alpha2
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-http01-issuer
    spec:
      acme:
        privateKeySecretRef:
          name: letsencrypt
        server: https://acme-v02.api.letsencrypt.org/directory
        solvers:
        - http01:
           ingress:
             class: istio
    EOF
    ```

1.  Ensure that the ClusterIssuer is created successfully:

    ```shell
    kubectl get clusterissuer <cluster-issuer-name> --output yaml
    ```

    Result: The `Status.Conditions` should include `Ready=True`.


### Install networking-certmanager deployment

1.  Determine if `networking-certmanager` is already installed by running the 
    following command:

    ```shell
    kubectl get deployment networking-certmanager -n knative-serving
    ```

1.  If `networking-certmanager` is not found, run the following command:

    ```shell
    kubectl apply --filename {{< artifact repo="net-certmanager" file="release.yaml" >}}
    ```

### Install networking-ns-cert component

If you choose to use the mode of provisioning certificate per namespace, you need to install `networking-ns-cert` components.

1. Determine if `networking-ns-cert` deployment is already installed by 
running the following command:

    ```shell
    kubectl get deployment networking-ns-cert -n knative-serving
    ```

1. If `networking-ns-cert` deployment is not found, run the following command:

    ```shell
    kubectl apply --filename {{< artifact repo="serving" file="serving-nscert.yaml" >}}
    ```

### Configure config-certmanager ConfigMap

Update your [`config-certmanager` ConfigMap](https://github.com/knative/net-certmanager/blob/master/config/config.yaml)
in the `knative-serving` namespace to reference your new `ClusterIssuer`.

1.  Run the following command to edit your `config-certmanager` ConfigMap:

    ```shell
    kubectl edit configmap config-certmanager --namespace knative-serving
    ```

1.  Add the `issuerRef` within the `data` section:

    ```shell
    ...
    data:
    ...
      issuerRef: |
        kind: ClusterIssuer
        name: letsencrypt-issuer
    ```

    Example:

    ```shell
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-certmanager
      namespace: knative-serving
      labels:
        networking.knative.dev/certificate-provider: cert-manager
    data:
      issuerRef: |
        kind: ClusterIssuer
        name: letsencrypt-http01-issuer
    ```

    `issueRef` defines which `ClusterIssuer` will be used by Knative to issue 
    certificates.

1.  Ensure that the file was updated successfully:

    ```shell
    kubectl get configmap config-certmanager --namespace knative-serving --output yaml
    ```

### Turn on Auto TLS

Update the
[`config-network` ConfigMap](https://github.com/knative/serving/blob/master/config/core/configmaps/network.yaml)
in the `knative-serving` namespace to enable `autoTLS`and specify how HTTP
requests are handled:

1.  Run the following command to edit your `config-network` ConfigMap:

    ```shell
    kubectl edit configmap config-network --namespace knative-serving
    ```

1.  Add the `autoTLS: Enabled` attribute under the `data` section:

    ```shell
    ...
    data:
    ...
      autoTLS: Enabled
    ...
    ```

    Example:

    ```shell
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-network
      namespace: knative-serving
    data:
       ...
       autoTLS: Enabled
       ...
    ```

1.  Configure how HTTP and HTTPS requests are handled in the
  [`httpProtocol`](https://github.com/knative/serving/blob/master/config/core/configmaps/network.yaml#L109)
  attribute.

    By default, Knative ingress is configured to serve HTTP traffic
    (`httpProtocol: Enabled`). Now that your cluster is configured to use TLS
    certificates and handle HTTPS traffic, you can specify whether or not any
    HTTP traffic is allowed.

    Supported `httpProtocol` values:

    - `Enabled`: Serve HTTP traffic.
    - `Disabled`: Rejects all HTTP traffic.
    - `Redirected`: Responds to HTTP request with a `302` redirect to ask the
      clients to use HTTPS.

     ```shell
     ...
     data:
     ...
       autoTLS: Enabled
     ...
     ```

     Example:

     ```shell
     apiVersion: v1
     kind: ConfigMap
     metadata:
       name: config-network
       namespace: knative-serving
     data:
       ...
       autoTLS: Enabled
       ...
       httpProtocol: Redirected
       ...
     ```

    **Note:**
    When using HTTP-01 challenge, `httpProtocol` field has to be set to `Enabled` to make sure HTTP-01 challenge requests can be accepted by the cluster.

1.  Ensure that the file was updated successfully:

    ```shell
    kubectl get configmap config-network --namespace knative-serving --output yaml
    ```

Congratulations! Knative is now configured to obtain and renew TLS certificates.
When your TLS certificate is active on your cluster, your Knative services will
be able to handle HTTPS traffic.

### Verify Auto TLS

1.  Run the following comand to create a Knative Service:
    ```shell
    kubectl apply -f https://raw.githubusercontent.com/knative/docs/master/docs/serving/samples/autoscale-go/service.yaml
    ```

1.  When the certificate is provisioned (which could take up to several minutes depending on 
    the challenge type), you should see something like:
    ```
    NAME               URL                                           LATESTCREATED            LATESTREADY              READY   REASON
    autoscale-go       https://autoscale-go.default.{custom-domain}   autoscale-go-6jf85 autoscale-go-6jf85       True  
    ```

    Note that the URL will be **https** in this case.
