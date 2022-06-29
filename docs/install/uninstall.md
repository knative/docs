# Uninstalling Knative

To uninstall an Operator-based Knative installation, see the following [Uninstall an Operator-based Knative Installation](#uninstall-an-operator-based-knative-installation) procedure.
To uninstall a YAML-based Knative installation, see the following [Uninstall a YAML-based Knative Installation](#uninstall-a-yaml-based-knative-installation) procedure.


## Uninstalling a YAML-based Knative installation

To uninstall a YAML-based Knative installation:


### Uninstalling optional Serving extensions

Uninstall any Serving extensions you have installed by performing the steps in the following relevant tab:



=== "HPA autoscaling"

    Knative also supports the use of the Kubernetes Horizontal Pod Autoscaler (HPA) for driving
    autoscaling decisions.
    The following command will uninstall the components needed to support HPA-class autoscaling:

    ```bash
    kubectl delete -f {{ artifact( repo="serving", file="serving-hpa.yaml") }}
    ```



=== "TLS with cert-manager"

    1. Uninstall the component that integrates Knative with cert-manager:

        ```bash
        kubectl delete -f {{ artifact( repo="net-certmanager", file="release.yaml") }}
        ```

    1. Optional: if you no longer need cert-manager, uninstall it by following the steps in the
    [cert-manager documentation](https://cert-manager.io/docs/installation/uninstall/kubernetes/).



=== "TLS via HTTP01"

    Uninstall the `net-http01` controller by running:

    ```bash
    kubectl delete -f {{ artifact( repo="net-http01", file="release.yaml") }}
    ```



### Uninstalling a networking layer

Follow the relevant procedure to uninstall the networking layer you installed:

<!-- TODO: Link to document/diagram describing what is a networking layer.  -->
<!-- This indentation is important for things to render properly. -->


=== "Contour"

    The following commands uninstall Contour and enable its Knative integration.

    1. Uninstall the Knative Contour controller by running:

        ```bash
        kubectl delete -f {{ artifact( repo="net-contour", file="net-contour.yaml") }}
        ```

    1. Uninstall Contour:

        ```bash
        kubectl delete -f {{ artifact( repo="net-contour", file="contour.yaml") }}
        ```



=== "Istio"

    The following commands uninstall Istio and enable its Knative integration.

    1. Uninstall the Knative Istio controller by running:

        ```bash
        kubectl delete -f {{ artifact( repo="net-istio", file="net-istio.yaml") }}
        ```

    1. Optional: if you no longer need Istio, uninstall it by running:

        ```bash
        kubectl delete -f {{ artifact( repo="net-istio", file="istio.yaml") }}
        ```





=== "Kourier"

    Uninstall the Knative Kourier controller by running:

       ```bash
       kubectl delete -f {{ artifact( repo="net-kourier", file="kourier.yaml") }}
       ```





### Uninstalling the Serving component

1. Uninstall the Serving core components by running:

    ```
    kubectl delete -f https://storage.googleapis.com/knative-nightly/serving/latest/serving-core.yaml
    ```

1. Uninstall the required custom resources by running:

    ```
    kubectl delete -f https://storage.googleapis.com/knative-nightly/serving/latest/serving-crds.yaml
    ```


### Uninstalling optional Eventing extensions

Uninstall any Eventing extensions you have installed by following the relevant procedure:



=== "Apache Kafka Sink"

    1. Uninstall the Kafka Sink data plane:

        ```bash
        kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-sink.yaml") }}
        ```

    1. Uninstall the Kafka controller:

        ```bash
        kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-controller.yaml") }}
        ```



=== "Sugar Controller"

    Uninstall the Eventing Sugar Controller by running:

    ```bash
    kubectl delete -f {{ artifact( repo="eventing", file="eventing-sugar-controller.yaml") }}
    ```



=== "GitHub Source"

    Uninstall a single-tenant GitHub source by running:

    ```bash
    kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-github", file="github.yaml") }}
    ```

    Uninstall a multi-tenant GitHub source by running:

    ```bash
    kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-github", file="mt-github.yaml") }}
    ```



=== "Apache Kafka Source"

    Uninstall the Apache Kafka source by running:

    ```bash
    kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-source.yaml") }}
    ```



=== "GCP Sources"

    Uninstall the GCP sources by running:

    ```bash
    kubectl delete -f {{ artifact(org="google", repo="knative-gcp", file="cloud-run-events.yaml") }}
    ```



=== "Apache CouchDB Source"

    Uninstall the Apache CouchDB source by running:

    ```bash
    kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-couchdb", file="couchdb.yaml") }}
    ```



=== "VMware Sources and Bindings"

    Uninstall the VMware sources and bindings by running:

    ```bash
    kubectl delete -f {{ artifact(org="vmware-tanzu", repo="sources-for-knative", file="release.yaml") }}
    ```







### Uninstalling an optional Broker (Eventing) layer

Uninstall a Broker (Eventing) layer, if you installed one:

<!-- This indentation is important for things to render properly. -->

=== "Apache Kafka Broker"

    1. Uninstall the Kafka Broker data plane by running the following command:

        ```bash
        kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-broker.yaml") }}
        ```

    1. Uninstall the Kafka controller by running the following command:

        ```bash
        kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-controller.yaml") }}
        ```



=== "MT-Channel-based"

    Uninstall the broker by running:

    ```bash
    kubectl delete -f {{ artifact( repo="eventing", file="mt-channel-broker.yaml") }}
    ```







### Uninstalling optional channel (messaging) layers

Uninstall each channel layer you have installed:

<!-- This indentation is important for things to render properly. -->


=== "Apache Kafka Channel"

    Uninstall the Apache Kafka Channel by running:

       ```bash
       kubectl delete -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-channel.yaml")}}
       ```

       <!-- Ideally write steps for uninstalling Apache Kafka for Kubernetes here. -->



=== "Google Cloud Pub/Sub Channel"

    Uninstall the Google Cloud Pub/Sub Channel by running:

       ```bash
       kubectl delete -f {{ artifact(org="google", repo="knative-gcp", file="cloud-run-events.yaml") }}
       ```



=== "In-Memory (standalone)"

    Uninstall the in-memory channel implementation by running:

    ```bash
    kubectl delete -f {{ artifact( repo="eventing", file="in-memory-channel.yaml") }}
    ```



=== "NATS Channel"

    1. Uninstall the NATS Streaming channel by running:

        ```bash
        kubectl delete -f {{ artifact(org="knative-sandbox", repo="eventing-natss", file="eventing-natss.yaml") }}
        ```

    1. Uninstall NATS Streaming for Kubernetes. For more information, see the [eventing-natss](https://github.com/knative-sandbox/eventing-natss/tree/main/config) repository in GitHub.



    <!-- TODO(https://github.com/knative/docs/issues/2153): Add more Channels here -->





### Uninstalling the Eventing component

1. Uninstall the Eventing core components by running:

    ```
    kubectl delete -f https://storage.googleapis.com/knative-nightly/eventing/latest/eventing-core.yaml
    ```

1. Uninstall the required custom resources by running:

    ```
    kubectl delete -f https://storage.googleapis.com/knative-nightly/eventing/latest/eventing-crds.yaml
    ```


## Uninstall an Operator-based Knative installation

To uninstall an Operator-based Knative installation, follow these procedures:


### Removing the Knative Serving component

Remove the Knative Serving CR:

```
kubectl delete KnativeServing knative-serving -n knative-serving
```


### Removing Knative Eventing component

Remove the Knative Eventing CR:

```
kubectl delete KnativeEventing knative-eventing -n knative-eventing
```

Knative operator prevents unsafe removal of Knative resources.
Even if the Knative Serving and Knative Eventing CRs are successfully removed, all the CRDs in
Knative are still kept in the cluster. All your resources relying on Knative CRDs can still work.


### Removing the Knative Operator:

If you have installed Knative using the Release page, remove the operator using the following command:

```
kubectl delete -f {{ artifact(org="knative", repo="operator", file="operator.yaml") }}
```

If you have installed Knative from source, uninstall it using the following command while in the root
directory for the source:

```
ko delete -f config/
```
