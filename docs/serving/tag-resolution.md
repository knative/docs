# Tag resolution

Knative Serving resolves image tags to a digest when you create a Revision. This
helps to provide consistency for Deployments. For more information, see the documentation on [Why we resolve tags in Knative](https://docs.google.com/presentation/d/e/2PACX-1vTgyp2lGDsLr_bohx3Ym_2mrTcMoFfzzd6jocUXdmWQFdXydltnraDMoLxvEe6WY9pNPpUUvM-geJ-g/pub).

!!! important
    The Knative Serving controller must be configured to access the container registry to use this feature.

## Custom certificates

If you are using a registry that has a self-signed certificate, you must configure the default Knative Serving `controller` Deployment to trust that certificate. You can configure trusting certificates by mounting your certificates into the `controller` Deployment, and then setting the environment variable appropriately.

### Procedure

1. If you are using a `custom-certs` secret that contains your CA certificates, add the following spec to the default Knative Serving `controller` Deployment:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: controller
      namespace: knative-serving
    spec:
      template:
        spec:
          containers:
            - name: controller
              volumeMounts:
                - name: custom-certs
                  mountPath: /path/to/custom/certs
              env:
                - name: SSL_CERT_DIR
                  value: /path/to/custom/certs
          volumes:
            - name: custom-certs
              secret:
                secretName: custom-certs
    ```

    Knative Serving accepts the [`SSL_CERT_FILE` and `SSL_CERT_DIR`](https://pkg.go.dev/crypto/x509#SystemCertPool) environment variables.

1. Create a secret in the `knative-serving` namespace that points to your root CA certificate, and then save the current Knative Serving `controller` Deployment:

    ```bash
    kubectl -n knative-serving create secret generic customca --from-file=ca.crt=/root/ca.crt
    ```

    ```bash
    kubectl -n knative-serving get deploy/controller -o yaml > knative-serving-controller.yaml
    ```

## Corporate proxy

If you are behind a corporate proxy, you must proxy the tag resolution requests between the controller and your registry.

Knative accepts the [`HTTP_PROXY` and `HTTPS_PROXY`](https://golang.org/pkg/net/http/#ProxyFromEnvironment) environment variables, so you can configure the controller Deployment as follows:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: controller
  namespace: knative-serving
spec:
  template:
    spec:
      containers:
        - name: controller
          env:
            - name: HTTP_PROXY
              value: http://proxy.example.com
            - name: HTTPS_PROXY
              value: https://proxy.example.com
```
