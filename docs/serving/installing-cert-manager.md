# Installing cert-manager for TLS certificates

Install the [Cert-Manager](https://github.com/jetstack/cert-manager) tool to
obtain TLS certificates that you can use for secure HTTPS connections in
Knative. For more information about enabling HTTPS connections in Knative, see
[Configuring HTTPS with TLS certificates](using-a-tls-cert.md).

You can use cert-manager to either manually obtain certificates, or to enable
Knative for automatic certificate provisioning. Complete instructions about
automatic certificate provisioning are provided in
[Enabling automatic TLS cert provisioning](using-auto-tls.md).

Regardless of if your want to manually obtain certificates, or configure Knative
for automatic provisioning, you can use the following steps to install
cert-manager.

## Before you begin

You must meet the following requirements to install cert-manager for Knative:

- Knative Serving must be installed. For details about installing the Serving
  component, see the [Knative installation guides](../install/).
- You must configure your Knative cluster to use a
  [custom domain](using-a-custom-domain.md).
- Knative currently supports cert-manager version `1.0.0` and higher.

## Downloading and installing cert-manager

Follow the steps from the official `cert-manager` website to download and install cert-manager

   [Installation steps](https://cert-manager.io/docs/installation/kubernetes/)


## Completing the Knative configuration for TLS support

Before you can use a TLS certificate for secure connections, you must finish
configuring Knative:

- **Manual**: If you installed cert-manager to manually obtain certificates,
  continue to the following topic for instructions about creating a Kubernetes
  secret:
  [Manually adding a TLS certificate](using-a-tls-cert.md#manually-adding-a-tls-certificate)

- **Automatic**: If you installed cert-manager to use for automatic certificate
  provisioning, continue to the following topic to enable that feature:
  [Enabling automatic TLS certificate provisioning in Knative](using-auto-tls.md)
