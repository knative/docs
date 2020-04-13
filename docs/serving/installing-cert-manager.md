---
title: "Installing cert-manager for TLS certificates"
linkTitle: "Installing cert-manager"
weight: 62
type: "docs"
---

Install the [Cert-Manager](https://github.com/jetstack/cert-manager) tool to
obtain TLS certificates that you can use for secure HTTPS connections in
Knative. For more information about enabling HTTPS connections in Knative, see
[Configuring HTTPS with TLS certificates](./using-a-tls-cert.md).

You can use cert-manager to either manually obtain certificates, or to enable
Knative for automatic certificate provisioning. Complete instructions about
automatic certificate provisioning are provided in
[Enabling automatic TLS cert provisioning](./using-auto-tls.md).

Regardless of if your want to manually obtain certificates, or configure Knative
for automatic provisioning, you can use the follwoing steps to install
cert-manager.

## Before you begin

You must meet the following requirements to install cert-manager for Knative:

- Knative Serving must be installed. For details about installing the Serving
  component, see the [Knative installation guides](../install/).
- You must configure your Knative cluster to use a
  [custom domain](./using-a-custom-domain.md).
- Knative currently supports cert-manager version `0.12.0` or higher.

## Downloading and installing cert-manager

Use the following steps to download, install, and configure cert-manager for
your Knative cluster environment:

1. Follow the steps in the official `cert-manager` website to download and install cert-manager

   [Installation steps](https://cert-manager.io/docs/installation/kubernetes/)

1. Configure which DNS provider is used to validate the DNS-01 challenge
   requests.

   By default, the [Let's Encrypt](https://letsencrypt.org) is used to
   demonstrate how to configure cert-manager, but you can use other supported
   CA's that issue certificates with the ACME protocol. However, you must use
   the
   [`DNS-01` challenge type](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge)
   to validate requests.

   Instructions about configuring cert-manager for any of the supported DNS
   providers are provided in
   [DNS01 challenge providers and configuration instructions](https://docs.cert-manager.io/en/latest/tasks/acme/configuring-dns01/index.html#supported-dns01-providers).

   Example:

   See how the Google Cloud DNS is defined as the provider:
   [Configuring HTTPS with cert-manager and Google Cloud DNS](./using-cert-manager-on-gcp.md#adding-your-service-account-to-cert-manager)

1. Post-install cleanup

   Run the following commands to remove the cert-manager install packages:

   ```shell
   cd ../
   rm -rf cert-manager-${CERT_MANAGER_VERSION}
   rm v${CERT_MANAGER_VERSION}.tar.gz
   ```

## Completing the Knative configuration for TLS support

Before you can use a TLS certificate for secure connections, you must finish
configuring Knative:

- **Manual**: If you installed cert-manager to manually obtain certificates,
  continue to the following topic for instructions about creating a Kubernetes
  secret:
  [Manually adding a TLS certificate](./using-a-tls-cert.md#manually-adding-a-tls-certificate)

- **Automatic**: If you installed cert-manager to use for automatic certificate
  provisioning, continue to the following topic to enable that feature:
  [Enabling automatic TLS certificate provisioning in Knative](./using-auto-tls.md)
