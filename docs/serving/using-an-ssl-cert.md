---
title: "Configuring HTTPS with a custom certificate"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 60
---

If you already have an SSL/TLS certificate for your domain you can follow the
steps below to configure Knative to use your certificate and enable HTTPS
connections.

Before you begin, you will need to
[configure Knative to use your custom domain](../using-a-custom-domain/).

**Note:** due to limitations in Istio, Knative only supports a single
certificate per cluster. If you will serve multiple domains in the same cluster,
make sure the certificate is signed for all the domains.

## Add the Certificate and Private Key into a secret

> Note, if you don't have a certificate, you can find instructions on obtaining
> an SSL/TLS certificate using LetsEncrypt at the bottom of this page.

Assuming you have two files, `cert.pk` which contains your certificate private
key, and `cert.pem` which contains the public certificate, you can use the
following command to create a secret that stores the certificate. Note the name
of the secret, `istio-ingressgateway-certs` is required.

```shell
kubectl create --namespace istio-system secret tls istio-ingressgateway-certs \
  --key cert.pk \
  --cert cert.pem
```

## Configure the Knative shared Gateway to use the new secret

Once you have created a secret that contains the certificate, you need to update
the Gateway spec to use the HTTPS.

To edit the shared gateway, run:

```shell
kubectl edit gateway knative-ingress-gateway --namespace knative-serving
```

Change the Gateway spec to include the `tls:` section as shown below, then save
the changes.

```yaml
# Please edit the object below. Lines beginning with a '#' will be ignored.
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  # ... skipped ...
spec:
  selector:
    knative: ingressgateway
  servers:
    - hosts:
        - "*"
      port:
        name: http
        number: 80
        protocol: HTTP
    - hosts:
        - "*"
      port:
        name: https
        number: 443
        protocol: HTTPS
      tls:
        mode: SIMPLE
        privateKey: /etc/istio/ingressgateway-certs/tls.key
        serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
```

Once the change has been made, you can now use the HTTPS protocol to access your
deployed services.

## Obtaining an SSL/TLS certificate using Let’s Encrypt through CertBot

If you don't have an existing SSL/TLS certificate, you can use [Let's
Encrypt][le] to obtain a certificate manually.

> **Warning:** Certificates issued by [Let's Encrypt][le] are only valid for
> [90 days](https://letsencrypt.org/docs/faq/). You must renew your certificate
> with the certbot tool again every 90 days.

[le]: https://letsencrypt.org/

1. Install the `certbot-auto` script from the
   [Certbot website](https://certbot.eff.org/docs/install.html#certbot-auto).
1. Use the certbot to request a certificate, using DNS validation. The certbot
   tool will walk you through validating your domain ownership by creating TXT
   records in your domain.

   ```shell
   ./certbot-auto certonly --manual --preferred-challenges dns -d '*.default.yourdomain.com'
   ```

1. When certbot is complete, you will have two output files, `privkey.pem` and
   `fullchain.pem`. These files map to the `cert.pk` and `cert.pem` files used
   above.

## Obtaining an SSL/TLS certificate using LetsEncrypt with cert-manager

You can also use [cert-manager](https://github.com/jetstack/cert-manager) to
automate the steps required to generate a TLS certificate using LetsEncrypt.

### Install cert-manager

To install cert-manager into your cluster, use kubectl to apply the cert-manager
manifest:

```
kubectl apply --filename https://raw.githubusercontent.com/jetstack/cert-manager/release-0.5/contrib/manifests/cert-manager/with-rbac.yaml
```

or see the
[cert-manager docs](https://cert-manager.readthedocs.io/en/latest/getting-started/)
for more ways to install and customize.

### Configure cert-manager for your DNS provider

Once you have installed cert-manager, you'll need to configure it for your DNS
hosting provider.

Knative currently only works with the `DNS01` challenge type for LetsEncrypt,
which is only supported by a
[small number of DNS providers through cert-manager](http://docs.cert-manager.io/en/latest/reference/issuers/acme/dns01.html?highlight=DNS#supported-dns01-providers).

Instructions for configuring cert-manager are provided for the following DNS
hosts:

- [Google Cloud DNS](using-cert-manager-on-gcp/)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
