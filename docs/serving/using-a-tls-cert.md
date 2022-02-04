# Configuring HTTPS with TLS certificates

Learn how to configure secure HTTPS connections in Knative using TLS
certificates
([TLS replaces SSL](https://en.wikipedia.org/wiki/Transport_Layer_Security)).
Configure secure HTTPS connections to enable your Knative services and routes to
[terminate external TLS connections](https://en.wikipedia.org/wiki/Transport_Layer_Security#TLS_interception).
You can configure Knative to handle certificates that you manually specify, or
you can enable Knative to automatically obtain and renew certificates.

You can use either [Certbot][cb] or [cert-manager][cm] to obtain certificates.
Both tools support TLS certificates but if you want to enable Knative for
automatic TLS certificate provisioning, you must install and configure the
cert-manager tool:

- **Manually obtain and renew certificates**: Both the Certbot and cert-manager
  tools can be used to manually obtain TLS certificates. In general, after you
  obtain a certificate, you must create a Kubernetes secret to use that
  certificate in your cluster. See the procedures later in this topic for details
  about manually obtaining and configuring certificates.

- **Enable Knative to automatically obtain and renew TLS certificates**: You can
  also use cert-manager to configure Knative to automatically obtain new TLS
  certificates and renew existing ones. If you want to enable Knative to
  automatically provision TLS certificates, instead see the
  [Enabling automatic TLS certificate provisioning](using-auto-tls.md) topic.

By default, the [Let's Encrypt Certificate Authority (CA)][le] is used to
demonstrate how to enable HTTPS connections, but you can configure Knative to
use any certificate from a CA that supports the ACME protocol. However, you must
use and configure your certificate issuer to use the
[`DNS-01` challenge type](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge).

!!! warning
    Certificates issued by Let's Encrypt are valid for only [90days][le-faqs]. Therefore, if you choose to manually obtain and configure your certificates, you must ensure that you renew each certificate before it expires.

[cm]: https://github.com/jetstack/cert-manager
[cm-docs]: https://cert-manager.readthedocs.io/en/latest/getting-started/
[cm-providers]:
  http://docs.cert-manager.io/en/latest/tasks/acme/configuring-dns01/index.html?highlight=supported%20DNS01%20providers#supported-dns01-providers
[le]: https://letsencrypt.org
[le-faqs]: https://letsencrypt.org/docs/faq/
[cb]: https://certbot.eff.org
[cb-docs]: https://certbot.eff.org/docs/install.html#certbot-auto
[cb-providers]: https://certbot.eff.org/docs/using.html#changing-the-acme-server
[cb-cli]: https://certbot.eff.org/docs/using.html#certbot-command-line-options

## Before you begin

You must meet the following requirements to enable secure HTTPS connections:

- Knative Serving must be installed. For details about installing the Serving
  component, see the [Knative installation guides](../install/yaml-install/serving/install-serving-with-yaml.md).
- You must configure your Knative cluster to use a
  [custom domain](using-a-custom-domain.md).

!!! warning
    Istio only supports a single certificate per Kubernetes cluster.
    To serve multiple domains using your Knative cluster, you must ensure that your new or existing certificate is signed for each of the domains that you want to serve.

## Obtaining a TLS certificate

If you already have a signed certificate for your domain, see
[Manually adding a TLS certificate](#manually-adding-a-tls-certificate) for
details about configuring your Knative cluster.

If you need a new TLS certificate, you can choose to use one of the following
tools to obtain a certificate from Let's Encrypt:

- Setup Certbot to manually obtain Let's Encrypt certificates
- Setup cert-manager to either manually obtain a certificate, or to
  automatically provision certificates

This page covers details for both options.

For details about using other CA's, see the tool's reference documentation:

- [Certbot supported providers][cb-providers]
- [cert-manager supported providers][cm-providers]

### Using Certbot to manually obtain Let’s Encrypt certificates

Use the following steps to install [Certbot][cb] and the use the tool to
manually obtain a TLS certificate from Let's Encrypt.

1. Install Certbot by following the [`certbot-auto` wrapper script][cb-docs]
   instructions.

1. Run the following command to use Certbot to request a certificate using DNS
   challenge during authorization:

     ```bash
     ./certbot-auto certonly --manual --preferred-challenges dns -d '*.default.yourdomain.com'
     ```

   where `-d` specifies your domain. If you want to validate multiple domain's,
   you can include multiple flags:
   `-d MY.EXAMPLEDOMAIN.1 -d MY.EXAMPLEDOMAIN.2`. For more information, see the
   [Cerbot command-line][cb-cli] reference.

   The Certbot tool walks you through the steps of validating that you own each
   domain that you specify by creating TXT records in those domains.

   Result: CertBot creates two files:

   - Certificate:`fullchain.pem`
   - Private key: `privkey.pem`

What's next:

Add the certificate and private key to your Knative cluster by
[creating a Kubernetes secret](#manually-adding-a-tls-certificate).

### Using cert-manager to obtain Let's Encrypt certificates

You can install and use [cert-manager][cm] to either manually obtain a
certificate or to configure your Knative cluster for automatic certificate
provisioning:

- **Manual certificates**: Install cert-manager and then use the tool to
  manually obtain a certificate.

  To use cert-manager to manually obtain certificates:

  1.  [Install and configure cert-manager](../install/installing-cert-manager.md).

  1.  Continue to the steps about
      [manually adding a TLS certificate](#manually-adding-a-tls-certificate) by
      creating and using a Kubernetes secret.

- **Automatic certificates**: Configure Knative to use cert-manager for
  automatically obtaining and renewing TLS certificate. The steps for installing
  and configuring cert-manager for this method are covered in full in the
  [Enabling automatic TLS cert provisioning](using-auto-tls.md) topic.

## Manually adding a TLS certificate

If you have an existing certificate or have used one of the Certbot or
cert-manager tool to manually obtain a new certificate, you can use the
following steps to add that certificate to your Knative cluster.

For instructions about enabling Knative for automatic certificate provisioning,
see [Enabling automatic TLS cert provisioning](using-auto-tls.md). Otherwise,
follow the steps in the relevant tab to manually add a certificate:


=== "Contour"

    To manually add a TLS certificate to your Knative cluster, you must create a
    Kubernetes secret and then configure the Knative Contour plugin.

    1. Create a Kubernetes secret to hold your TLS certificate, `cert.pem`, and the
       private key, `key.pem`, by running the command:

           ```bash
           kubectl create -n contour-external secret tls default-cert \
             --key key.pem \
             --cert cert.pem
           ```

        !!! note
            Take note of the namespace and secret name. You will need these in future steps.

    1. To use this certificate and private key in different namespaces, you must
    create a delegation. To do so, create a YAML file using the following template:

         ```yaml
         apiVersion: projectcontour.io/v1
         kind: TLSCertificateDelegation
         metadata:
           name: default-delegation
           namespace: contour-external
         spec:
           delegations:
             - secretName: default-cert
               targetNamespaces:
               - "*"
         ```
    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

    1. Update the Knative Contour plugin to use the certificate as a fallback
       when autoTLS is disabled by running the command:

         ```bash
         kubectl patch configmap config-contour -n knative-serving \
           -p '{"data":{"default-tls-secret":"contour-external/default-cert"}}'
         ```



=== "Istio"
    To manually add a TLS certificate to your Knative cluster, you create a
    Kubernetes secret and then configure the `knative-ingress-gateway`:

    1. Create a Kubernetes secret to hold your TLS certificate, `cert.pem`, and the
       private key, `key.pem`, by entering the following command:

       ```bash
       kubectl create --namespace istio-system secret tls tls-cert \
         --key key.pem \
         --cert cert.pem
       ```


    1. Configure Knative to use the new secret that you created for HTTPS
       connections:

       1. Run the following command to open the Knative shared `gateway` in edit
          mode:

          ```bash
          kubectl edit gateway knative-ingress-gateway --namespace knative-serving
          ```

       1. Update the `gateway` to include the following `tls:` section and
          configuration:

          ```yaml
          tls:
            mode: SIMPLE
            credentialName: tls-cert
          ```

          Example:

          ```yaml
          # Edit the following object. Lines beginning with a '#' will be ignored.
          # An empty file will abort the edit. If an error occurs while saving this
          # file will be reopened with the relevant failures.
          apiVersion: networking.istio.io/v1alpha3
          kind: Gateway
          metadata:
            # ... skipped ...
          spec:
            selector:
              istio: ingressgateway
            servers:
              - hosts:
                  - "*"
                port:
                  name: http
                  number: 80
                  protocol: HTTP
              - hosts:
                  - TLS_HOSTS
                port:
                  name: https
                  number: 443
                  protocol: HTTPS
                tls:
                  mode: SIMPLE
                  credentialName: tls-cert
          ```
          In this example, `TLS_HOSTS` represents the hosts of your TLS certificate. It can be a single host, multiple hosts, or a wildcard host.
          For detailed instructions, please refer [Istio documentation](https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/)

## What's next:

After your changes are running on your Knative cluster, you can begin using the
HTTPS protocol for secure access your deployed Knative services.
