# Eventing integration with Istio service mesh

**Flag name**: `istio`

**Stage**: Beta, disabled by default

**Tracking issue**: [#6596](https://github.com/knative/eventing/issues/6596)

## Overview

Administrators can use Istio with Eventing to encrypt, authenticate and authorize requests to
Eventing components.

## Prerequisites

- In order to enable the istio integration, you will need to install Istio by
  following [the Istio installation guides](https://istio.io/latest/docs/setup/install/).

## Installation

Some Eventing components use services of type `ExternalName` and with such services, Istio need to
be manually configured to connect to such services using mutual TLS.

Eventing releases a controller that automatically configures Istio so that any pod that is part of
an Istio mesh can communicate with Eventing components that are also part of the same Istio mesh.

1. Create the Eventing namespace and enable Istio injection:
    ```shell
    kubectl create namespace knative-eventing --dry-run=client -oyaml | kubectl apply -f -
    kubectl label namespace knative-eventing istio-injection=enabled
    ```
2. [Follow Eventing installation](./../../install)

3. Install `eventing-istio-controller`:
    ```shell
    kubectl apply -f {{ artifact(org="knative-extensions", repo="eventing-istio",file="eventing-istio.yaml")}}
    ```
4. Verify `eventing-istio-controller` is ready:
    ```shell
    kubectl get deployment -n knative-eventing
    ```
   Example output:
    ```shell
    NAME                        ...   READY
    eventing-istio-controller   ...   True 
    # other deployments omitted ...
    ```

## Enable istio integration

The `istio` feature flag is an enum configuration that configures the `eventing-istio-controller` to
create Istio resources for Eventing resources.

The possible values for `istio` are:

- `disabled`
    - Disable Eventing integration with Istio
- `enabled`
    - Enabled Eventing integration with Istio

For example, to enable `istio` integration, the `config-features` ConfigMap will look like
the following:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-eventing
data:
  istio: "enabled"
```

