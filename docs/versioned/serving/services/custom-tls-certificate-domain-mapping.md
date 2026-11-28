---
audience: developer
components:
  - serving
function: how-to
---

# Using a custom TLS certificate for DomainMapping

{{ feature(beta="0.24") }}

Provide a certificate Secret to an existing DomainMapping to serve its mapped
hostname over HTTPS. Supplying this certificate bypasses automatic certificate
creation for that mapping through [external-domain TLS](../encryption/external-domain-tls.md).

## Prerequisites

- You have a working [DomainMapping](custom-domains.md). Keep its domain name and
  **mapping namespace** for every command below.
- You can create a TLS Secret in that namespace and update the mapping. The Secret
  must be in the **DomainMapping's namespace**, even if its target is elsewhere.
- You have a matching certificate and private key. The certificate must cover the
  mapped hostname; callers must trust its issuing Certificate Authority.
- Your networking gateway has an HTTPS endpoint reachable by your callers.
  The default kind Quickstart's local HTTP test does not by itself expose an HTTPS
  endpoint. Prepare HTTPS access through your [networking layer](../../install/yaml-install/serving/install-serving-with-yaml.md#install-a-networking-layer)
  before using this optional TLS procedure.

## Procedure

Replace the placeholders with the same domain and namespace used by your existing
mapping. Replace certificate/key paths with your actual files. Do not commit or
share the private key.

1. Create the [TLS Secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets)
   in the mapping's namespace:

    ```bash
    kubectl create secret tls <tls-secret-name> \
      --namespace <namespace> \
      --cert=path/to/certificate --key=path/to/private-key
    ```

1. Set the mapping's certificate reference. This patch changes only the TLS
   setting and retains the existing target reference and other configuration:

    ```bash
    kubectl patch domainmapping <domain-name> \
      --namespace <namespace> --type merge \
      --patch '{"spec":{"tls":{"secretName":"<tls-secret-name>"}}}'
    ```

    If you maintain the mapping as a YAML manifest, use that method **instead**:
    add this `tls` block alongside the existing `spec.ref` without replacing it:

    ```yaml
    spec:
      # Keep the existing ref and other settings here.
      tls:
        secretName: <tls-secret-name>
    ```

    Apply the edited manifest explicitly:

    ```bash
    kubectl apply -f <mapping-file>.yaml --namespace <namespace>
    ```

1. Verify the update in the same namespace:

    ```bash
    kubectl wait domainmapping/<domain-name> \
      --namespace <namespace> --for=condition=Ready --timeout=120s
    kubectl get domainmapping <domain-name> --namespace <namespace>
    ```

    `READY` should be `True`, and `URL` should use `https://`. If not, inspect
    `kubectl describe domainmapping <domain-name> --namespace <namespace>` for
    certificate, claim, or ingress errors. Do not share Secret contents when
    asking for help.

1. From a client that can resolve the mapped hostname and reach its HTTPS gateway,
   request your application:

    ```bash
    curl https://<domain-name>
    ```

    Confirm the application's expected response. Readiness alone does not prove
    external reachability or that your client trusts the certificate.

    For a private test CA or self-signed test certificate, explicitly supply the
    trusted CA certificate rather than disabling certificate checks:

    ```bash
    curl --cacert path/to/trusted-ca-certificate https://<domain-name>
    ```

TLS protects the connection; it does not add application authorization. The
certificate Secret and DomainMapping remain in the cluster until you remove them
or delete the disposable cluster that contains them.
