---
title: "Installing cert-manager for TLS certificates"
linkTitle: "Installing cert-manager"
weight: 62
type: "docs"
---

Install the  [Cert-Manager](https://github.com/jetstack/cert-manager) tool to obtain TLS 
certificates that you can use for secure HTTPS connections in Knative. For more information 
about enabling HTTPS connections in Knative, see 
[Configuring HTTPS with TLS certificates](./using-an-tls-cert.md).

You can use cert-manager to either manually obtain certificates, or to enable Knative for 
automatic certificate provisioning.
Complete instructions about automatic certificate provisioning are provided in 
[Enabling automatic TLS cert provisioning](./using-auto-tls.md).

Regardless of if your want to manually obtain certificates, or configure Knative for automatic
provisioning, you can use the follwoing steps to install cert-manager.

## Before you begin

You must meet the following requirements to install cert-manager for Knative:

- Knative Serving must be installed. For details about installing the Serving
  component, see the [Knative installation guides](../install/).
- You must configure your Knative cluster to use a
  [custom domain](./using-a-custom-domain.md).
- Knative currently supports cert-manager version `0.6.1` or higher.

## Downloading and installing cert-manager

Use the following steps to download, install, and configure cert-manager for your Knative cluster
environment:

1. Run the following commands to download and extract the `cert-manager` installation package:

    ```shell
    CERT_MANAGER_VERSION=0.6.1
    DOWNLOAD_URL=https://github.com/jetstack/cert-manager/archive/v${CERT_MANAGER_VERSION}.tar.gz

    wget $DOWNLOAD_URL
    tar xzf v${CERT_MANAGER_VERSION}.tar.gz

    cd cert-manager-${CERT_MANAGER_VERSION} 
    ```

1. Run the following commands to install cert-manager:

    1. Install the cert-manager CRDs:

       ```shell
       kubectl apply -f deploy/manifests/00-crds.yaml
       ```

    1. Run one of the following commands to install the cert-manager plugin:

       - For Knative clusters running Kubernetes version 1.13 or above:

          ```shell
          # If you are running cluster version 1.13 or above
          kubectl apply -f deploy/manifests/cert-manager.yaml
          ```

        - For Knative clusters running Kubernetes version 1.12 or below:

          ```shell
          # If you are running cluster version 1.12 or below, you must append the --validate=false flag
          kubectl apply -f deploy/manifests/cert-manager.yaml --validate=false
          ```

1. Configure which DNS provider is to validate the DNS-01 challenge requests.

    By default, the [Let's Encrypt](https://letsencrypt.org) is used to
    demonstrate how to configure cert-manager, but you can use other supported CA's 
    that issue certificates with the ACME protocol. However, you
    must use and configure your CA to use the
    [`DNS-01` challenge type](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge).

    Instructions about configuring cert-manager for any of the supported DNS providers are provided in
    [DNS01 challenge providers and configuration instructions](https://docs.cert-manager.io/en/latest/tasks/acme/configuring-dns01/index.html#supported-dns01-providers).

    **Example**

    [Configure cert-manager for Google Cloud DNS](./using-auto-tls.md#Set-up-DNS-challenge-Provider)

1. Post-install cleanup

    Run the following commands to remove the cert-manager install packages:

    ```shell
    cd ../
    rm -rf cert-manager-${CERT_MANAGER_VERSION}
    rm v${CERT_MANAGER_VERSION}.tar.gz
    ```

## Completing the Knative configuration for TLS support

Before you can use a TLS certificate for secure connections, you must finish configuring Knative:

- **Manual**: If you installed cert-manager to manually obtain certificates, continue to the following topic
  for instructions about creating a Kubernetes secret: [Manually adding a TLS certificate](./using-an-tls-cert.md#manually-adding-a-tls-certificate) 
  
- **Automatic**: If you installed cert-manager to use for automatic certificate provisioning, continue to the following topic
  to enable that feature: [Enabling automatic TLS certificate provisioning in Knative](./using-auto-tls.md)
