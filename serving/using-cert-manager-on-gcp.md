## Configure Knative and cert-manager for Google Cloud DNS

These instructions assuming you have already setup a Knative cluster and
installed cert-manager into your cluster. For more information, see [using an
SSL certificate](using-an-ssl-cert.md). Another assumption is that you already
setup your managed zone with Cloud DNS, as part of configuring the domain to
map to your IP address.

To automate the generation of a certificate with cert-manager and LetsEncrypt,
we will use a `DNS01` challenge type, which requires the domain owner to add a TXT record
to their zone to prove ownership. Other challenge types are not currently supported by
Knative.

### Create a Cloud DNS service account
To be able to add the TXT record, we need to configure Knative with a service account
that can be used by cert-manager to create and update this DNS record.

To begin, we create a new service account with the project role `dns.admin`:

```shell
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

```shell
# Upload that as a secret in your Kubernetes cluster.
kubectl create secret -n cert-manager generic cloud-dns-key \
  --from-file=key.json=$HOME/key.json

# Delete the local secret
rm ~/key.json

```

### Configure CertManager to use your DNS admin service account

#### Specify a certificate issuer which is a set of ACME challenge solvers

```shell
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

```shell
kubectl get clusterissuer -n cert-manager letsencrypt-issuer -o yaml
```
and confirm that its conditions have `Ready=True`.  For an example:

```yaml
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

```shell
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
  # The certificate common name, use one from your domains.
  commonName: "*.default.$DOMAIN"
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

```shell
kubectl get certificate -n istio-system my-certificate -o yaml
```
and verify that its `Status.Conditions` have `Ready=True`.  For an example

```yaml
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

```shell
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
