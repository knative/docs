---
title: "Configuring HTTPS with cert-manager and Google Cloud DNS"
linkTitle: "Configuring HTTPS with Cloud DNS"
weight: 63
type: "docs"
---

You can use cert-manager with Knative to automatically provision TLS
certificates from Let's Encrypt and use
[Google Cloud DNS](https://cloud.google.com/dns/) to handle HTTPS requests and
validate DNS challenges.

The following guide demonstrates how you can setup Knative to handle secure
HTTPS requests on Google Cloud Platform, specifically using cert-manager for TLS
certificates and [Google Cloud DNS](https://cloud.google.com/dns/) as the DNS
provider.

Learn more about using TLS certificates in Knative:

- [Configuring HTTPS with TLS certificates](./using-a-tls-cert.md)
- [Enabling automatic TLS certificate provisioning](./using-auto-tls.md)

## Before you begin

You must meet the following prerequisites to configure Knative with cert-manager
and Cloud DNS:

- You must have a
  [GCP project ID with owner privileges](https://console.cloud.google.com/cloud-resource-manager).
- [Google Cloud DNS](https://cloud.google.com/dns/docs/how-to) must set up and
  configure for your domain.
- You must have a Knative cluster with the following requirements:
  - Knative Serving running.
  - The Knative cluster must be running on Google Cloud Platform. For details
    about installing the Serving component, see the
    [Knative installation guides](../install/).
  - Your Knative cluster must be configured to use a
    [custom domain](./using-a-custom-domain.md).
  - [cert-manager v0.6.1 or higher installed](./installing-cert-manager.md)
- Your DNS provider must be setup and configured to your domain.

## Creating a service account and using a Kubernetes secret

To allow cert-manager to access and update the DNS record, you must create a
service account in GCP, add the key in a Kubernetes secret, and then add that
secret to your Knative cluster.

Note that several example names are used in the following commands, for example
secret or file names, which can all be changed to your liking.

1. Create a service account in GCP with `dns.admin` project role by running the
   following commands, where `<your-project-id>` is the ID of your GCP project:

   ```shell
   # Set this to your GCP project ID
   export PROJECT_ID=<your-project-id>

   # Name of the service account you want to create.
   export CLOUD_DNS_SA=cert-manager-cloud-dns-admin
   gcloud --project $PROJECT_ID iam service-accounts \
     create $CLOUD_DNS_SA \
     --display-name "Service Account to support ACME DNS-01 challenge."

   # Fully-qualified service account name also has project-id information.
   export CLOUD_DNS_SA=$CLOUD_DNS_SA@$PROJECT_ID.iam.gserviceaccount.com

   # Bind the role dns.admin to this service account, so it can be used to support
   # the ACME DNS01 challenge.
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member serviceAccount:$CLOUD_DNS_SA \
     --role roles/dns.admin
   ```

1. Download the service account key by running the following commands:

   ```shell
   # Make a temporary directory to store key
   KEY_DIRECTORY=`mktemp -d`

   # Download the secret key file for your service account.
   gcloud iam service-accounts keys create $KEY_DIRECTORY/cloud-dns-key.json \
     --iam-account=$CLOUD_DNS_SA
   ```

1. Create a Kubernetes secret and then add that secret to your Knative cluster
   by running the following commands:

   ```shell
   # Upload that as a secret in your Kubernetes cluster.
   kubectl create secret --namespace cert-manager generic cloud-dns-key \
     --from-file=key.json=$KEY_DIRECTORY/cloud-dns-key.json

   # Delete the local secret
   rm -rf $KEY_DIRECTORY
   ```

## Adding your service account to cert-manager

Create a `ClusterIssuer` configuration file to define how cert-manager obtains
TLS certificates and how the requests are validated with Cloud DNS.

1. Run the following command to create the `ClusterIssuer` configuration. The
   following creates the `letsencrypt-issuer` `ClusterIssuer`, that includes
   your Let's Encrypt account info, `DNS-01` challenge type, and Cloud DNS
   provider info, including your `cert-manager-cloud-dns-admin` service account.

   ```shell
    kubectl apply --filename - <<EOF
    apiVersion: cert-manager.io/v1alpha2
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-issuer
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        # This will register an issuer with LetsEncrypt.  Replace
        # with your admin email address.
        email: myemail@gmail.com
        privateKeySecretRef:
          # Set privateKeySecretRef to any unused secret name.
          name: letsencrypt-issuer
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
    EOF
   ```

1. Ensure that `letsencrypt-issuer` is created successfully by running the
   following command:

   ```shell
   kubectl get clusterissuer --namespace cert-manager letsencrypt-issuer --output yaml
   ```

   Result: The `Status.Conditions` should include `Ready=True`. For example:

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

## Add `letsencrypt-issuer` to your ingress secret to configure your certificate

To configure how Knative uses your TLS certificates, you create a `Certificate`
to add `letsencrypt-issuer` to the `istio-ingressgateway-certs` secret.

Note that `istio-ingressgateway-certs` will be overridden if the secret already
exists.

1. Run the following commands to create the `my-certificate` `Certificate`,
   where `<your-domain.com>` is your domain:

   ```shell
  # Change this value to the domain you want to use.
  export DOMAIN=<your-domain.com>

  kubectl apply --filename - <<EOF
  apiVersion: cert-manager.io/v1alpha2
  kind: Certificate
  metadata:
    name: my-certificate
    namespace: istio-system
  spec:
    secretName: istio-ingressgateway-certs
    issuerRef:
      name: letsencrypt-issuer
    dnsNames:
    - "*.default.$DOMAIN"
    - "*.other-namespace.$DOMAIN"
  EOF
   ```

1. Ensure that `my-certificate` is created successfully by running the following
   command:

   ```shell
   kubectl get certificate --namespace istio-system my-certificate --output yaml
   ```

   Result: The `Status.Conditions` should include `Ready=True`. For example:

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

Note: If `Status.Conditions` is `Ready=False`, that indicates a failure to
obtain a certificate, which should be explained in the accompanying error
message.

## Configuring the Knative ingress gateway

To configure the `knative-ingress-gateway` to use the TLS certificate that you
created, append the `tls:` section to the end of your HTTPS port configuration.

Run the following commands to configure Knative to use HTTPS connections and
send a `301` redirect response for all HTTP requests:

```shell
kubectl apply --filename - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: knative-ingress-gateway
  namespace: knative-serving
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
    tls:
      # Sends 301 redirect for all http requests.
      # Omit to allow http and https.
      httpsRedirect: true
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

Congratulations, you can now access your Knative services with secure HTTPS
connections. Your Knative cluster is configured to use cert-manager to manually
obtain TLS certificates but see the following section about automating that
process.

## Configure Knative for automatic certificate provisioning

You can update your Knative configuration to automatically obtain and renew TLS
certificates before they expire. To learn more about automatic certificates, see
[Enabling automatic TLS certificate provisioning](./using-auto-tls.md).
