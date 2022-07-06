<!-- Snippet used in the following topics:
- docs/serving/install/README.md
-->
## Configure a networking layer

<!-- TODO: Link to document/diagram describing what is a networking layer.  -->

=== "Istio (default)"

    <h4>Prerequisites</h4>

    - You have a working Istio installation.
    - You have created the `KnativeServing` CR.

    <h4>Procedure</h4>

    1. Install Istio by using the `net-istio` Knative plugin:

        ```bash
        kubectl apply -f {{artifact(repo="net-istio",file="istio.yaml")}}
        ```

    1. Add the `config.istio` spec to the `KnativeServing` CR:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeServing
        metadata:
          name: knative-serving
          namespace: knative-serving
        spec:
          # ...
          config:
            istio:
              local-gateway.knative-serving.knative-local-gateway: "knative-local-gateway.<istio-namespace>.svc.cluster.local"
        ```

        Where:

        - `<istio-namespace>` is the namespace where Istio is installed.

    1. Apply the YAML file for the `KnativeServing` CR by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the `KnativeServing` CR file.

=== "Kourier"

    <h4>Prerequisites</h4>

    - You have a working Kourier installation.
    - You have created the `KnativeServing` CR.

    <h4>Procedure</h4>

    1. Install Kourier by using the `net-kourier` Knative plugin:

        ```bash
        kubectl apply -f {{artifact(repo="net-kourier",file="kourier.yaml")}}
        ```

    1. Configure Knative Serving to use Kourier by running the command:

        ```bash
        kubectl patch configmap/config-network \
            --namespace knative-serving \
            --type merge \
            --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
        ```

        This command adds the `ingress.kourier` spec and the `config.network` spec to the `KnativeServing` CR:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeServing
        metadata:
          name: knative-serving
          namespace: knative-serving
        spec:
          # ...
          ingress:
            kourier:
              enabled: true
          config:
            network:
              ingress-class: "kourier.ingress.networking.knative.dev"
        ```

=== "Contour"

    <h4>Prerequisites</h4>

    - You have a working Contour installation.
    - You have created the `KnativeServing` CR.

    <h4>Procedure</h4>

    1. Install Contour by using the `net-contour` Knative plugin:

        ```bash
        kubectl apply -f {{artifact(repo="net-contour",file="contour.yaml")}}
        ```
        <!-- TODO(https://github.com/knative-sandbox/net-contour/issues/11): We need a guide on how to use/modify a pre-existing install. -->

    1. Configure Knative Serving to use Contour by default by running the command:

        ```bash
        kubectl patch configmap/config-network \
            -n knative-serving \
            --type merge \
            --patch '{"data":{"ingress-class":"contour.ingress.networking.knative.dev"}}'
        ```

        This command adds the `ingress.contour` spec and the `config.network` spec to the `KnativeServing` CR:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeServing
        metadata:
          name: knative-serving
          namespace: knative-serving
        spec:
          # ...
          ingress:
            contour:
              enabled: true
          config:
            network:
              ingress-class: "contour.ingress.networking.knative.dev"
        ```
