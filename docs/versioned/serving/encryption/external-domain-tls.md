---
audience: administrator
components:
  - serving
function: how-to
---

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
- Permission to read component configuration and update its authoritative source, plus the certificate, Secret, or ingress resources needed by your chosen route. Retain previous configuration values for recovery.

### Choose the configuration authority

Identify whether the installation is managed by the Knative Operator or directly through YAML before changing configuration. If GitOps manages either source, update and synchronize it rather than competing with live edits. Examples below target a same-cluster installation in `knative-serving`; substitute the actual namespace and use the [multi-cluster Operator guide](../../install/operator/multi-cluster-deployment.md) for remote targets.

For **Operator-managed Serving**, inspect `spec.config` in the current `KnativeServing` resource and its authoritative manifest before changing `config-network`/`network` or, for the manual Contour route, `config-contour`/`contour`. Change the existing winning entry. Do not add a shortened entry that is shadowed by a full-name entry, even when the full-name entry is empty, or delete the full-name entry to bypass it. If neither form exists, choose one according to the [ConfigMap mapping reference](../../install/operator/configuration-reference.md#configmap-mapping).

After choosing the entry through the mapping reference, use the [generic Serving Operator apply/verify workflow](../../install/operator/configuring-serving-cr.md#apply-and-verify-a-configuration-change) for authoritative application, custom-resource status, and recovery. Inspect the affected TLS ConfigMap (`config-network` or `config-contour`) and complete the HTTPS checks below. Do not substitute TLS settings into the separate domain example or follow its `config-domain` guards. When configuring the custom domain itself, use that domain task separately.

For **YAML-managed Serving**, merge the intended keys into the authoritative ConfigMap manifest and apply it through your existing workflow. Direct `kubectl edit`/`patch` commands below are only for installations not managed by the Operator or GitOps. Preserve unrelated configuration and verify HTTPS after the change; matching ConfigMap values alone are not sufficient.

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

These are not globally exclusive modes. With external-domain TLS enabled, the v1.24 [Route reconciler](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/reconciler/route/route.go#L203-L265) looks for a matching wildcard certificate first and provisions an individual certificate when none matches. Different Routes can therefore use different certificate strategies.

#### Using a certificate for each Knative Service

Set `external-domain-tls: Enabled` in the configuration corresponding to [`config-network`](https://github.com/knative/serving/blob/knative-v1.24.0/vendor/knative.dev/networking/config/config-network.yaml), using the authority selected above:

=== "Operator-managed Serving"

    Merge `external-domain-tls: "Enabled"` into the winning network entry under `spec.config`, preserving other values. Only when the preflight confirms that `config-network` is absent may you use this shortened-key fragment:

    ```yaml
    spec:
      config:
        network:
          external-domain-tls: "Enabled"
    ```

    Apply it through the [generic Serving Operator apply/verify workflow](../../install/operator/configuring-serving-cr.md#apply-and-verify-a-configuration-change), inspecting `config-network` as the affected resource. If a full-name entry exists, change that entry instead; do not add this fragment alongside it. Do not edit the generated `config-network` ConfigMap.

=== "YAML-managed Serving"

    Merge `external-domain-tls: Enabled` into your authoritative ConfigMap's `data`. For a directly managed installation with no GitOps controller, you can edit it:

    ```bash
    kubectl edit configmap config-network -n knative-serving
    ```

    Example fragment:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-network
      namespace: knative-serving
    data:
      # Preserve other active configuration keys.
      external-domain-tls: Enabled
    ```

After applying the configuration, restart the Knative Serving controller to start the Knative cert-manager integration:
   
```bash
kubectl rollout restart deploy/controller -n knative-serving
```

#### Using one wildcard certificate per namespace

!!! warning
    Provisioning a wildcard Certificate per namespace only works with DNS-01
    challenge. This feature cannot be used with HTTP-01 challenge.

The automatic TLS and cert-manager prerequisites above also apply to this route. Enable `external-domain-tls` through the selected configuration authority before configuring the wildcard selector.

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

Apply your chosen `namespace-wildcard-cert-selector` through the selected configuration authority:

=== "Operator-managed Serving"

    Merge the selector value into the winning network entry under `spec.config`. Follow the preflight and application workflow above; do not add a shadow entry or patch the generated ConfigMap. For example, only when `config-network` is absent, the shortened-key fragment is:

    ```yaml
    spec:
      config:
        network:
          namespace-wildcard-cert-selector: |-
            matchExpressions:
            - key: "networking.knative.dev/disableWildcardCert"
              operator: "NotIn"
              values: ["true"]
    ```

=== "YAML-managed Serving"

    Merge the selector into your authoritative `config-network` manifest. For a directly managed installation with no GitOps controller, you can use this patch, adapting the selector as needed:

    ```bash
    kubectl patch --namespace knative-serving configmap config-network -p '{"data": {"namespace-wildcard-cert-selector": "{\"matchExpressions\": [{\"key\":\"networking.knative.dev/disableWildcardCert\", \"operator\": \"NotIn\", \"values\":[\"true\"]}]}"}}'
    ```

For more details on namespace selectors, see [the Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors).

Restart the Knative Serving controller to start the Knative cert-manager integration:

```bash
kubectl rollout restart deploy/controller -n knative-serving
```

Check that the generated `config-network` contains the intended active values after reconciliation. For an Operator-managed installation, also check custom-resource status using the linked generic apply/verify workflow. Then complete [HTTPS verification](#verification); certificate provisioning and application reachability are not established merely by applying configuration.


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

Choose certificate names that cover the actual Service hostname. With the default `{service}.{namespace}.{domain}` hostname shape, a single-level wildcard for `*.yourdomain.com` does not cover `service.namespace.yourdomain.com`; a namespace-specific wildcard or exact hostname may be needed. Check the [v1.24 domain template](https://github.com/knative/serving/blob/knative-v1.24.0/vendor/knative.dev/networking/config/config-network.yaml) and perform the hostname/trust check in [Verification](#verification).

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

    1. Configure `default-tls-secret: "contour-external/default-cert"` for the Knative Contour plugin as a fallback when `external-domain-tls` is disabled. The [v1.24 Contour configuration parser](https://github.com/knative-extensions/net-contour/blob/knative-v1.24.0/pkg/reconciler/contour/config/contour.go) accepts this key as a namespace/name Secret reference:

        - **Operator-managed:** merge the value into the winning `config-contour`/`contour` entry under `spec.config`, after the precedence check above. Apply and verify through the [generic Serving Operator workflow](../../install/operator/configuring-serving-cr.md#apply-and-verify-a-configuration-change), inspecting `config-contour` as the affected resource; do not patch the generated ConfigMap.
        - **YAML-managed:** update your authoritative `config-contour` manifest. Only for a directly managed installation with no GitOps controller, use:

            ```bash
            kubectl patch configmap config-contour -n knative-serving \
              -p '{"data":{"default-tls-secret":"contour-external/default-cert"}}'
            ```



=== "Istio"

    To add a TLS certificate to your Knative cluster, you create a
    Kubernetes secret and then configure the `knative-ingress-gateway`.

    These gateway-edit steps assume the gateway is not Operator-managed. If the Operator owns it, use its [Serving networking configuration](../../install/operator/configuring-serving-cr.md#networking-entry-points) through the authoritative custom resource instead of directly editing that managed resource.

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

Use an existing external Knative Service, or [deploy a test container](../services/creating-services.md), with a known GET response. You need read/watch permission for the Service and network access to its external hostname. Replace the values below with the intended context, application namespace, Service, and endpoint:

```bash
CONTEXT=my-cluster-context
NAMESPACE=default
SERVICE=your-service
REQUEST_PATH=/
```

1. Wait for the Service to be Ready and read its URL:

    ```bash
    kubectl --context "$CONTEXT" wait service.serving.knative.dev/"$SERVICE" \
      -n "$NAMESPACE" --for=condition=Ready --timeout=120s
    URL=$(kubectl --context "$CONTEXT" get service.serving.knative.dev "$SERVICE" \
      -n "$NAMESPACE" -o jsonpath='{.status.url}')
    printf '%s\n' "$URL"
    ```

    For automatic external-domain TLS provisioning, an eligible Service should report an HTTPS URL once its certificate is ready. If readiness fails or the URL is empty, inspect the Service's conditions before proceeding. Check the selected certificate-provisioning route and any Service-level opt-out if automatic provisioning does not occur.

2. Request HTTPS for that hostname, regardless of the displayed URL scheme:

    ```bash
    HTTPS_URL="https://${URL#*://}"
    curl --fail --show-error --max-time 60 "${HTTPS_URL}${REQUEST_PATH}"
    ```

    Expected result: TLS validation succeeds and the application returns the known response. The certificate must be trusted by the client and cover the requested hostname. For a private CA, configure the client's trust or use `curl --cacert /path/to/ca.pem`; do not use `--insecure` as verification. A Ready Service or matching configuration alone does not verify certificate trust, DNS, ingress reachability, or application behavior.

    For failed automatic issuance, inspect the certificate resources and events from your cert-manager integration; for connection or TLS errors, inspect DNS, ingress configuration, certificate hostname coverage, and client trust.

Restore previous settings through the same authoritative workflow if recovery is required. For Operator-managed configuration, do not restore values by editing generated ConfigMaps. Repeat the configuration and HTTPS checks after recovery.

## Trust

!!! note
    A quick note on trust, all clients that call the external domain of a Knative Service need to trust the Certificate Authority
    that signed the certificates. This is out of scope of Knative, but needs to be addressed to ensure a working system. Especially,
    when a Certificate Authority performs a rotation of the CA or the intermediate certificates. Find more information on
    [Configuring Knative cert-manager integration](./configure-certmanager-integration.md#managing-trust-and-rotation-without-downtime).


## Additional configuration

### Configuring HTTP redirects

Knative Serving allows to automatically redirect HTTP traffic, when HTTPS is enabled on external domains. 
Use the configuration authority selected above: Operator users update `http-protocol` in the winning network entry under `spec.config`; YAML-managed users update the authoritative `config-network` data. Preserve unrelated keys and follow the linked generic apply/verify workflow where applicable, inspecting `config-network` rather than the domain example's ConfigMap.

1. Configure how HTTP and HTTPS requests are handled with the `http-protocol` attribute.

    By default, Knative ingress is configured to serve HTTP traffic
    (`http-protocol: Enabled`). Now that your cluster is configured to use TLS
    certificates and handle HTTPS traffic on external domains, you can specify whether any
    HTTP traffic is allowed or not.

    Supported `http-protocol` values:

    - `Enabled`: Serve HTTP traffic.
    - `Redirected`: Requests an HTTP-to-HTTPS redirect, documented as `301` in the [v1.24 network configuration](https://github.com/knative/serving/blob/knative-v1.24.0/vendor/knative.dev/networking/config/config-network.yaml). The selected ingress implementation performs the redirect; verify its actual status and `Location` below.

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
      # Preserve other active configuration keys.
      external-domain-tls: Enabled
      http-protocol: Redirected
    ```

    This illustrates ConfigMap data, not a resource to apply over an Operator-managed ConfigMap. After propagation, request the HTTP endpoint without following redirects:

    ```bash
    curl --silent --show-error --output /dev/null --dump-header - \
      --max-time 60 "http://${URL#*://}${REQUEST_PATH}"
    ```

    Confirm a redirect response whose `Location` points to the intended HTTPS endpoint, then repeat the HTTPS request above. Configuration values or a successful HTTPS request alone do not demonstrate that HTTP redirects are active.

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
         # Preserve unrelated Service annotations.
         networking.knative.dev/disable-external-domain-tls: "true"
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
