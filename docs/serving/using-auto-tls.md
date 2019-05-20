---
title: "Enabling automatic TLS certificate provisioning"
linkTitle: "Enabling auto TLS certs"
weight: 64
type: "docs"
---

If you install and configure cert-manager, you can configure Knative to
automatically obtain new TLS certificates and renew existing ones. To learn more
about using secure connections in Knative, see
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

1. Create and add the `ClusterIssuer` configuration file to your Knative cluster
   to define who issues the TLS certificates, how requests are validated
   (`DNS-01`), and which DNS provider validates those requests.

   1. Create the `ClusterIssuer` file:

      cert-manager reference:

      - See the generic
        [`ClusterIssuer` example](https://docs.cert-manager.io/en/latest/tasks/issuers/setup-acme.html#creating-a-basic-acme-issuer)
      - Also see the
        [`DNS-01` example](https://docs.cert-manager.io/en/latest/tasks/acme/configuring-dns01/index.html)

      Example Cloud DNS `ClusterIssuer` configuration file:

      If you use the Let's Encrypt CA and Google Cloud DNS, you would create the
      `letsencrypt-issuer` `ClusterIssuer` file, that includes your Let's
      Encrypt account info, the required `DNS-01` challenge type, and Cloud DNS
      provider info.

      See the
      [complete Google Cloud DNS configuration](./using-cert-manager-on-gcp.md).

      ```shell
      apiVersion: certmanager.k8s.io/v1alpha1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-issuer
        namespace: cert-manager
      spec:
        acme:
          server: https://acme-v02.api.letsencrypt.org/directory
          # This will register an issuer with LetsEncrypt.  Replace
          # with your admin email address.
          email: myemail@gmail.com
          privateKeySecretRef:
            # Set privateKeySecretRef to any unused secret name.
            name: letsencrypt-issuer
          dns01:
            providers:
            - name: cloud-dns-provider
              clouddns:
                # Set this to your GCP project-id
                project: $PROJECT_ID
                # Set this to the secret that we publish our service account key
                # in the previous step.
                serviceAccountSecretRef:
                  name: cloud-dns-key
                  key: key.json
      ```

   1. Add your `ClusterIssuer` configuration to your Knative cluster by running
      the following commands, where `<filename>` is the name of the file that
      you created:

      1. Add the configuration file to Knative:

         ```shell
         kubectl apply -f  <filename>.yaml
         ```

      1. Ensure that the file is created successfully:

         ```shell
         kubectl get clusterissuer --namespace cert-manager letsencrypt-issuer --output yaml
         ```

         Result: The `Status.Conditions` should include `Ready=True`.

1. Update your
   [`config-certmanager` ConfigMap](https://github.com/knative/serving/blob/master/config/config-certmanager.yaml)
   in the `knative-serving` namespace to define your new `ClusterIssuer`
   configuration and your your DNS provider.

   1. Run the following command to edit your `config-certmanager` ConfigMap:

      ```shell
      kubectl edit configmap config-certmanager --namespace knative-serving
      ```

   1. Add the `issuerRef` and `solverConfig` sections within the `data` section:

      ```shell
      ...
      data:
      ...
        issuerRef: |
          kind: ClusterIssuer
          name: letsencrypt-issuer

        solverConfig: |
          dns01:
            provider: cloud-dns-provider
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
          name: letsencrypt-issuer
        solverConfig: |
          dns01:
            provider: cloud-dns-provider
      ```

   1. Ensure that the file was updated successfully:

      ```shell
      kubectl get configmap config-certmanager --namespace knative-serving --output yaml
      ```

1. Update the
   [`config-network` ConfigMap](https://github.com/knative/serving/blob/master/config/config-network.yaml)
   in the `knative-serving` namespace to enable `autoTLS`and specify how HTTP
   requests are handled:

   1. Run the following command to edit your `config-network` ConfigMap:

      ```shell
      kubectl edit configmap config-network --namespace knative-serving
      ```

   1. Add the `autoTLS: Enabled` attribute under the `data` section:

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

   1. Configure how HTTP and HTTPS requests are handled in the
      [`httpProtocol`](https://github.com/knative/serving/blob/master/config/config-network.yaml#L110)
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

   1. Ensure that the file was updated successfully:

   ```shell
    kubectl get configmap config-network --namespace knative-serving --output yaml
   ```

Congratulations! Knative is now configured to obtain and renew TLS certificates.
When your TLS certificate is active on your cluster, your Knative services will
be able to handle HTTPS traffic.
