---
audience: administrator
components:
  - serving
function: how-to
---

# Installing Kourier for Knative

This guide walks you through manually installing and customizing Kourier for use with Knative.

## Before you begin

This installation is recommended for Knative installations without Istio installed.

You need:

- A Kubernetes cluster created.

## Supported Kourier versions

You can view the latest tested Kourier version on the [Kourier releases page](https://github.com/knative-extensions/net-kourier/releases).

## Installing Kourier

1. Install Knative Serving if not already installed:

``` bash
kubectl apply -f https://github.com/knative/serving/releases/latest/download/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/latest/download/serving-core.yaml
```

1. Install Kourier:

```bash
kubectl apply -f https://github.com/knative/net-kourier/releases/latest/download/kourier.yaml
```

1. Configure Knative Serving to use the proper `ingress.class`:

```bash
kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
```

1. Optional - Set your desired domain (replace 127.0.0.1.nip.io to your preferred domain):

```bash
kubectl patch configmap/config-domain \
  -n knative-serving \
  --type merge \
  -p '{"data":{"127.0.0.1.nip.io":""}}'
```

1. Optional - Deploy a sample hello world app:

```bash
cat <<-EOF | kubectl apply -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
spec:
  template:
    spec:
      containers:
      - image: gcr.io/knative-samples/helloworld-go
        env:
        - name: TARGET
          value: Go Sample v1
EOF
```

1. Optional - For testing purposes, you can use port-forwarding to make requests to Kourier from your machine:

```bash
kubectl port-forward --namespace kourier-system $(kubectl get pod -n kourier-system -l "app=3scale-kourier-gateway" --output=jsonpath="{.items[0].metadata.name}") 8080:8080 19000:9000 8443:8443

curl -v -H "Host: helloworld-go.default.127.0.0.1.nip.io" http://localhost:8080
```

## Deployment

By default, the deployment of the Kourier components is split between two different namespaces:

- `knative-serving` - Namespace where Kourier control is deployed.
- `kourier-system` - Namespace where gateways are deployed.

To change the Kourier gateway namespace, you will need to:

- Modify the files in `config/` and replace all the namespaces fields that have `kourier-system` with the desired namespace.
- Set the `KOURIER_GATEWAY_NAMESPACE` environmental variable in the `kourier-control` deployment to the new namespace.

## Features

Kourier provides the following features:

- Traffic splitting between Knative revisions.
- Automatic update of endpoints as they are scaled.
- Support for gRPC services.
- Timeouts and retries.
- TLS
- Cipher Suite
- External Authorization support.
- Proxy Protocol (AN EXPERIMENTAL / ALPHA FEATURE)

## Clean up Kourier

See the Uninstall Kourier.

## What's next

- View the [Knative Serving documentation](../serving/README.md).
