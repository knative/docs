# Configure cluster-local domain encryption

## Before you begin

You must meet the following requirements to enable secure HTTPS connections:

- Knative Serving must be installed. For details about installing the Serving
  component, see the [Knative installation guides](../../install/yaml-install/serving/install-serving-with-yaml.md).

!!! warning
    This feature is currently only supported with Kourier and Istio as a networking layer.

## Enabling cluster-local-domain-tls

First, you need to install and configure `cert-manager` and `net-certmanager`. Please refer to [Installing and configuring net-certmanager](./install-and-configure-net-certmanager.md) for details.

Then, update the [`config-network` ConfigMap](https://github.com/knative/serving/blob/main/config/core/configmaps/network.yaml) in the `knative-serving` namespace to enable `cluster-local-domain-tls`:

1.  Run the following command to edit your `config-network` ConfigMap:

    ```bash
    kubectl edit configmap config-network -n knative-serving
    ```

1.  Add the `cluster-local-domain-tls: Enabled` attribute under the `data` section:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-network
      namespace: knative-serving
    data:
       ...
       cluster-local-domain-tls: Enabled
       ...
    ```

Congratulations! Knative is now configured to obtain and renew TLS certificates for cluster-local domains.


## Verification

1. Deploy a Knative Service

1. Check the URL with `kubectl get ksvc -n <your-namespace> -o yaml`

1. The service URL cluster-local domain (https://helloworld.test.svc.cluster.local) should now be **https**:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld
  namespace: test
spec:
  # ...
status:
  address:
    # cluster-local-domain:
    url: https://helloworld.test.svc.cluster.local
  # ...
  # external domain:
  url: http://helloworld.first.example.com
```


## Trust

!!! note
    A quick note on trust, all clients that call the cluster-local domain of a Knative Service need to trust the Certificate Authority
    that signed the certificates. This is out of scope of Knative, but needs to be addressed to ensure a working system. Especially,
    when a Certificate Authority performs a rotation of the CA or the intermediate certificates. Find more information on
    [Install and configure net-certmanager](./install-and-configure-net-certmanager.md#managing-trust-and-rotation-without-downtime).

