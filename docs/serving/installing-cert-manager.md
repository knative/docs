---
title: "Performing a Cert-Manager Installation"
weight: 15
type: "docs"
---

Within Knative, we provide a feature of automatically provisioning and 
configuring TLS certificates to terminate the external TLS connection. This 
feature needs [Cert-Manager](https://github.com/jetstack/cert-manager) to be 
installed within your cluster.
This doc provides a guide to install Cert-Manager.

<!-- TODO(zhiminx) add the link of networking-certmanager deployment after the code is checked in.-->
> Note: Cert-Manager CRDs need to be installed if Knative 
> [networking-certmanager deployment]() is installed in your 
> cluster (no matter whether the auto TLS will be used). 

## Download Cert-Manager
Run below command to download `Cert-Manager`
```shell
CERT_MANAGER_VERSION=0.6.1
DOWNLOAD_URL=https://github.com/jetstack/cert-manager/archive/v${CERT_MANAGER_VERSION}.tar.gz

wget $DOWNLOAD_URL
tar xzf v${CERT_MANAGER_VERSION}.tar.gz

cd cert-manager-${CERT_MANAGER_VERSION} 
```

## Install Cert-Manager CRDs
Run below command to install Cert-Manager CRDs
```shell
kubectl apply -f deploy/manifests/00-crds.yaml
```

## Install Full Cert-Manager
To use Knative Auto TLS feature, a full Cert-Manager needs to be 
installed.
Run below command to install Cert-Manager:

```shell
# If you are running cluster in 1.12 or below, you will need to add the --validate=false flag
kubectl apply -f deploy/manifests/cert-manager.yaml --validate=false
```
Or
```shell
# If you are running cluster in 1.13 or above
kubectl apply -f deploy/manifests/cert-manager.yaml 
```

## Clean UP
```shell
cd ../
rm -rf cert-manager-${CERT_MANAGER_VERSION}
rm v${CERT_MANAGER_VERSION}.tar.gz
```

## Set up Auto-TLS within Knative
For more information about setting up Auto-TLS within Knative, please check
the [doc](./using-auto-tls.md).
