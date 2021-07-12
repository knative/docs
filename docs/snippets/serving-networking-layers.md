### Install a networking layer

The tabs below expand to show instructions for installing a networking layer.
Follow the procedure for the networking layer of your choice:

!!! important
    If you do not install or select a networking layer, the Knative Operator uses Istio by default.

<!-- TODO: Link to document/diagram describing what is a networking layer.  -->
<!-- This indentation is important for things to render properly. -->

=== "Istio"

    The following commands install Istio and enable its Knative integration.

    1. Install a properly configured Istio by following the
    [Advanced Istio installation](../installing-istio.md) instructions or by running the command:

        ```bash
        kubectl apply -l knative.dev/crd-install=true -f {{ artifact(repo="net-istio",file="istio.yaml")}}
        kubectl apply -f {{ artifact(repo="net-istio",file="istio.yaml")}}
        ```

    1. Install the Knative Istio controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-istio",file="net-istio.yaml")}}
        ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl -n istio-system get service istio-ingressgateway
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.

=== "Kourier"

    The following commands install Kourier and enable its Knative integration.

    1. Install the Knative Kourier controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-kourier",file="kourier.yaml")}}
        ```

    1. Configure Knative Serving to use Kourier by default by running the command:

        ```bash
        kubectl patch configmap/config-network \
            -n knative-serving \
            --type merge \
            --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
        ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl -n kourier-system get service kourier
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.


=== "Ambassador"

    The following commands install Ambassador and enable its Knative integration.

    1. Create a namespace in which to install Ambassador by running the command:

        ```bash
        kubectl create namespace ambassador
        ```

    1. Install Ambassador by running the command:

        ```bash
        kubectl apply -n ambassador \
          -f https://getambassador.io/yaml/ambassador/ambassador-crds.yaml \
          -f https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml \
          -f https://getambassador.io/yaml/ambassador/ambassador-service.yaml
        ```

    1. Give Ambassador the required permissions by running the command:

        ```bash
        kubectl patch clusterrolebinding ambassador -p '{"subjects":[{"kind": "ServiceAccount", "name": "ambassador", "namespace": "ambassador"}]}'
        ```

    1. Enable Knative support in Ambassador by running the command:

        ```bash
        kubectl set env --namespace ambassador  deployments/ambassador AMBASSADOR_KNATIVE_SUPPORT=true
        ```

    1. Configure Knative Serving to use Ambassador by default by running the command:

        ```bash
        kubectl patch configmap/config-network \
          -n knative-serving \
          --type merge \
          --patch '{"data":{"ingress.class":"ambassador.ingress.networking.knative.dev"}}'
        ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl -n ambassador get service ambassador
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.


=== "Contour"

    The following commands install Contour and enable its Knative integration.

    1. Install a properly configured Contour by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-contour",file="contour.yaml")}}
        ```
        <!-- TODO(https://github.com/knative-sandbox/net-contour/issues/11): We need a guide on how to use/modify a pre-existing install. -->

    1. Install the Knative Contour controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="net-contour",file="net-contour.yaml")}}
        ```

    1. Configure Knative Serving to use Contour by default by running the command:

        ```bash
        kubectl patch configmap/config-network \
            -n knative-serving \
            --type merge \
            --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'
        ```

    1. Fetch the External IP address or CNAME by running the command:

        ```bash
        kubectl -n contour-external get service envoy
        ```

        !!! tip
            Save this to use in the [Configure DNS](#configure-dns) section below.
