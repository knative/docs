---
title: "Enabling automatic TLS certificate provisioning"
linkTitle: "Enabling auto TLS certs"
weight: 64
type: "docs"
---

If you install and configure cert-manager, you can configure Knative to
automatically obtain new TLS certificates and renew existing ones.
To learn more about using secure connections in Knative, see
[Configuring HTTPS with TLS certificates](./using-a-tls-cert.md).

## Before you begin

You must meet the following prerequisites to enable automatic certificate
provisioning:

- The following must be installed on your Knative cluter:
  - [Knative Serving version 0.6.0 or higher](../install/).
  - [Istio with SDS, version 1.1 or higher](../install/installing-istio.md#installing-istio-with-SDS-to-secure-the-ingress-gateway).
    Note: Currently, [Gloo](https://github.com/solo-io/gloo) is unsupported.
  - [cert-manager version `0.6.1` or higher](./installing-cert-manager.md).
- Your Knative cluster must be configured to use a
  [custom domain](./using-a-custom-domain.md).
- Your DNS provider must be setup and configured to your domain.


## Enabling automatic certificate provisioning

To enable Knative to automatically provision TLS certificates:

1. Determine if `networking-certmanager` is installed by running the following
   command:
   ```shell
   kubectl get deployment networking-certmanager -n knative-serving
   ```
   
1. If `networking-certmanager` is not found, run the following commands to 
   install it:

   ```shell
   # KNATIVE_VERSION needs to be 0.6.0 or above.
   KNATIVE_VERSION=0.6.0

   kubectl apply --filename https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/serving.yaml \
   --selector networking.knative.dev/certificate-provider=cert-manager
    ```

1. Create a `ClusterIssuer` configuration file to define who issues the
   TLS certificates, how requests are validated (`DNS-01`), and which DNS provider
   validates those requests.

   For reference, see the 
   [cert-manager `ClusterIssuer` example](https://docs.cert-manager.io/en/latest/tasks/issuers/setup-acme.html#creating-a-basic-acme-issuer).

    
   Example:

   If you use the Let's Encrypt CA and Google Cloud DNS, you would create the
  `letsencrypt-issuer` `ClusterIssuer`, that includes your Let's Encrypt 
   account info, the required `DNS-01` challenge type, and Cloud DNS provider 
   info.

   ```
   issuerRef: |
     kind: ClusterIssuer
     name: letsencrypt-issuer

   solverConfig: |
     dns01:
       provider: cloud-dns-provider
   ```

   See a complete example that demonstrates how to
   [configure cert-manager with Google Cloud DNS](./using-cert-manager-on-gcp.md).

1. Update the `config-network` ConfigMap in the `knative-serving` namespace to
   include the `autoTLS: Enabled` attribute under `data`. For example:

   ```
   apiVersion: v1
   data:
     _example: |
     ...

     # Add this entry in the `data` field.
     autoTLS: Enabled
   kind: ConfigMap
   metadata:
     name: config-network
     namespace: knative-serving
   ...
   ```

1. Configure how Knative handles HTTP and HTTPS.

    By default, Knative ingress is configured to serve HTTP traffic
    (`httpProtocol: "Enabled"`). Now that your cluster is configured to use 
    TLS certificates and handle HTTPS traffic, you can specify whether or not
    any HTTP traffic is allowed.
     
    Use the 
    [`httpProtocol`](https://github.com/knative/serving/blob/master/config/config-network.yaml#L110)
    attribute in the `config-network` ConfigMap of the `knative-serving` 
    namespace, to define how you want HTTP traffic handled. Possible values:

    - `Enabled`: Serve HTTP traffic.
    - `Disabled`: Rejects all HTTP traffic.
    - `Redirected`: Responds to HTTP request with a `302` redirect to ask 
      the clients to use HTTPS.
    
   Example:

   ```
   apiVersion: v1
   data:
     _example: |
     ...

     # Add this entry with Disabled or Redirected in the `data` field.
     httpProtocol: Redirected
   kind: ConfigMap
   metadata:
     name: config-network
     namespace: knative-serving
   ...
   ```

Congratulations! Knative is now configured to obtain and renew TLS 
certificates. When your TLS certificate is active on your cluster, your 
Knative services will be able to handle HTTPS traffic.
