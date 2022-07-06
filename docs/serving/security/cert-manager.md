### TLS with cert-manager

Install the [Cert-Manager](https://github.com/jetstack/cert-manager) tool to
obtain TLS certificates that you can use for secure HTTPS connections in
Knative. For more information about enabling HTTPS connections in Knative, see Configuring HTTPS with TLS certificates.

You can use cert-manager to either manually obtain certificates, or to enable
Knative for automatic certificate provisioning. Complete instructions about
automatic certificate provisioning are provided in Enabling automatic TLS cert provisioning.

Regardless of if your want to manually obtain certificates, or configure Knative
for automatic provisioning, you can use the following steps to install
cert-manager.

Knative supports automatically provisioning TLS certificates through
[cert-manager](https://cert-manager.io/docs/). The following commands
install the components needed to support the provisioning of TLS certificates
through cert-manager.

1. Install cert-manager version v1.0.0 or later.

1. Install the component that integrates Knative with `cert-manager` by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="net-certmanager",file="release.yaml")}}
    ```

1. Configure Knative to automatically configure TLS certificates by following the steps in Enabling automatic TLS certificate provisioning.

#### Before you begin

- Install Knative Serving.
- You must configure your Knative cluster to use a custom domain.
- Knative currently supports cert-manager version `1.0.0` and higher.

#### Downloading and installing cert-manager

To download and install cert-manager, follow the [Installation steps](https://cert-manager.io/docs/installation/kubernetes/) from the official `cert-manager` website.

#### Completing the Knative configuration for TLS support

Before you can use a TLS certificate for secure connections, you must finish
configuring Knative:

- **Manual**: If you installed cert-manager to manually obtain certificates,
  continue to the following topic for instructions about creating a Kubernetes
  secret: Manually adding a TLS certificate

- **Automatic**: If you installed cert-manager to use for automatic certificate
  provisioning, continue to the following topic to enable that feature: Enabling automatic TLS certificate provisioning in Knative
