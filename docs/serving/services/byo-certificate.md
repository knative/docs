# Using a custom TLS certificate for DomainMapping

{{ feature(beta="0.24") }}

By providing the reference to an existing _TLS Certificate_ you can instruct a `DomainMapping` to use that
certificate to secure the mapped service. Using this feature skips [autoTLS](../using-auto-tls.md) certificate creation.

## Prerequisites

- You have followed the steps from [Configuring custom domains](custom-domains.md) and now have a working `DomainMapping`.
- You must have a TLS certificate from your Certificate Authority provider or self-signed.

## Procedure

1. Assuming you have obtained the `cert` and `key` files from your Certificate Authority provider or self-signed, create a plain Kubernetes [TLS Secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) by running the command:

    Use kubectl to create the secret:
    ```bash
    kubectl create secret tls <tls-secret-name> --cert=path/to/cert/file --key=path/to/key/file
    ```
    Where `<tls-secret-name>` is the name of the secret object being created.

1. Update your `DomainMapping` YAML file to use the newly created secret as follows:

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: DomainMapping
    metadata:
      name: <domain-name>
      namespace: <namespace>
    spec:
      ref:
        name: <service-name>
        kind: Service
        apiVersion: serving.knative.dev/v1
    # tls block specifies the secret to be used
      tls:
        secretName: <tls-secret-name>
    ```
    Where:

    - `<tls-secret-name>` is the name of the TLS secret created in the previous step.
    - `<domain-name>` is the domain name that you want to map a Service to.
    - `<namespace>` is the namespace that contains both the `DomainMapping` and `Service` objects.
    - `<service-name>` is the name of the Service that will be mapped to the domain.

1. Verify the `DomainMapping` status:

    1. Check the status by running the command:
    ```bash
    kubectl get domainmapping <domain-name>
    ```
    The `URL` column of the status should show the mapped domain with the scheme updated to `https`:
    ```
    NAME                      URL                               READY   REASON
    <domain-name>             https://<domain-name>             True
    ```
    1. If the Service is exposed publicly, verify that it is available by running:
    ```bash
    curl https://<domain-name>
    ```
    If the certificate is self-signed skip verification by adding the `-k` flag to the curl command.
