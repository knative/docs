# Installing Security-Guard

Here we show how to install Security-Guard in Knative. Security-Guard is an enhancement to knative-Serving and needs to be installed after the Knative-Serving is successfully installed.

Using Security-Guard requires that your cluster will use an enhanced queue-proxy image.

In addition, Security-Guard includes automation for auto-learning a per service Guardian.
Auto-learning requires you to deploy a `guard-service` on your kubernetes cluster.
`guard-service` should be installed in any namespace where you deploy knative services that require Security-Guard protection.

## Before you begin

Before installing Security-Guard, learn [about Security-Guard](./security-guard-about.md)

## Install steps

To start this tutorial, after installing Knative Serving, run the following procedure to replace your queue-proxy image and deploy a `guard-service` in the current namespace.

=== "Install from source"

    1. Clone the Security-Guard repository using `git clone git@github.com:knative-sandbox/security-guard.git`

    1. Do `cd security-guard`

    1. Run `ko apply -Rf ./config`

=== "Install from released images and yamls"

    Use released images to update your system to enable Security-Guard:

    1. Set the feature named `queueproxy.mount-podinfo` to `allowed` in the config-features ConfigMap.

        An easy way to do that is using:

        ```
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.1/config/deploy/config-features.yaml
        ```

    1. Set the deployment parameter `queue-sidecar-image` to `gcr.io/knative-releases/knative.dev/security-guard/cmd/queue` in the config-deployment ConfigMap.

        An easy way to do that is using:

        ```
        kubectl apply -f https://github.com/knative-sandbox/security-guard/releases/download/v0.1.0/queue-proxy.yaml
        ```

    1. Add the necessary Security-Guard resources to your cluster using:

        ```
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.1/config/resources/gateAccount.yaml
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.1/config/resources/serviceAccount.yaml
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/release-0.1/config/resources/guardiansCrd.yaml
        ```

    1. Deploy `guard-service` on your system to enable automated learning of micro-rules. In the current version, it is recommended to deploy `guard-service` in any namespace where knative services are deployed.

        An easy way to do that is using:

        ```
        kubectl apply -f https://github.com/knative-sandbox/security-guard/releases/download/v0.1.0/guard-service.yaml
        ```
