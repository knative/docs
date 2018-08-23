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

> Note, if you don't have a certificate, you can find instructions on obtaining an SSL/TLS certificate using LetsEncrypt at the bottom of this page.

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

Once the change has been made, you can now use the HTTPS protocol to access
your deployed services.


## Obtaining an SSL/TLS certificate using LetsEncrypt through CertBot

If you don't have an existing SSL/TLS certificate, you can use [LetsEncrypt](https://letsencrypt.org)
to obtain a certificate manually.

1. Install the `certbot-auto` script from the [Certbot website](https://certbot.eff.org/docs/install.html#certbot-auto).
1. Use the certbot to request a certificate, using DNS validation. The certbot tool will walk
   you through validating your domain ownership by creating TXT records in your domain.

    ```shell
    ./certbot-auto certonly --manual --preferred-challenges dns -d '*.default.yourdomain.com'
    ```

1. When certbot is complete, you will have two output files, `privkey.pem` and `fullchain.pem`. These files
   map to the `cert.pk` and `cert.pem` files used above.

## Obtaining an SSL/TLS certificate using LetsEncrypt through CertManager

Because CertManager HTTP01 ACME challenge resolver doesn't work with Istio
Gateway yet, we show here how to use the DNS01 challenge.  While this limits the
set of DNS providers to just [a handful](
http://docs.cert-manager.io/en/latest/reference/issuers/acme/dns01.html?highlight=DNS#supported-dns01-providers),
it adds the benefit of getting wildcard certificates.

### Specify a service account to perform the DNS01 ACME challenge

The DNS01 ACME challenge asks the domain owner to add a record to their zone to
prove ownership.  That means we will need to provide some service account to
CertManager so that it can perform the challenge for us.

As an example, Cloud DNS user can create a service account with the project role `dns.admin`:

```
# Set this to your GCP project ID
export PROJECT_ID=<your-project-id>

# Name of the service account you want to create.
export CLOUD_DNS_SA=cert-manager-cloud-dns-admin
gcloud --project $PROJECT_ID iam service-accounts \
  create $CLOUD_DNS_SA \
  --display-name "Service Account to perform ACME DNS-01 challenge."

# Fully-qualified service account name also has project-id information.
export CLOUD_DNS_SA=$CLOUD_DNS_SA@$PROJECT_ID.iam.gserviceaccount.com

# Bind the role dns.admin to this service account, so it can be used to perform
# the ACME DNS01 challenge.
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CLOUD_DNS_SA \
  --role roles/dns.admin

# Download the secret key file for your service account.
gcloud iam service-accounts keys create ~/key.json \
  --iam-account=$CLOUD_DNS_SA
```

After obtaining the service account secret, you will need to publish that
to your cluster.  We use the secret name `cloud-dns-key` here, but you can
choose a different name.

```
# Upload that as a secret in your Kubernetes cluster.
kubectl create secret -n cert-manager generic cloud-dns-key \
  --from-file=key.json=$HOME/key.json

# Delete the local secret
rm ~/key.json

```

### Install CertManager

Run
```
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/master/contrib/manifests/cert-manager/with-rbac.yaml
```
or see [CertManager doc](https://cert-manager.readthedocs.io/en/latest/getting-started/) for more ways to install and customize.


### Configure CertManager to use your DNS admin service account

#### Specify a certificate issuer which is a set of ACME challenge solvers

```
kubectl apply -f - <<EOF
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-issuer
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
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
EOF

```

To check if your ClusterIssuer is valid, run

```
kubectl get cluster -n cert-manager letsencrypt-issuer -o yaml

```
and confirm that its conditions have `Ready=True`.  For an example:

```
status:
  acme:
    uri: https://acme-v02.api.letsencrypt.org/acme/acct/40759665
  conditions:
  - lastTransitionTime: 2018-08-23T01:44:54Z
    message: The ACME account was registered with the ACME server
    reason: ACMEAccountRegistered
    status: "True"
    type: Ready
```

#### Specifying our certificate: which issuer it should use, and which secret to publish the cert.

```
# Change this value to the domain you want to use.
export DOMAIN=your-domain.com

kubectl apply -f - <<EOF
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: my-certificate
  # Istio certs secret lives in the istio-system namespace, and
  # a cert-manager Certificate is namespace-scoped.
  namespace: istio-system
spec:
  # Reference to the Istio default cert secret.
  secretName: istio-ingressgateway-certs
  acme:
    config:
    # Each certificate could comprise of different ACME challenge
    # solver.  In this example we are using one provider for all
    # the domains.
    - dns01:
        provider: cloud-dns-provider
      domains:
      # Since certificate wildcards only allow one level, we will
      # need to one for every namespace.  We don't need to use
      # wildcard here, fully-qualified domains will work fine too.
      - "*.default.$DOMAIN"
      - "*.other-namespace.$DOMAIN"
  dnsNames:
  - "*.default.$DOMAIN"
  - "*.other-namespace.$DOMAIN"
  # Reference to the ClusterIssuer we created in the previous step.
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-issuer
EOF
```

To check that your certificate setting is valid, run

```
k get certificate -n istio-system my-certificate -o yaml
```
and verify that its `Status.Conditions` have `Ready=True`.  For an example

```
status:
  acme:
    order:
      url: https://acme-v02.api.letsencrypt.org/acme/order/40759665/45358362
  conditions:
  - lastTransitionTime: 2018-08-23T02:28:44Z
    message: Certificate issued successfully
    reason: CertIssued
    status: "True"
    type: Ready
```

### Configure our Gateway `knative-shared-gateway` to use the certificate.

```
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: knative-shared-gateway
  namespace: knative-serving
spec:
  selector:
    knative: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - "*"
    tls:
      mode: SIMPLE
      privateKey: /etc/istio/ingressgateway-certs/tls.key
      serverCertificate: /etc/istio/ingressgateway-certs/tls.crt
EOF

```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
