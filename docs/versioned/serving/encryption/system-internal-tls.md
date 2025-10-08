---
audience: administrator
components:
  - serving
function: how-to
---

# Configure Knative system-internal encryption

{% include "encryption-notice.md" %}

## Before you begin

You must meet the following requirements to enable secure HTTPS connections:

- Knative Serving must be installed. For details about installing the Serving
  component, see the [Knative installation guides](../../install/yaml-install/serving/install-serving-with-yaml.md).

!!! warning
    This feature is currently only supported with Kourier as a networking layer.

### Installing and configuring cert-manager and integration

First, you need to install and configure `cert-manager` and the Knative cert-manager integration.
Please refer to [Configuring Knative cert-manager integration](./configure-certmanager-integration.md) for details.


## Enabling system-internal-tls

To enable `system-internal-tls` update the [`config-network` ConfigMap](https://github.com/knative/serving/blob/main/config/core/configmaps/network.yaml) in the `knative-serving` namespace:

1.  Run the following command to edit your `config-network` ConfigMap:

    ```bash
    kubectl edit configmap config-network -n knative-serving
    ```

1.  Add the `system-internal-tls: Enabled` attribute under the `data` section:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-network
      namespace: knative-serving
    data:
       ...
       system-internal-tls: Enabled
       ...
    ```

1.  Restart the Knative activator and controller component to start the Knative cert-manager integration:
 
    ```bash
    kubectl rollout restart deploy/activator -n knative-serving
    kubectl rollout restart deploy/controller -n knative-serving
    ```

Congratulations! Knative will now use TLS between its internal system components (Ingress-Controller, Activator and Queue-Proxy).


## Verification

1. Deploy a Knative Service

1. Check if certificates are created and ready with `kubectl get kcert -n <your-knative-service-namespace>`

1. Check if the Queue-Proxy container reads the certificate on startup with 

    ```bash
    kubectl logs your-pod -n your-knative-service-namespace -c queue-proxy | grep -E 'certDir|Certificate|tls'
    ```

    It should look like this:

    ```
    {"severity":"INFO","timestamp":"2024-01-03T07:07:32.892810888Z","logger":"queueproxy","caller":"certificate/watcher.go:62","message":"Starting to watch the following directories for changes{certDir 15 0 /var/lib/knative/certs <nil>} {keyDir 15 0 /var/lib/knative/certs <nil>}","commit":"86420f2-dirty","knative.dev/key":"first/helloworld-00001","knative.dev/pod":"helloworld-00001-deployment-75fbb7d488-qgmxx"}
    {"severity":"INFO","timestamp":"2024-01-03T07:07:32.89397512Z","logger":"queueproxy","caller":"certificate/watcher.go:131","message":"Certificate and/or key have changed on disk and were reloaded.","commit":"86420f2-dirty","knative.dev/key":"first/helloworld-00001","knative.dev/pod":"helloworld-00001-deployment-75fbb7d488-qgmxx"}
    {"severity":"INFO","timestamp":"2024-01-03T07:07:32.894232939Z","logger":"queueproxy","caller":"sharedmain/main.go:282","message":"Starting tls server admin:8022","commit":"86420f2-dirty","knative.dev/key":"first/helloworld-00001","knative.dev/pod":"helloworld-00001-deployment-75fbb7d488-qgmxx"}
    {"severity":"INFO","timestamp":"2024-01-03T07:07:32.894268548Z","logger":"queueproxy","caller":"sharedmain/main.go:282","message":"Starting tls server main:8112","commit":"86420f2-dirty","knative.dev/key":"first/helloworld-00001","knative.dev/pod":"helloworld-00001-deployment-75fbb7d488-qgmxx"}
    ```

## Trust

!!! warning
    A quick note on trust, Knative will automatically trust the CA that signed the Certificates, if the cert-manager issuer allows 
    putting the CA directly in the field `ca.crt` of the certificates `Secret`. Regardless of that, Cluster admins **should always**
    provide a trust-bundle, as described in  [Configuring Knative cert-manager integration](./configure-certmanager-integration.md#managing-trust-and-rotation-without-downtime).
    This is also strongly recommended in the [cert-manager documentation](https://cert-manager.io/docs/trust/trust-manager/#cert-manager-integration-intentionally-copying-ca-certificates)
    to avoid issues with rotation.
   
