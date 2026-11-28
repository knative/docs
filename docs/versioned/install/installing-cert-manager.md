---
audience: administrator
components:
  - serving
function: how-to
---

# Installing cert-manager for TLS certificates

Knative integrates with [cert-manager](https://github.com/jetstack/cert-manager) to automatically issue and renew TLS certificates for HTTPS connections. Installing `cert-manager` is required for automatic external-domain TLS, cluster-local TLS, and system-internal TLS (if you only supply your own existing TLS Secrets for custom domains, `cert-manager` is not required).

## Before you begin

You must meet the following requirements to install cert-manager for Knative:

- Knative currently supports cert-manager version `1.0.0` and higher.

## Install cert-manager { #downloading-and-installing-cert-manager }

To download and install cert-manager, follow the [Installation steps](https://cert-manager.io/docs/installation/) from the official `cert-manager` website.

## Using cert-manager with Knative

Knative encryption can be configured in:

* [Serving: Encryption Overview](../serving/encryption/encryption-overview.md)

