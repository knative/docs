---
audience: administrator
components:
  - serving
function: how-to
---

# Installing cert-manager for TLS certificates

Knative leverages [cert-manager](https://github.com/jetstack/cert-manager) to request TLS certificates
used for secure HTTPS connections in Knative. Installing [cert-manager](https://github.com/jetstack/cert-manager)
is required before enabling any of the Knative encryption features. Follow the steps below for the installation.

## Before you begin

You must meet the following requirements to install cert-manager for Knative:

- Knative currently supports cert-manager version `1.0.0` and higher.

## Downloading and installing cert-manager

To download and install cert-manager, follow the [Installation steps](https://cert-manager.io/docs/installation/) from the official `cert-manager` website.

## Using cert-manager with Knative

Knative encryption can be configured in:

* [Serving: Encryption Overview](../serving/encryption/encryption-overview.md)

