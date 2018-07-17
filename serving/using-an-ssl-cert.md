# Setting up an SSL cert

If you already have an SSL cert for your domain, follow these steps to use it
for your cluster.  See instructions [here](./using-a-custom-domain.md) to set
up a domain for your cluster.

Note that due to Istio limitation we can only use one certificate for our
cluster -- as a result you will need to make sure that your certificate is
signed for all of your cluster's domain names.

## Add the Certificate and Private Key into a secret

Istio requires that the secret must be name `istio-ingressgateway-certs`.
To create the secret, run the following command.

```shell
# Replace <cert.pk> and <cert.pem> in the following command with the correct
# name of your certificate and private key file.
kubectl create -n istio-system secret tls istio-ingressgateway-certs \
    --key cert.pk \
    --cert cert.pem
```

## Configure the Knative shared Gateway to use the new secret

Run this,
```shell
kubectl edit gateway knative-shared-gateway -n knative-serving
```
then update your Gateway spec to look like this
```
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
