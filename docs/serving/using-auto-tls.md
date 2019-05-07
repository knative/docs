---
title: "Using Auto-TLS in Knative"
weight: 15
type: "docs"
---

Within Knative, we provide a feature of automatically provisioning and 
configuring TLS certificates to terminate the external TLS connection. This doc
provides a guide about how to enable and configure Auto TLS feature in Knative.

## Prerequisites

<!-- TODO(zhiminx) add the link about installing Istio with SDS enabled after PR https://github.com/knative/docs/pull/1272 is checked in-->
1. Follow the [instructions]() to install Istio with SDS enabled. Istio version
needs to be 1.1 or above. And currently this feature does not work with 
Gloo yet.
2. Follow the [instructions](./installing-cert-manager.md) to install Cert-Manager.
3. Follow the [instructions](../install) to install Knative cluster. Knative 
version needs to be 0.6.0 or above.

## Install Knative networking-certmanager components

Skip this step if you already have Knative networking-certmanager components installed.
Run below command to install Knative networking-certmanager components.
```shell
# KNATIVE_VERSION needs to be 0.6.0 or above.
KNATIVE_VERSION=0.6.0

kubectl apply --filename https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/serving.yaml \ 
-l networking.knative.dev/certificate-provider=cert-manager
```

## Configure Cert-Manager

> Note that currently the Auto-TLS feature only supports DNS challenge.

### Set up DNS challenge Provider

Follow the [instructions](https://docs.cert-manager.io/en/latest/tasks/acme/configuring-dns01/index.html#supported-dns01-providers) to set up DNS challenge issuer according to the 
DNS provider of your custom domain.

#### Google Cloud DNS Provider Instruction

Specifically for Google Cloud DNS, below are steps to set up the DNS challenge 
issuer.

##### Set up Cloud DNS servers

Skip this step if you already have Cloud DNS set up for your domain in your 
GCP project.
Follow the [instructions](https://cloud.google.com/dns/docs/how-to) to set up Cloud DNS first.

##### Creating a Cloud DNS service account

Configure Knative with a service account that can be used
by cert-manager to create and update the DNS record.

To begin, create a new service account with the project role `dns.admin`:

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

# Make a temporary directory to store key
KEY_DIRECTORY=`mktemp -d`

# Download the secret key file for your service account.
gcloud iam service-accounts keys create $KEY_DIRECTORY/cloud-dns-key.json \
  --iam-account=$CLOUD_DNS_SA
```

After obtaining the service account secret, publish it to your cluster. This
command uses the secret name `cloud-dns-key`, but you can choose a different
name.

```shell
# Upload that as a secret in your Kubernetes cluster.
kubectl create secret --namespace cert-manager generic cloud-dns-key \
  --from-file=key.json=$KEY_DIRECTORY/cloud-dns-key.json

# Delete the local secret
rm -rf $KEY_DIRECTORY
```

##### Specifying a certificate issuer

Create a ClusterIssuer as below.

```shell
kubectl apply --filename - <<EOF
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
EOF
```

To check if your ClusterIssuer is valid, enter:

```shell
kubectl get clusterissuer --namespace cert-manager letsencrypt-issuer --output yaml
```
Then confirm that its conditions have `Ready=True`. 

## Configure Auto TLS in Knative

### Configure `config-certmanager` ConfigMap
Configure `issuerRef` and `solverConfig` in the ConfigMap `config-certmanager` 
according to the created `ClusterIssuer`.

For above [ClusterIssuer](#Specifying-a-certificate-issuer) example, the corresponding `issuerRef` and 
`solverConfig` are
```
issuerRef: |
  kind: ClusterIssuer
  name: letsencrypt-issuer

solverConfig: |
  dns01:
    provider: cloud-dns-provider
```

### Configure Custom Domain
Follow the [instructions](https://github.com/knative/docs/blob/master/docs/serving/using-a-custom-domain.md#edit-using-kubectl) to configure the domain of Knative serving with your custom domain.

### Turn on Auto TLS

Add the entry `autoTLS:Enabled` into the ConfigMap `config-network` under 
`knative-serving` namespace to turn on Auto TLS. The ConfigMap should look 
like:
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

### Configure HTTP Protocol

By default, Knative ingress is still able to serve HTTP traffic.
If you want to change the way of handling HTTP traffic, configure the 
value [httpProtocol](https://github.com/knative/serving/blob/9c51850c3d4b8a3665c0d2fab3fa840a9e1e4334/config/config-network.yaml#L110) in the ConfigMap `config-network` accordingly.
Specifically, add the entry `httpProtocol:{your-new-http-way}` into the ConfigMap `config-network` under `knative-serving` namespace. 
The ConfigMap should look like:
```
apiVersion: v1
data:
  _example: |
  ...

  # Add this entry in the `data` field.
  httpProtocol:{your-new-http-way}
kind: ConfigMap
metadata:
  name: config-network
  namespace: knative-serving
...
```

At this point, Auto TLS feature is configured and ready to use. When deploying 
a Knative service, you should be able to send HTTPS traffic to it when the TLS
certificate is ready.