# Installing Security-Guard

Here we show how to install Security-Guard in Knative. Security-Guard is an enhancement to knative-Serving and needs to be installed after the Knative-Serving is successfully installed.

Using Security-Guard requires that your cluster will use an enhanced queue-proxy image.

In addition, Security-Guard includes automation for auto-learning a per service Guardian.
Auto-learning requires you to deploy a `guard-service` on your kubernetes cluster.
`guard-service` should be installed in in the `knative-serving` namespace.

In production you would typically also wish to enable TLS and Token support to protect the queue-proxy communication with the `guard-service` as described below.

## Before you begin

Before installing Security-Guard, learn [about Security-Guard](./security-guard-about.md)

## Install steps

To start this tutorial, after installing Knative Serving, run the following procedure to replace your queue-proxy image and deploy a `guard-service`.

=== "Install from source"

    1. Clone the Security-Guard repository using `git clone git@github.com:knative-sandbox/security-guard.git`

    1. Do `cd security-guard`

    1. Run `ko apply -Rf ./config`

=== "Install from released images and yamls"

    Use released images to update your system to enable Security-Guard:

    1. Set the feature named `queueproxy.mount-podinfo` to `allowed` in the config-features ConfigMap.

        An easy way to do that is using:

        ```
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.4/config/deploy/config-features.yaml
        ```

    1. Set the deployment parameter `queue-sidecar-image` to `gcr.io/knative-releases/knative.dev/security-guard/cmd/queue` in the config-deployment ConfigMap.

        An easy way to do that is using:

        ```
        kubectl apply -f https://github.com/knative-sandbox/security-guard/releases/download/v0.4.0/queue-proxy.yaml
        ```

    1. Add the necessary Security-Guard resources to your cluster using:

        ```
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.4/config/resources/gateAccount.yaml
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.4/config/resources/serviceAccount.yaml
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.4/config/resources/guardiansCrd.yaml
        ```

    1. Deploy `guard-service` on your system to enable automated learning of micro-rules.

        An easy way to do that is using:

        ```
        kubectl apply -f https://github.com/knative-sandbox/security-guard/releases/download/v0.4.0/guard-service.yaml
        ```
=== "Install using the Knative Operator"

    !!! note
       The example below shows a case where kourier ingress is used, make the necessary changes when installing with istio or contour.

    Example script to install Security-Guard and Serving with Kourier using the Knative Operator.

    ```
    kubectl apply --filename - <<EOF
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-serving
    ---
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      security:
        securityGuard:
          enabled: true
      ingress:
        kourier:
          enabled: true
      config:
        network:
          ingress.class: "kourier.ingress.networking.knative.dev"
    EOF

    kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.4/config/resources/gateAccount.yaml
    ```

## Per Namespace Setup

In order to deploy guard protected services in a namespace, provide `guard-gate` with the necessary permissions on each namespace used:

```
kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.4/config/resources/gateAccount.yaml
```

## Additional Production Configuration

It is recommended to secure the communication between queue-proxy with the `guard-service` using one of the following methods:

=== "Manual changes"

    1. Add `GUARD_SERVICE_TLS=true` to the environment of `guard-service` to enable TLS and server side authentication using a Knative issued certificate. The `guard-service` will be using the keys in the `knative-serving-certs` secret of the `knative-serving` namespace.

    1. Add `GUARD_SERVICE_AUTH=true` to the environment of `guard-service` to enable client side authentication using tokens

    1. Set the `queue-sidecar-rootca` parameter of the `config-deployment` configmap in the `knative-serving` namespace to the public key defined under `ca-cert.pem` key in the `knative-serving-certs` secret of the `knative-serving` namespace. This will inform queue-proxy to use TLS and approve the guard-service certificates.

    1. Set `queue-sidecar-token-audiences = "guard-service"` at the `config-deployment` configmap in the `knative-serving` namespace. This will produce a a token with audience `guard-service` for every queue-proxy instance.

