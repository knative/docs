---
title: "Uninstalling Knative"
weight: 85
type: "docs"
---

To uninstall an Operator-based Knative installation, follow the [Uninstall an Operator-based Knative Installation](#uninstall-an-operator-based-knative-installation) procedure below.
To uninstall a YAML-based Knative installation, follow the [Uninstall a YAML-based Knative Installation](#uninstall-a-yaml-based-knative-installation) procedure below.


## Uninstalling a YAML-based Knative installation

To uninstall a YAML-based Knative installation:


### Uninstalling optional Serving extensions

Uninstall any Serving extensions you have installed by following the relevant steps below:

{{< tabs name="serving_extensions" >}}

{{% tab name="HPA autoscaling" %}}

Knative also supports the use of the Kubernetes Horizontal Pod Autoscaler (HPA) for driving
autoscaling decisions.
The following command will uninstall the components needed to support HPA-class autoscaling:

```bash
kubectl delete -f {{< artifact repo="serving" file="serving-hpa.yaml" >}}
```

{{< /tab >}}

{{% tab name="TLS with cert-manager" %}}

1. Uninstall the component that integrates Knative with cert-manager:

   ```bash
   kubectl delete -f {{< artifact repo="net-certmanager" file="release.yaml" >}}
   ```

1. Optional: if you no longer need cert-manager, uninstall it by following the steps in the
[cert-manager documentation](https://cert-manager.io/docs/installation/uninstall/kubernetes/).

   {{< /tab >}}

{{% tab name="TLS via HTTP01" %}}

Uninstall the `net-http01` controller by running:

```bash
kubectl delete -f {{< artifact repo="net-http01" file="release.yaml" >}}
```

{{< /tab >}}

{{% tab name="TLS wildcard support" %}}

Uninstall the components needed to provision wildcard certificates in each namespace by running:

```bash
kubectl delete -f {{< artifact repo="serving" file="serving-nscert.yaml" >}}
```

{{< /tab >}}

{{% tab name="DomainMapping CRD" %}}

To uninstall the `DomainMapping` components run:

```bash
kubectl delete -f {{< artifact repo="serving" file="serving-domainmapping.yaml" >}}
kubectl delete -f {{< artifact repo="serving" file="serving-domainmapping-crds.yaml" >}}
```

{{< /tab >}} {{< /tabs >}}


### Uninstalling a networking layer

Follow the relevant procedure to uninstall the networking layer you installed:

<!-- TODO: Link to document/diagram describing what is a networking layer.  -->
<!-- This indentation is important for things to render properly. -->

   {{< tabs name="serving_networking" default="Kourier" >}}
   {{% tab name="Ambassador" %}}

The following commands uninstall Ambassador and enable its Knative integration.

1. Uninstall Ambassador by running:

   ```bash
   kubectl delete --namespace ambassador \
    -f https://getambassador.io/yaml/ambassador/ambassador-crds.yaml \
    -f https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml \
    -f https://getambassador.io/yaml/ambassador/ambassador-service.yaml
   ```

1. Delete the Ambassador namespace:

   ```bash
   kubectl delete namespace ambassador
   ```

{{< /tab >}}

{{% tab name="Contour" %}}

The following commands uninstall Contour and enable its Knative integration.

1. Uninstall the Knative Contour controller by running:

    ```bash
    kubectl delete -f {{< artifact repo="net-contour" file="net-contour.yaml" >}}
    ```

1. Uninstall Contour:

    ```bash
    kubectl delete -f {{< artifact repo="net-contour" file="contour.yaml" >}}
    ```

{{< /tab >}}

{{% tab name="Gloo" %}}

Uninstall Gloo and the Knative integration by running:

   ```bash
   glooctl uninstall knative
   ```

{{< /tab >}}

{{% tab name="Istio" %}}

The following commands uninstall Istio and enable its Knative integration.

1. Uninstall the Knative Istio controller by running:

    ```bash
    kubectl delete -f {{< artifact repo="net-istio" file="net-istio.yaml" >}}
    ```

1. Optional: if you no longer need Istio, uninstall it by running:

    ```bash
    kubectl delete -f {{< artifact repo="net-istio" file="istio.yaml" >}}
    ```

{{< /tab >}}

{{% tab name="Kong" %}}

Uninstall Kong Ingress Controller by running:

   ```bash
   kubectl delete -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/0.9.x/deploy/single/all-in-one-dbless.yaml
   ```

{{< /tab >}}

{{% tab name="Kourier" %}}

Uninstall the Knative Kourier controller by running:

   ```bash
   kubectl delete -f {{< artifact repo="net-kourier" file="kourier.yaml" >}}
   ```

{{< /tab >}} {{< /tabs >}}


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

Uninstall any Eventing extensions you have installed by following the relevant procedure below:

{{< tabs name="eventing_extensions" >}}

{{% tab name="Apache Kafka Sink" %}}

1. Uninstall the Kafka Sink data plane:

   ```bash
   kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-sink.yaml" >}}
   ```

1. Uninstall the Kafka controller:

   ```bash
   kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-controller.yaml" >}}
   ```

{{< /tab >}}

{{% tab name="Sugar Controller" %}}

Uninstall the Eventing Sugar Controller by running:

```bash
kubectl delete -f {{< artifact repo="eventing" file="eventing-sugar-controller.yaml" >}}
```

{{< /tab >}}

{{% tab name="GitHub Source" %}}

Uninstall a single-tenant GitHub source by running:

```bash
kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-github" file="github.yaml" >}}
```

Uninstall a multi-tenant GitHub source by running:

```bash
kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-github" file="mt-github.yaml" >}}
```

{{< /tab >}}

{{% tab name="Apache Camel-K Source" %}}

Uninstall the Apache Camel-K Source by running:

```bash
kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-camel" file="camel.yaml" >}}
```

{{< /tab >}}

{{% tab name="Apache Kafka Source" %}}

Uninstall the Apache Kafka source by running:

```bash
kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-kafka" file="source.yaml" >}}
```

{{< /tab >}}

{{% tab name="GCP Sources" %}}

Uninstall the GCP sources by running:

```bash
kubectl delete -f {{< artifact org="google" repo="knative-gcp" file="cloud-run-events.yaml" >}}
```

{{< /tab >}}

{{% tab name="Apache CouchDB Source" %}}

Uninstall the Apache CouchDB source by running:

```bash
kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-couchdb" file="couchdb.yaml" >}}
```

{{< /tab >}}

{{% tab name="VMware Sources and Bindings" %}}

Uninstall the VMware sources and bindings by running:

```bash
kubectl delete -f {{< artifact org="vmware-tanzu" repo="sources-for-knative" file="release.yaml" >}}
```

{{< /tab >}}

{{< /tabs >}}


### Uninstalling an optional Broker (Eventing) layer

Uninstall a Broker (Eventing) layer, if you installed one:

<!-- This indentation is important for things to render properly. -->
{{< tabs name="eventing_brokers" default="MT-Channel-based" >}}
{{% tab name="Apache Kafka Broker" %}}

1. Uninstall the Kafka Broker data plane by running the following command:

    ```bash
    kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-broker.yaml" >}}
    ```

1. Uninstall the Kafka controller by running the following command:

    ```bash
    kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-controller.yaml" >}}
    ```

{{< /tab >}}

{{% tab name="MT-Channel-based" %}}

Uninstall the broker by running:

```bash
kubectl delete -f {{< artifact repo="eventing" file="mt-channel-broker.yaml" >}}
```

{{< /tab >}}

{{< /tabs >}}


### Uninstalling optional channel (messaging) layers

Uninstall each channel layer you have installed:

<!-- This indentation is important for things to render properly. -->

   {{< tabs name="eventing_channels" default="In-Memory (standalone)" >}}
   {{% tab name="Apache Kafka Channel" %}}

Uninstall the Apache Kafka Channel by running:

   ```bash
   curl -L "{{< artifact org="knative-sandbox" repo="eventing-kafka" file="channel-consolidated.yaml" >}}" \
    | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
    | kubectl delete -f -
   ```

   <!-- Ideally write steps for uninstalling Apache Kafka for Kubernetes here. -->

{{< /tab >}}

{{% tab name="Google Cloud Pub/Sub Channel" %}}

Uninstall the Google Cloud Pub/Sub Channel by running:

   ```bash
   kubectl delete -f {{< artifact org="google" repo="knative-gcp" file="cloud-run-events.yaml" >}}
   ```

{{< /tab >}}

{{% tab name="In-Memory (standalone)" %}}

Uninstall the in-memory channel implementation by running:

```bash
kubectl delete -f {{< artifact repo="eventing" file="in-memory-channel.yaml" >}}
```

{{< /tab >}}

{{% tab name="NATS Channel" %}}

1. Uninstall the NATS Streaming channel by running:

    ```bash
    kubectl delete -f {{< artifact org="knative-sandbox" repo="eventing-natss" file="300-natss-channel.yaml" >}}
    ```

1. Uninstall NATS Streaming for Kubernetes. For more information, see the [eventing-natss](https://github.com/knative-sandbox/eventing-natss/tree/main/config) repository in GitHub.

{{< /tab >}}

<!-- TODO(https://github.com/knative/docs/issues/2153): Add more Channels here -->

{{< /tabs >}}


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

To uninstall an Operator-based Knative installation, follow the procedures below.


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
kubectl delete -f {{< artifact org="knative" repo="operator" file="operator.yaml" >}}
```

If you have installed Knative from source, uninstall it using the following command while in the root
directory for the source:

```
ko delete -f config/
```
