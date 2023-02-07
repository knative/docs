# Enabling auto-TLS certs

If you install and configure cert-manager, you can configure Knative to
automatically obtain new TLS certificates and renew existing ones for Knative
Services. To learn more about using secure connections in Knative, see
[Configuring HTTPS with TLS certificates](using-a-tls-cert.md).

## Before you begin

The following must be installed on your Knative cluster:

- [Knative Serving](../install/yaml-install/serving/install-serving-with-yaml.md).

- A Networking layer such as Kourier, Istio with SDS v1.3 or higher, or Contour v1.1 or higher. See [Install a networking layer](../install/yaml-install/serving/install-serving-with-yaml.md#install-a-networking-layer) or [Istio with SDS, version 1.3 or higher](../install/installing-istio.md#installing-istio-with-SDS-to-secure-the-ingress-gateway).

- [`cert-manager` version `1.0.0` or higher](../install/installing-cert-manager.md).

- Your Knative cluster must be configured to use a [custom domain](using-a-custom-domain.md).

- Your DNS provider must be setup and configured to your domain.

- If you want to use HTTP-01 challenge, you need to configure your custom
domain to map to the IP of ingress. You can achieve this by adding a DNS A record to map the domain to the IP according to the instructions of your DNS provider.

## Automatic TLS provision mode

Knative supports the following Auto TLS modes:

1.  Using DNS-01 challenge

    In this mode, your cluster needs to be able to talk to your DNS server to verify the ownership of your domain.

    - **Provision Certificate per namespace is supported when using DNS-01 challenge mode.**
        - This is the recommended mode for faster certificate provision.
        - In this mode, a single Certificate will be provisioned per namespace and is reused across the Knative Services within the same namespace.

    - **Provision Certificate per Knative Service is supported when using DNS-01 challenge mode.**
        - This is the recommended mode for better certificate isolation between Knative Services.
        - In this mode, a Certificate will be provisioned for each Knative Service.
        - The TLS effective time is longer as it needs Certificate provision for each Knative Service creation.

1.  Using HTTP-01 challenge

    - In this type, your cluster does not need to be able to talk to your DNS server. You must map your domain to the IP of the cluster ingress.
    - When using HTTP-01 challenge, **a certificate will be provisioned per Knative Service.**
    - **HTTP-01 does not support provisioning a certificate per namespace.**

## Enabling Auto TLS

1.  Create and add the `ClusterIssuer` configuration file to your Knative cluster
to define who issues the TLS certificates, how requests are validated,
and which DNS provider validates those requests.

    - **ClusterIssuer for DNS-01 challenge:** use the cert-manager reference to determine how to configure your `ClusterIssuer` file.

        - See the generic [`ClusterIssuer` example](https://cert-manager.io/docs/configuration/acme/#creating-a-basic-acme-issuer)
        - Also see the
        [`DNS01` example](https://docs.cert-manager.io/en/latest/tasks/acme/configuring-dns01/index.html)

        For example, the following `ClusterIssuer` file named `letsencrypt-issuer` is
        configured for the Let's Encrypt CA and Google Cloud DNS.
        The Let's Encrypt account info, required `DNS-01` challenge type, and
        Cloud DNS provider info is defined under `spec`.

        ```yaml
        apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: letsencrypt-dns-issuer
        spec:
          acme:
            server: https://acme-v02.api.letsencrypt.org/directory
            # This will register an issuer with LetsEncrypt.  Replace
            # with your admin email address.
            email: test-email@knative.dev
            privateKeySecretRef:
              # Set privateKeySecretRef to any unused secret name.
              name: letsencrypt-dns-issuer
            solvers:
            - dns01:
                cloudDNS:
                  # Set this to your GCP project-id
                  project: $PROJECT_ID
                  # Set this to the secret that we publish our service account key
                  # in the previous step.
                  serviceAccountSecretRef:
                    name: cloud-dns-key
                    key: key.json
        ```

    - **ClusterIssuer for HTTP-01 challenge**

        To apply the ClusterIssuer for HTTP01 challenge:

        1. Create a YAML file using the following template:

            ```yaml
            apiVersion: cert-manager.io/v1
            kind: ClusterIssuer
            metadata:
              name: letsencrypt-http01-issuer
            spec:
              acme:
                privateKeySecretRef:
                  name: letsencrypt
                server: https://acme-v02.api.letsencrypt.org/directory
                solvers:
                - http01:
                   ingress:
                     class: istio
            ```

        1. Apply the YAML file by running the command:

            ```bash
            kubectl apply -f <filename>.yaml
            ```
            Where `<filename>` is the name of the file you created in the previous step.

1.  Ensure that the ClusterIssuer is created successfully:

    ```bash
    kubectl get clusterissuer <cluster-issuer-name> -o yaml
    ```

    Result: The `Status.Conditions` should include `Ready=True`.

### DNS-01 challenge only: Configure your DNS provider

If you choose to use DNS-01 challenge, configure which DNS provider is used to
validate the DNS-01 challenge requests.

Instructions about configuring cert-manager, for all the supported DNS
providers, are provided in
[DNS01 challenge providers and configuration instructions](https://cert-manager.io/docs/configuration/acme/dns01/#supported-dns01-providers).

Note that DNS-01 challenges can be used to either validate an
individual domain name or to validate an entire namespace using a
wildcard certificate like `*.my-ns.example.com`.

### Install net-certmanager-controller deployment

1.  Determine if `net-certmanager-controller` is already installed by running the
    following command:

    ```bash
    kubectl get deployment net-certmanager-controller -n knative-serving
    ```

1.  If `net-certmanager-controller` is not found, run the following command:

    ```bash
    kubectl apply -f {{ artifact( repo="net-certmanager", file="release.yaml") }}
    ```

### Provisioning certificates per namespace (wildcard certificates)

!!! warning
    Provisioning a certificate per namespace only works with DNS-01
    challenge. This component cannot be used with HTTP-01 challenge.

The per-namespace certificate manager uses namespace labels to select which
namespaces should have a certificate applied. For more details on namespace
selectors, see
[the Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors).

Prior to release 1.0, the fixed label
`networking.knative.dev/disableWildcardCert: true` was used to disable
certificate generation for a namespace. In 1.0 and later, other labels such as
`kubernetes.io/metadata.name` may be used to select or restrict namespaces.

To enable certificates for all namespaces except those with the
`networking.knative.dev/disableWildcardCert: true` label, use the following
command:

```bash
kubectl patch --namespace knative-serving configmap config-network -p '{"data": {"namespace-wildcard-cert-selector": "{\"matchExpressions\": [{\"key\":\"networking.knative.dev/disableWildcardCert\", \"operator\": \"NotIn\", \"values\":[\"true\"]}]}"}}'
```

This selects all namespaces where the label value is not in the set `"true"`.

### Configure config-certmanager ConfigMap

Update your [`config-certmanager` ConfigMap](https://github.com/knative-sandbox/net-certmanager/blob/main/config/config.yaml)
in the `knative-serving` namespace to reference your new `ClusterIssuer`.

1.  Run the following command to edit your `config-certmanager` ConfigMap:

    ```bash
    kubectl edit configmap config-certmanager -n knative-serving
    ```

1.  Add the `issuerRef` within the `data` section:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-certmanager
      namespace: knative-serving
      labels:
        networking.knative.dev/certificate-provider: cert-manager
    data:
      issuerRef: |
        kind: ClusterIssuer
        name: letsencrypt-http01-issuer
    ```

    `issueRef` defines which `ClusterIssuer` is used by Knative to issue
    certificates.

1.  Ensure that the file was updated successfully:

    ```bash
    kubectl get configmap config-certmanager -n knative-serving -o yaml
    ```

### Turn on Auto TLS

Update the [`config-network` ConfigMap](https://github.com/knative/serving/blob/main/config/core/configmaps/network.yaml) in the `knative-serving` namespace to enable `auto-tls` and specify how HTTP requests are handled:

1.  Run the following command to edit your `config-network` ConfigMap:

    ```bash
    kubectl edit configmap config-network -n knative-serving
    ```

1.  Add the `auto-tls: Enabled` attribute under the `data` section:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-network
      namespace: knative-serving
    data:
       ...
       auto-tls: Enabled
       ...
    ```

1.  Configure how HTTP and HTTPS requests are handled in the [`http-protocol`](https://github.com/knative/serving/blob/main/config/core/configmaps/network.yaml#L109) attribute.

    By default, Knative ingress is configured to serve HTTP traffic
    (`http-protocol: Enabled`). Now that your cluster is configured to use TLS
    certificates and handle HTTPS traffic, you can specify whether or not any
    HTTP traffic is allowed.

    Supported `http-protocol` values:

    - `Enabled`: Serve HTTP traffic.
    - `Redirected`: Responds to HTTP request with a `302` redirect to ask the
      clients to use HTTPS.

    ```yaml
    data:
      http-protocol: Redirected
    ```

    Example:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-network
      namespace: knative-serving
    data:
      ...
      auto-tls: Enabled
      http-protocol: Redirected
      ...
    ```

1.  Ensure that the file was updated successfully:

    ```bash
    kubectl get configmap config-network -n knative-serving -o yaml
    ```

Congratulations! Knative is now configured to obtain and renew TLS certificates.
When your TLS certificate is active on your cluster, your Knative services will
be able to handle HTTPS traffic.

### Verify Auto TLS

1.  Run the following command to create a Knative Service:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/knative/docs/main/docs/serving/autoscaling/autoscale-go/service.yaml
    ```

1.  When the certificate is provisioned (which could take up to several minutes depending on the challenge type), you should see something like:

    ```bash
    NAME               URL                                           LATESTCREATED            LATESTREADY              READY   REASON
    autoscale-go       https://autoscale-go.default.{custom-domain}   autoscale-go-6jf85 autoscale-go-6jf85       True  
    ```

    Note that the URL will be **https** in this case.

### Disable Auto TLS per service or route

If you have Auto TLS enabled in your cluster, you can choose to disable Auto TLS for individual services or routes by adding the annotation `networking.knative.dev/disable-auto-tls: true`.

Using the previous `autoscale-go` example:

1. Edit the service using `kubectl edit service.serving.knative.dev/autoscale-go -n default` and add the annotation:

    ```yaml
     apiVersion: serving.knative.dev/v1
     kind: Service
     metadata:
       annotations:
        ...
         networking.knative.dev/disable-auto-tls: "true"
        ...
    ```

1. The service URL should now be **http**, indicating that AutoTLS is disabled:

    ```bash
    NAME           URL                                          LATEST               AGE     CONDITIONS   READY   REASON
    autoscale-go   http://autoscale-go.default.1.arenault.dev   autoscale-go-dd42t   8m17s   3 OK / 3     True
    ```