=== "Using scripts"

    Use the following script to set TLS and Tokens support in guard-service:

    ```
    echo "Add TLS and Tokens to guard-service"
    kubectl patch deployment guard-service -n knative-serving -p '{"spec":{"template":{"spec":{"containers":[{"name":"guard-service","env":[{"name": "GUARD_SERVICE_TLS", "value": "true"}, {"name": "GUARD_SERVICE_AUTH", "value": "true"}]}]}}}}'
    ```

    Use the following script to set TLS and Tokens support in guard-gates:

    ```
    echo "Copy the certificate to a temporary file"
    ROOTCA="$(mktemp)"
    FILENAME=`basename $ROOTCA`
    kubectl get secret -n knative-serving knative-serving-certs -o json| jq -r '.data."ca-cert.pem"' | base64 -d >  $ROOTCA

    echo "Get the certificate in a configmap friendly form"
    CERT=`kubectl create cm config-deployment --from-file $ROOTCA -o json --dry-run=client |jq .data.\"$FILENAME\"`

    echo "Add TLS and Tokens to config-deployment configmap"
    kubectl patch cm config-deployment -n knative-serving -p '{"data":{"queue-sidecar-token-audiences": "guard-service", "queue-sidecar-rootca": '"$CERT"'}}'

    echo "cleanup"
    rm  $ROOTCA
    ```

    Use the following script to read the TLS and Token settings of both guard-service and guard-gates:

    ```
    echo "Results:"
    kubectl get cm config-deployment -n knative-serving -o json|jq '.data'
    kubectl get deployment guard-service -n knative-serving -o json|jq .spec.template.spec.containers[0].env
    ```

    Use the following script to unset TLS and Tokens support in guard-service:

    ```
    echo "Remove TLS and Tokens from  guard-service deployment"
    kubectl patch deployment guard-service -n knative-serving -p '{"spec":{"template":{"spec":{"containers":[{"name":"guard-service","env":[{"name": "GUARD_SERVICE_TLS", "value": "false"}, {"name": "GUARD_SERVICE_AUTH", "value": "false"}]}]}}}}'
    ```

    Use the following script to unset TLS and Tokens support in guard-gates:

    ```
    echo "Remove TLS and Tokens from config-deployment configmap"
    kubectl patch cm config-deployment -n knative-serving -p '{"data":{"queue-sidecar-token-audiences": "", "queue-sidecar-rootca": ""}}'
    ```

=== "Using Knative Operator"

    !!! note
       The example below shows a case where kourier ingress is used, make the necessary changes when installing with istio or contour.

    Example script to install Security-Guard with TLS and Serving with Kourier using the Knative Operator.

    ```
    kubectl apply --filename - <<EOF
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-serving
    ---
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    EOF

    echo "Waiting for secret to be created (CTRL-C to exit)"
    PEM=""
    while [[ -z $PEM ]]
    do
      echo -n "."
      sleep 1
      DOC=`kubectl get secret -n knative-serving knative-serving-certs -o json 2> /dev/null`
      PEM=`echo $DOC | jq -r '.data."ca-cert.pem"'`
    done
    echo " Secret found!"

    echo "Copy the certificate to file"
    ROOTCA="$(mktemp)"
    FILENAME=`basename $ROOTCA`
    echo $PEM | base64 -d >  $ROOTCA

    echo "Create a temporary config-deployment configmap with the certificate"
    CERT=`kubectl create cm config-deployment --from-file $ROOTCA -o json --dry-run=client |jq .data.\"$FILENAME\"`

    echo "cleanup"
    rm $ROOTCA

    kubectl apply --filename - <<EOF
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      deployments:
      - name: guard-service
        env:
        - container: guard-service
          envVars:
          - name: GUARD_SERVICE_TLS
            value: "true"
          - name: GUARD_SERVICE_AUTH
            value: "true"
      security:
        securityGuard:
          enabled: true
      ingress:
        kourier:
          enabled: true
      config:
        network:
          ingress.class: "kourier.ingress.networking.knative.dev"
        deployment:
          queue-sidecar-rootca: ${CERT}
          queue-sidecar-token-audiences: guard-service
    EOF
    ```
