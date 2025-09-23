# Configure external domain encryption

Knative allows to use either use custom TLS certificates or to use automatically generated TLS certificates 
to enable secure HTTPS connections for your Knative Services for the external domain (like `application.example.com`).

## Before you begin

You must meet the following requirements to enable secure HTTPS connections:

- Knative Serving must be installed. For details about installing the Serving
  component, see the [Knative installation guides](../../install/yaml-install/serving/install-serving-with-yaml.md).
- You must configure your Knative cluster to use a [custom external domain](../using-a-custom-domain.md).
- Your DNS provider must be setup and configured to your domain.
- A Networking layer such as Kourier, Istio with SDS v1.3 or higher, or Contour v1.1 or higher. See [Install a networking layer](../../install/yaml-install/serving/install-serving-with-yaml.md#install-a-networking-layer).


## Automatically obtain and renew certificates

### Installing and configuring cert-manager and integration

!!! info
    If you want to use HTTP-01 challenge, you need to configure your custom domain to map to the IP of ingress. 
    You can achieve this by adding a DNS A record to map the domain to the IP according to the instructions of your DNS provider.

First, you need to install and configure `cert-manager` and the Knative cert-manager integration.
Please refer to [Configuring Knative cert-manager integration](./configure-certmanager-integration.md) for details.


### Configuring Knative Serving

Automatic certificate provisioning allows to request certificates in two ways:

* One certificate for each individual Knative Service
* One wildcard certificate per namespace

Only one of them can be active at the same time!

#### Using a certificate for each Knative Service

Update the [`config-network` ConfigMap](https://github.com/knative/serving/blob/main/config/core/configmaps/network.yaml) in the `knative-serving` namespace to enable `external-domain-tls`:

1. Run the following command to edit your `config-network` ConfigMap:

    ```bash
    kubectl edit configmap config-network -n knative-serving
    ```

1. Add the `external-domain-tls: Enabled` attribute under the `data` section:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-network
      namespace: knative-serving
    data:
       ...
       external-domain-tls: Enabled
       ...
    ```

1. Restart the Knative Serving controller to start the Knative cert-manager integration:
   
    ```bash
    kubectl rollout restart deploy/controller -n knative-serving
    ```

#### Using one wildcard certificate per namespace

!!! warning
    Provisioning a wildcard Certificate per namespace only works with DNS-01
    challenge. This feature cannot be used with HTTP-01 challenge.

The per-namespace configuration uses namespace labels to select which namespaces should have a 
certificate applied. The selection is configured using the key `namespace-wildcard-cert-selector`
in the `config-network` ConfigMap. For example, you can use the following configurations:

- `namespace-wildcard-cert-selector`: `""` = Use an empty value to disable the feature (this is the default).
- `namespace-wildcard-cert-selector`: `{}` = Use an empty object to enable for all namespaces.

You can also configure the selector to opt-out when a specific label is on the namespace:

```yaml
namespace-wildcard-cert-selector: |-
  matchExpressions:
  - key: "networking.knative.dev/disableWildcardCert"
    operator: "NotIn"
    values: ["true"] 
```
This selects all namespaces where the label value is not in the set `"true"`.

Or use existing kubernetes labels to select namespaces based on their name:

```yaml
namespace-wildcard-cert-selector: |-
  matchExpressions:
    - key: "kubernetes.io/metadata.name"
      operator: "In"
      values: ["my-namespace", "my-other-namespace"] 
```

To apply the configuration you can use the following command (optionally adapting the label-selector):

```bash
kubectl patch --namespace knative-serving configmap config-network -p '{"data": {"namespace-wildcard-cert-selector": "{\"matchExpressions\": [{\"key\":\"networking.knative.dev/disableWildcardCert\", \"operator\": \"NotIn\", \"values\":[\"true\"]}]}"}}'
```

For more details on namespace selectors, see [the Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors).

Restart the Knative Serving controller to start the Knative cert-manager integration:

```bash
kubectl rollout restart deploy/controller -n knative-serving
```

Congratulations! Knative is now configured to obtain and renew TLS certificates.
When your TLS Certificate is issued and available on your cluster, your Knative services will
be able to handle HTTPS traffic on the external domain.


## Manually obtain and renew certificates

There are various ways on how to obtain certificates manually. You can either use tools like 
[Certbot][cb] or [cert-manager][cm] or provide the certificates manually from another source. 
In general, after you obtain a certificate, you must create a Kubernetes secret to use that
certificate in your cluster. See the procedures later in this topic for details
about manually obtaining and configuring certificates.

### Obtaining a certificate using a tool

Please refer to the according documentation of the tool:

- [Certbot docs][cb-docs]
- [cert-manager docs][cm-docs]

Knative expects a wildcard certificate signed for the DNS domain of your cluster external domain, like

> `*.yourdomain.com`

Once you have obtained the certificate and the private key, [create a Kubernetes Secret](#create-a-kubernetes-secret) 
for the certificate and key to be used by Knative.

!!! warning
    Certificates issued by Let's Encrypt are valid for only [90days][le-faqs]. Therefore, if you choose to manually obtain and configure your certificates, you must ensure that you renew each certificate before it expires.


### Create a Kubernetes Secret

Use the following steps in the relevant tab to add your certificate to your Knative cluster:

=== "Contour"

    To add a TLS certificate to your Knative cluster, you must create a
    Kubernetes secret and then configure the Knative Contour plugin.

    1. Create a Kubernetes secret to hold your TLS certificate, `cert.pem`, and the
       private key, `key.pem`, by running the command:

           ```bash
           kubectl create -n contour-external secret tls default-cert \
             --key key.pem \
             --cert cert.pem
           ```

        !!! note
            Take note of the namespace and secret name. You will need these in future steps.

    1. To use this certificate and private key in different namespaces, you must
    create a delegation. To do so, create a YAML file using the following template:

         ```yaml
         apiVersion: projectcontour.io/v1
         kind: TLSCertificateDelegation
         metadata:
           name: default-delegation
           namespace: contour-external
         spec:
           delegations:
             - secretName: default-cert
               targetNamespaces:
               - "*"
         ```
    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

    1. Update the Knative Contour plugin to use the certificate as a fallback
       when `external-domain-tls` is disabled by running the command:

         ```bash
         kubectl patch configmap config-contour -n knative-serving \
           -p '{"data":{"default-tls-secret":"contour-external/default-cert"}}'
         ```



=== "Istio"

    To add a TLS certificate to your Knative cluster, you create a
    Kubernetes secret and then configure the `knative-ingress-gateway`:

    1. Create a Kubernetes secret to hold your TLS certificate, `cert.pem`, and the
       private key, `key.pem`, by entering the following command:

       ```bash
       kubectl create --namespace istio-system secret tls tls-cert \
         --key key.pem \
         --cert cert.pem
       ```


    1. Configure Knative to use the new secret that you created for HTTPS
       connections:

       1. Run the following command to open the Knative shared `gateway` in edit
          mode:

          ```bash
          kubectl edit gateway knative-ingress-gateway --namespace knative-serving
          ```

       1. Update the `gateway` to include the following `tls:` section and
          configuration:

          ```yaml
          tls:
            mode: SIMPLE
            credentialName: tls-cert
          ```

          Example:

          ```yaml
          # Edit the following object. Lines beginning with a '#' will be ignored.
          # An empty file will abort the edit. If an error occurs while saving this
          # file will be reopened with the relevant failures.
          apiVersion: networking.istio.io/v1alpha3
          kind: Gateway
          metadata:
            # ... skipped ...
          spec:
            selector:
              istio: ingressgateway
            servers:
              - hosts:
                  - "*"
                port:
                  name: http
                  number: 80
                  protocol: HTTP
              - hosts:
                  - TLS_HOSTS
                port:
                  name: https
                  number: 443
                  protocol: HTTPS
                tls:
                  mode: SIMPLE
                  credentialName: tls-cert
          ```
          In this example, `TLS_HOSTS` represents the hosts of your TLS certificate. It can be a single host, multiple hosts, or a wildcard host.
          For detailed instructions, please refer [Istio documentation](https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/)


## Verification

1. Deploy a Knative Service

1. Check the URL with `kubectl get ksvc -n <your-namespace>`

1. The service URL should now be **https**:

    ```bash
    NAME           URL                                          LATEST               AGE     CONDITIONS   READY   REASON
    autoscale-go   https://autoscale-go.default.1.example.com   autoscale-go-dd42t   8m17s   3 OK / 3     True
    ```

## Trust

!!! note
    A quick note on trust, all clients that call the external domain of a Knative Service need to trust the Certificate Authority
    that signed the certificates. This is out of scope of Knative, but needs to be addressed to ensure a working system. Especially,
    when a Certificate Authority performs a rotation of the CA or the intermediate certificates. Find more information on
    [Configuring Knative cert-manager integration](./configure-certmanager-integration.md#managing-trust-and-rotation-without-downtime).


## Additional configuration

### Configuring HTTP redirects

Knative Serving allows to automatically redirect HTTP traffic, when HTTPS is enabled on external domains. 
To configure this 

1.  Configure how HTTP and HTTPS requests are handled with the `http-protocol` attribute.

    By default, Knative ingress is configured to serve HTTP traffic
    (`http-protocol: Enabled`). Now that your cluster is configured to use TLS
    certificates and handle HTTPS traffic on external domains, you can specify whether any
    HTTP traffic is allowed or not.

    Supported `http-protocol` values:

    - `Enabled`: Serve HTTP traffic.
    - `Redirected`: Responds to HTTP request with a `302` redirect to ask the clients to use HTTPS.

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
      external-domain-tls: Enabled
      http-protocol: Redirected
      ...
    ```

### Disable automatic TLS certificate provisioning per Service or Route

If you have automatic TLS certificate provisioning enabled in your cluster, you can choose to disable the feature
for individual Knative Services or Routes by adding the annotation `networking.knative.dev/disable-external-domain-tls: true`.

Using the `autoscale-go` example:

1. Edit the service using `kubectl edit service.serving.knative.dev/autoscale-go -n default` and add the annotation:

    ```yaml
     apiVersion: serving.knative.dev/v1
     kind: Service
     metadata:
       annotations:
        ...
         networking.knative.dev/disable-external-domain-tls: "true"
        ...
    ```

1. The service URL should now be **http**, indicating that automatic TLS Certificate provisioning is disabled:

    ```bash
    NAME           URL                                          LATEST               AGE     CONDITIONS   READY   REASON
    autoscale-go   http://autoscale-go.default.1.example.com    autoscale-go-dd42t   8m17s   3 OK / 3     True
    ```


[cm]: https://github.com/jetstack/cert-manager
[cm-docs]: https://cert-manager.io/docs/getting-started/
[le-faqs]: https://letsencrypt.org/docs/faq/
[cb]: https://certbot.eff.org
[cb-docs]: https://certbot.eff.org/docs/install.html#certbot-auto
