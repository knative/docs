# Installing Security-Guard

!!! note
    Knative operator supports installing Security-Guard. This guide is for users installing Security-Guard without the Knative operator.

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
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.3/config/deploy/config-features.yaml
        ```

    1. Set the deployment parameter `queue-sidecar-image` to `gcr.io/knative-releases/knative.dev/security-guard/cmd/queue` in the config-deployment ConfigMap.

        An easy way to do that is using:

        ```
        kubectl apply -f https://github.com/knative-sandbox/security-guard/releases/download/v0.3.0/queue-proxy.yaml
        ```

    1. Add the necessary Security-Guard resources to your cluster using:

        ```
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.3/config/resources/gateAccount.yaml
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.3/config/resources/serviceAccount.yaml
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.3/config/resources/guardiansCrd.yaml
        ```

    1. Deploy `guard-service` on your system to enable automated learning of micro-rules. 

        An easy way to do that is using:

        ```
        kubectl apply -f https://github.com/knative-sandbox/security-guard/releases/download/v0.3.0/guard-service.yaml
        ```

## Additional Production Configuration

It is recommended to secure the communication between queue-proxy with the `guard-service` using the following steps:

1. Add `GUARD_SERVICE_TLS=true` to the environment of `guard-service` to enable TLS and server side authentication using a Knative issued certificate. The `guard-service` will be using the keys in the `knative-serving-certs` secret of the `knative-serving` namespace.

1. Add `GUARD_SERVICE_AUTH=true` to the environment of `guard-service` to enable client side authentication using tokens

1. Set the `QueueSidecarRootCA` parameter of the `config-deployment` configmap in the `knative-serving` namespace to the public key defined in the `knative-serving-certs` secret of the `knative-serving` namespace. This will inform queue-proxy to approve knative issued certificates.

1. Set `QueueSidecarTokenAudiences = "guard-service"` at the `config-deployment` configmap in the `knative-serving` namespace. This will produce a a token with audience `guard-service` for every queue-proxy instance.
