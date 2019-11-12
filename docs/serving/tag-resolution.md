---
title: "Enabling tag to digest resolution"
linkTitle: "Tag resolution"
weight: 75
type: "docs"
---

Knative serving resolves image tags to a digest when you create a revision. This
gives knative revisions some very nice properties, e.g. your deployments will be
consistent, you don't have to worry about "immutable tags", etc. For more info,
see
[Why we resolve tags in Knative](https://docs.google.com/presentation/d/1gjcVniYD95H1DmGM_n7dYJ69vD9d6KgJiA-D9dydWGU/edit?usp=sharing)
(join
[`knative-users@googlegroups.com`](https://groups.google.com/d/forum/knative-users)
for access).

Unfortunately, this means that the knative serving controller needs to be
configured to access your container registry.

## Custom Certificates

If you're using a registry that has a self-signed certificate, you'll need to
convince the serving controller to trust that certificate. We respect the
[`SSL_CERT_FILE` and `SSL_CERT_DIR`](https://golang.org/pkg/crypto/x509/#pkg-overview)
environment variables, so you can trust them by mounting the certificates into
the controller's deployment and setting the environment variable appropriatel,
assuming you have a `custom-certs` secret containing your CA certs:

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

## Corporate Proxy

If you're behind a corporate proxy, you'll need to proxy the tag resolution
requests between the controller and your registry. We respect the
[`HTTP_PROXY` and `HTTPS_PROXY`](https://golang.org/pkg/net/http/#ProxyFromEnvironment)
environment variables, so you can configure the controller's deployment via:

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

## Skipping tag resolution

If this all seems like too much trouble, you can configure serving to skip tag
resolution via the `registriesSkippingTagResolving` configmap field:

```
kubectl -n knative-serving edit configmap config-deployment
```

E.g., to disable tag resolution for `registry.example.com`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-deployment
  namespace: knative-serving

data:
  # List of repositories for which tag to digest resolving should be skipped
  registriesSkippingTagResolving: registry.example.com
```
