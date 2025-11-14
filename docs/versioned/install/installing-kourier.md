---
audience: administrator
components:
  - serving
function: how-to
---

# Plugin: Kourier

This page walks you through manually installing and customizing Kourier for use with Knative. Kourier is an ingress for Knative Serving. Kourier is a lightweight alternative for the Istio ingress as its deployment consists only of an [Envoy proxy](https://www.envoyproxy.io) and a control plane for it.

## Before you begin

This installation is recommended for Knative installations without Istio installed.

You need:

- A Kubernetes cluster with the Knative Serving component installed.

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
    kubectl apply -f {{ artifact(repo="net-kourier",org="knative-extensions",file="kourier.yaml" )}}
    ```

1. Configure Knative Serving to use the proper `ingress.class`:

    ```bash
    kubectl patch configmap/config-network \
      -n knative-serving \
      --type merge \
      -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
    ```

1. Optional - Set your desired domain (replace `127.0.0.1.nip.io` to your preferred domain):

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

- `knative-serving` - Namespace where Kourier controlle is deployed.
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

## Setup TLS certificate

Create a secret containing your TLS certificate and Private key:

```bash
kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
```

Add the following env vars to net-kourier-controller in the "kourier" container:

```bash
CERTS_SECRET_NAMESPACE: ${NAMESPACES_WHERE_THE_SECRET_HAS_BEEN_CREATED}
CERTS_SECRET_NAME: ${CERT_NAME}
```

### Cipher Suites

You can specify the cipher suites for TLS external listener. To specify the cipher suites you want to allow, run the following command to patch config-kourier ConfigMap:

```bash
kubectl -n "knative-serving" patch configmap/config-kourier \
  --type merge \
  -p '{"data":{"cipher-suites":"ECDHE-ECDSA-AES128-GCM-SHA256,ECDHE-ECDSA-CHACHA20-POLY1305"}}'
```

The default uses the default cipher suites of the envoy version.

## External Authorization Configuration

If you want to enable the external authorization support you can set these environment variables in the `net-kourier-controller` deployment:

| Environment Variable | Description |
|---| --- |
| `KOURIER_EXTAUTHZ_HOST` | Required. The external authorization service and port: `my-auth:2222` |
| `KOURIER_EXTAUTHZ_FAILUREMODEALLOW` | Required. Allow traffic to go through if the ext auth service is down. Accepts true/false |
| `KOURIER_EXTAUTHZ_PROTOCOL` | The protocol used to query the ext auth service. Can be one of: GRPC, HTTP, or HTTPS. Defaults to GRPC |
| `KOURIER_EXTAUTHZ_MAXREQUESTBYTES` | Max request bytes defaults to 8192 bytes. For more information, see [BufferSettings](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/http/ext_authz/v3/ext_authz.proto.html#extensions-filters-http-ext-authz-v3-buffersettings) in Envoy documentation.|
| `KOURIER_EXTAUTHZ_TIMEOUT` | Max time in ms to wait for the ext authz service. Defaults to 2s |
| `KOURIER_EXTAUTHZ_PATHPREFIX` | If `KOURIER_EXTAUTHZ_PROTOCOL` is equal to HTTP or HTTPS path to query the ext auth service. For example, if set to `/verify` it will query `/verify/` (notice the trailing `/`). If not set it will query `/` |
| `KOURIER_EXTAUTHZ_PACKASBYTES` | If `KOURIER_EXTAUTHZ_PROTOCOL` is equal to grpc sends the body as raw bytes instead of a UTF-8 string. Accepts only true/false t/f or 1/0. Attempting to set another value will throw an error. Defaults to false. For more information, see [BufferSettings](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/http/ext_authz/v3/ext_authz.proto.html#extensions-filters-http-ext-authz-v3-buffersettings) in Envoy documentation. |

## Proxy Protocol Configuration

Note: this is an experimental/alpha feature.

To enable proxy protocol feature, run the following command to patch config-kourier ConfigMap:

```bash
kubectl patch configmap/config-kourier \
  -n knative-serving \
  --type merge \
  -p '{"data":{"enable-proxy-protocol":"true"}}'
```

Ensure that the file was updated successfully:

```bash
kubectl get configmap config-kourier --namespace knative-serving --output yaml
```

### LoadBalancer configuration

Use your load balancer provider annotation to enable proxy-protocol.

- If you are planning to enable external-domain-tls, use your load balancer (LB) provider annotation to specify a custom name to use for the load balancer. This is used to work around the issue of kube-proxy adding external LB address to node local iptables rule, which will break requests to an LB from in-cluster if the LB is expected to terminate SSL or proxy protocol.

- Change the external Traffic Policy to local so the LB we'll preserve the client source IP and avoids a second hop for LoadBalancer.

Example (Scaleway provider):

```bash
apiVersion: v1
kind: Service
metadata:
  name: kourier
  namespace: kourier-system
  annotations:
    service.beta.kubernetes.io/scw-loadbalancer-proxy-protocol-v2: '*'
    service.beta.kubernetes.io/scw-loadbalancer-use-hostname: "true"
  labels:
    networking.knative.dev/ingress-provider: kourier
spec:
  ports:
    - name: http2
      port: 80
      protocol: TCP
      targetPort: 8080
    - name: https
      port: 443
      protocol: TCP
      targetPort: 8443
  selector:
    app: 3scale-kourier-gateway
  externalTrafficPolicy: Local
  type: LoadBalancer
```

## Tips

Domain Mapping is configured to explicitly use http2 protocol only. This behaviour can be disabled by adding the following annotation to the Domain Mapping resource

```bash
kubectl annotate domainmapping <domain_mapping_name> kourier.knative.dev/disable-http2=true --namespace <namespace>
```

A good use case for this configuration is DomainMapping with Websocket

This annotation is an experimental feature. The annotation name my change in the future.

## What's next

- View the [Knative Serving documentation](../serving/README.md).
