# Configuring HTTPS with a custom certificate

If you already have an SSL/TLS certificate for your domain you can
follow the steps below to configure Knative to use your certificate
and enable HTTPS connections.

Before you begin, you will need to 
[configure Knative to use your custom domain](./using-a-custom-domain.md).

**Note:** due to limitations in Istio, Knative only supports a single 
certificate per cluster. If you will serve multiple domains in the same
cluster, make sure the certificate is signed for all the domains.

## Add the Certificate and Private Key into a secret

Assuming you have two files, `cert.pk` which contains your certificate private
key, and `cert.pem` which contains the public certificate, you can use the 
following command to create a secret that stores the certificate. Note the
name of the secret, `istio-ingressgateway-certs` is required.

```shell
kubectl create -n istio-system secret tls istio-ingressgateway-certs \
  --key cert.pk \
  --cert cert.pem
```

## Configure the Knative shared Gateway to use the new secret

Once you have created a secret that contains the certificate,
you need to update the Gateway spec to use the HTTPS.

To edit the shared gateway, run:

```shell
kubectl edit gateway knative-shared-gateway -n knative-serving
```

Change the Gateway spec to include the `tls:` section as shown below, then
save the changes.

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
    - '*'
    port:
      name: http
      number: 80
      protocol: HTTP
  - hosts:
    - '*'
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      mode: SIMPLE
      privateKey: /etc/istio/ingressgateway-certs/tls.key
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
```

