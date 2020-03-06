---
title: "Installing Knative"
weight: 06
type: "docs"
aliases:
  - /docs/install/knative-with-any-k8s
  - /docs/install/knative-with-aks
  - /docs/install/knative-with-ambassador
  - /docs/install/knative-with-contour
  - /docs/install/knative-with-docker-for-mac
  - /docs/install/knative-with-gke
  - /docs/install/knative-with-gardener
  - /docs/install/knative-with-gloo
  - /docs/install/knative-with-icp
  - /docs/install/knative-with-iks
  - /docs/install/knative-with-microk8s
  - /docs/install/knative-with-minikube
  - /docs/install/knative-with-pks
---

This guide walks you through the installation of the latest version of Knative.

Knative has two components, which can be installed and used independently or together.
To help you pick and choose the pieces that are right for you, here is a brief
description of each:
 - [**Serving**](#installing-the-serving-component) {{< feature-state version="v0.9" state="stable" short=true >}} provides an abstraction for stateless request-based scale-to-zero services.
 - [**Eventing**](#installing-the-eventing-component) {{< feature-state version="v0.2" state="alpha" short=true >}} provides abstractions to enable binding event sources (e.g. Github Webhooks, Kafka) and consumers (e.g. Kubernetes or Knative Services).

Knative also has an [**Observability plugin**](#installing-the-observability-plugin) {{< feature-state version="v0.1" state="alpha" short=true >}}  which provides standard tooling that can be used to get visibility into the health of the software running on Knative.

## Before you begin

This guide assumes that you want to install an upstream Knative release on a Kubernetes cluster. A growing number of vendors have managed Knative offerings; see the [Knative Offerings](../knative-offerings.md) page for a full list.

Knative {{< version >}} requires a Kubernetes cluster v1.15 or newer, as well as a compatible
`kubectl`. This guide assumes that you've already created a Kubernetes cluster,
and that you are using bash in a Mac or Linux environment; some commands will
need to be adjusted for use in a Windows environment.

<!-- TODO: Link to provisioning guide for advanced installation -->

## Installing the Serving component

{{< feature-state version="v0.9" state="stable" >}}


The following commands install the Knative Serving component.

1. Install the [Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) (aka CRDs):

   ```bash
   kubectl apply --filename {{< artifact repo="serving" file="serving-crds.yaml" >}}
   ```

1. Install the core components of Serving (see below for optional extensions):

   ```bash
   kubectl apply --filename {{< artifact repo="serving" file="serving-core.yaml" >}}
   ```

1. Pick a networking layer (alphabetical):
   <!-- TODO: Link to document/diagram describing what is a networking layer.  -->

   <!-- This indentation is important for things to render properly. -->
   {{< tabs name="serving_networking" default="Istio" >}}
{{% tab name="Ambassador" %}}

{{% feature-state version="v0.8" state="alpha" %}}

The following commands install Ambassador and enable its Knative integration.

1. Create a namespace to install Ambassador in:

   ```bash
   kubectl create namespace ambassador
   ```

1. Install Ambassador:

   ```bash
   kubectl apply --namespace ambassador \
     --filename https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml \
     --filename https://getambassador.io/yaml/ambassador/ambassador-service.yaml
   ```

1. Give Ambassador the required permissions:

   ```bash
   kubectl patch clusterrolebinding ambassador -p '{"subjects":[{"kind": "ServiceAccount", "name": "ambassador", "namespace": "ambassador"}]}'
   ```

1. Enable Knative support in Ambassador:

   ```bash
   kubectl set env --namespace ambassador  deployments/ambassador AMBASSADOR_KNATIVE_SUPPORT=true
   ```

1. To configure Knative Serving to use Ambassador by default:

    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress.class":"ambassador.ingress.networking.knative.dev"}}'
    ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace ambassador get service ambassador
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Contour" %}}

{{% feature-state version="v0.12" state="alpha" %}}

The following commands install Contour and enable its Knative integration.

1. Install a properly configured Contour:

   ```bash
   kubectl apply --filename {{< artifact repo="net-contour" file="contour.yaml" >}}
   ```

   <!-- TODO(https://github.com/knative/net-contour/issues/11): We need a guide on how to use/modify a pre-existing install. -->

1. Install the Knative Contour controller:

   ```bash
   kubectl apply --filename {{< artifact repo="net-contour" file="net-contour.yaml" >}}
   ```

1. To configure Knative Serving to use Contour by default:

    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'
    ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace contour-external get service envoy
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Gloo" %}}

{{% feature-state version="v0.8" state="alpha" %}}

_For a detailed guide on Gloo integration, see [Installing Gloo for Knative](https://docs.solo.io/gloo/latest/installation/knative/) in the Gloo documentation._

The following commands install Gloo and enable its Knative integration.

1. Make sure `glooctl` is installed (version 1.3.x and higher recommended):

   ```bash
   glooctl version
   ```

   If it is not installed, you can install the latest version using:

   ```bash
   curl -sL https://run.solo.io/gloo/install | sh
   export PATH=$HOME/.gloo/bin:$PATH
   ```

   Or following the [Gloo CLI install instructions](https://docs.solo.io/gloo/latest/installation/knative/#install-command-line-tool-cli).

1. Install Gloo and the Knative integration:

    ```bash
    glooctl install knative --install-knative=false
    ```

1. Fetch the External IP or CNAME:

   ```bash
   glooctl proxy url --name knative-external-proxy
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Istio" %}}

{{% feature-state version="v0.9" state="stable" %}}

The following commands install Istio and enable its Knative integration.

<!-- TODO(https://github.com/knative/docs/issues/2166): Create streamlined instructions to inline -->

1. [Installing Istio for Knative](./installing-istio.md)

1. Install the Knative Istio controller:

   ```bash
   kubectl apply --filename {{< artifact repo="net-istio" file="release.yaml" >}}
   ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace istio-system get service istio-ingressgateway
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Kourier" %}}

{{% feature-state version="v0.12" state="alpha" %}}

The following commands install Kourier and enable its Knative integration.

1. Install the Knative Kourier controller:

   ```bash
   kubectl apply --filename https://raw.githubusercontent.com/knative/serving/{{< version >}}/third_party/kourier-latest/kourier.yaml
   ```

1. To configure Knative Serving to use Kourier by default:

    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
    ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace kourier-system get service kourier
   ```

   Save this for configuring DNS below.

{{< /tab >}}
{{< /tabs >}}

1. Configure DNS

   <!-- This indentation is important for things to render properly. -->
   {{< tabs name="serving_dns" >}}
{{% tab name="Magic DNS (xip.io)" %}}
We ship a simple Kubernetes Job called "default domain" that will (see caveats) configure Knative Serving to use <a href="http://xip.io">xip.io</a> as the default DNS suffix.

```bash
kubectl apply --filename {{< artifact repo="serving" file="serving-default-domain.yaml" >}}
```

**Caveat**: This will only work if the cluster LoadBalancer service exposes an IPv4 address, so it will not work with IPv6 clusters, AWS, or local setups like Minikube.  For these, see "Real DNS".
{{< /tab >}}


{{% tab name="Real DNS" %}}
To configure DNS for Knative, take the External IP or CNAME from setting up networking, and configure it with your DNS provider as follows:

- If the networking layer produced an External IP address, then configure a wildcard `A` record for the domain:

    ```
    # Here knative.example.com is the domain suffix for your cluster
    *.knative.example.com == A 35.233.41.212
    ```

- If the networking layer produced a CNAME, then configure a CNAME record for the domain:

    ```
    # Here knative.example.com is the domain suffix for your cluster
    *.knative.example.com == CNAME a317a278525d111e89f272a164fd35fb-1510370581.eu-central-1.elb.amazonaws.com
    ```

Once your DNS provider has been configured, direct Knative to use that domain:

```bash
# Replace knative.example.com with your domain suffix
kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"knative.example.com":""}}'
```

{{< /tab >}}
{{< /tabs >}}

1. Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`:

   ```bash
   kubectl get pods --namespace knative-serving
   ```

At this point, you have a basic installation of Knative Serving!


### Optional Serving extensions

{{< tabs name="serving_extensions" >}}
{{% tab name="HPA autoscaling" %}}

{{% feature-state version="v0.8" state="beta" %}}

Knative also supports the use of the Kubernetes Horizontal Pod Autoscaler (HPA)
for driving autoscaling decisions.  The following command will install the
components needed to support HPA-class autoscaling:

```bash
kubectl apply --filename {{< artifact repo="serving" file="serving-hpa.yaml" >}}
```

<!-- TODO(https://github.com/knative/docs/issues/2152): Link to a more in-depth guide on HPA-class autoscaling -->

{{< /tab >}}

{{% tab name="TLS with cert-manager" %}}

{{% feature-state version="v0.6" state="alpha" %}}

Knative supports automatically provisioning TLS certificates via [cert-manager](https://cert-manager.io/docs/).  The following commands will install the components needed to support the provisioning of TLS certificates via cert-manager.

1. First, install [cert-manager version `0.12.0` or higher](../serving/installing-cert-manager.md)

2. Next, install the component that integrates Knative with cert-manager:

    ```bash
    kubectl apply --filename {{< artifact repo="serving" file="serving-cert-manager.yaml" >}}
    ```

3. Now configure Knative to [automatically configure TLS certificates](../serving/using-auto-tls.md).
{{< /tab >}}

{{% tab name="TLS wildcard support" %}}

<!-- This isn't where this was introduced, but we seem to have missed it in the release notes :( -->
{{% feature-state version="v0.12" state="alpha" %}}

If you plan to use cert-manager's support for provisioning wildcard certificates, then the most efficient way to provision certificates is with the namespace wildcard certificate controller.  The following command will install the components needed to provision wildcard certificates in each namespace:

```bash
kubectl apply --filename {{< artifact repo="serving" file="serving-nscert.yaml" >}}
```

{{< /tab >}}
{{< /tabs >}}


### Getting started with Serving

Deploy your first app with the [getting started with Knative app deployment](../serving/getting-started-knative-app.md) guide.  You can also find a number of samples for Knative Serving [here](../serving/samples/).


## Installing the Eventing component

{{< feature-state version="v0.2" state="alpha" >}}


The following commands install the Knative Eventing component.

1. Install the [Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) (aka CRDs):

   ```bash
   kubectl apply --filename {{< artifact repo="eventing" file="eventing-crds.yaml" >}}
   ```

1. Install the core components of Eventing (see below for optional extensions):

   ```bash
   kubectl apply --filename {{< artifact repo="eventing" file="eventing-core.yaml" >}}
   ```

1. Install a default Channel (messaging) layer (alphabetical).

   <!-- This indentation is important for things to render properly. -->
   {{< tabs name="eventing_channels" default="In-Memory (standalone)" >}}
{{% tab name="Apache Kafka Channel" %}}

1. First, [Install Apache Kafka for Kubernetes](../eventing/samples/kafka/README.md)

1. Then install the Apache Kafka Channel:

   ```bash
   curl -L "{{< artifact repo="eventing-contrib" file="kafka-channel.yaml" >}}" \
    | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
    | kubectl apply --filename -
   ```

To learn more about the Apache Kafka channel, try [our sample](../eventing/samples/kafka/channel/README.md)

{{< /tab >}}

{{% tab name="Google Cloud Pub/Sub Channel" %}}

1. Install the Google Cloud Pub/Sub Channel:

   ```bash
   # This installs both the Channel and the GCP Sources.
   kubectl apply --filename {{< artifact org="google" repo="knative-gcp" file="cloud-run-events.yaml" >}}
   ```

To learn more about the Google Cloud Pub/Sub Channel, try [our sample](https://github.com/google/knative-gcp/blob/master/docs/examples/channel/README.md)

{{< /tab >}}

{{% tab name="In-Memory (standalone)" %}}

{{< feature-state version="v0.2" state="alpha" >}}

The following command installs an implementation of Channel that runs in-memory.  This implementation is nice because it is simple and standalone, but it is unsuitable for production use cases.

   ```bash
   kubectl apply --filename {{< artifact repo="eventing" file="in-memory-channel.yaml" >}}
   ```

{{< /tab >}}

{{% tab name="NATS Channel" %}}

1. First, [Install NATS Streaming for Kubernetes](https://github.com/knative/eventing-contrib/blob/{{< version >}}/natss/config/broker/README.md)

1. Then install the NATS Streaming Channel:

   ```bash
   kubectl apply --filename {{< artifact repo="eventing-contrib" file="natss-channel.yaml" >}}
   ```

{{< /tab >}}

<!-- TODO(https://github.com/knative/docs/issues/2153): Add more Channels here -->

{{< /tabs >}}

1. Install a default Broker (eventing) layer:

   <!-- This indentation is important for things to render properly. -->
   {{< tabs name="eventing_brokers" default="Channel-based" >}}
{{% tab name="Channel-based" %}}
{{< feature-state version="v0.5" state="alpha" >}}

The following command installs an implementation of Broker that utilizes Channels:

   ```bash
   kubectl apply --filename {{< artifact repo="eventing" file="channel-broker.yaml" >}}
   ```

To customize which channel implementation is used, update the following ConfigMap:

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: default-ch-webhook
     namespace: knative-eventing
   data:
     default-ch-config: |
       # This is the cluster-wide default channel.
       clusterDefault:
         apiVersion: messaging.knative.dev/v1alpha1
         kind: InMemoryChannel

       namespaceDefaults:
         # This allows you to specify different defaults per-namespace,
         # in this case the "some-namespace" namespace will use the Kafka
         # channel by default.
         some-namespace:
           apiVersion: messaging.knative.dev/v1alpha1
           kind: KafkaChannel
           spec:
             numPartitions: 2
             replicationFactor: 1
   ```

{{< /tab >}}

{{< /tabs >}}

1. Monitor the Knative components until all of the components show a `STATUS` of
   `Running`:

   ```bash
   kubectl get pods --namespace knative-eventing
   ```

At this point, you have a basic installation of Knative Eventing!


### Optional Eventing extensions

   <!-- This indentation is important for things to render properly. -->
   {{< tabs name="eventing_extensions" >}}
{{% tab name="Enable Broker" %}}

<!-- Unclear when this feature came in -->
{{< feature-state version="v0.5" state="alpha" >}}

The following command enables the default Broker on a namespace (here `default`):

   ```bash
   kubectl label namespace default knative-eventing-injection=enabled
   ```

{{< /tab >}}

{{% tab name="Github Source" %}}

{{< feature-state version="v0.2" state="alpha" >}}

The following command installs the Github Source:

   ```bash
   kubectl apply --filename {{< artifact repo="eventing-contrib" file="github.yaml" >}}
   ```

To learn more about the Github source, try [our sample](../eventing/samples/github-source/README.md)

{{< /tab >}}

{{% tab name="Apache Camel-K Source" %}}
{{< feature-state version="v0.5" state="alpha" >}}

The following command installs the Apache Camel-K Source:

   ```bash
   kubectl apply --filename {{< artifact repo="eventing-contrib" file="camel.yaml" >}}
   ```

To learn more about the Apache Camel-K source, try [our sample](../eventing/samples/apache-camel-source/README.md)

{{< /tab >}}

{{% tab name="Apache Kafka Source" %}}

{{< feature-state version="v0.5" state="alpha" >}}

The following command installs the Apache Kafka Source:

   ```bash
   kubectl apply --filename {{< artifact repo="eventing-contrib" file="kafka-source.yaml" >}}
   ```

To learn more about the Apache Kafka source, try [our sample](../eventing/samples/kafka/source/README.md)

{{< /tab >}}

{{% tab name="GCP Sources" %}}

{{< feature-state version="v0.2" state="alpha" >}}

The following command installs the GCP Sources:

   ```bash
   # This installs both the Sources and the Channel.
   kubectl apply --filename {{< artifact org="google" repo="knative-gcp" file="cloud-run-events.yaml" >}}
   ```

To learn more about the Cloud Pub/Sub source, try [our sample](../eventing/samples/cloud-pubsub-source/README.md).

To learn more about the Cloud Storage source, try [our sample](../eventing/samples/cloud-storage-source/README.md).

To learn more about the Cloud Scheduler source, try [our sample](../eventing/samples/cloud-scheduler-source/README.md).

To learn more about the Cloud Audit Logs source, try [our sample](../eventing/samples/cloud-audit-logs-source/README.md).

{{< /tab >}}

<!-- TODO: couchdb source -->
<!-- TODO: prometheus source -->
<!-- TODO: AWS SQS source  -->

<!-- TODO(https://github.com/knative/docs/issues/2154): Add sources and other stuff here. -->

{{< /tabs >}}


### Getting started with Eventing

You can find a number of samples for Knative Eventing [here](../eventing/samples/README.md). A quick-start guide is available [here](../eventing/getting-started.md).


## Installing the Observability plugin

{{< feature-state version="v0.2" state="alpha" >}}

Install the following observability features to enable logging, metrics, and request tracing in your Serving and Eventing components.

All observibility plugins require that you first install the core:

```bash
kubectl apply --filename {{< artifact repo="serving" file="monitoring-core.yaml" >}}
```

After the core is installed, you can choose to install one or all of the following observability plugins:

- Install [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) for metrics:

   ```bash
   kubectl apply --filename {{< artifact repo="serving" file="monitoring-metrics-prometheus.yaml" >}}
   ```

- Install the [ELK stack](https://www.elastic.co/what-is/elk-stack) (Elasticsearch, Logstash and Kibana) for logs:

   ```bash
   kubectl apply --filename {{< artifact repo="serving" file="monitoring-logs-elasticsearch.yaml" >}}
   ```

- Install [Jaeger](https://jaegertracing.io/) for distributed tracing

   <!-- This indentation is important for things to render properly. -->
   {{< tabs name="jaeger" default="In-Memory (standalone)" >}}
{{% tab name="In-Memory (standalone)" %}}
To install the in-memory (standalone) version of Jaeger, run the following command:

```bash
kubectl apply --filename {{< artifact repo="serving" file="monitoring-tracing-jaeger-in-mem.yaml" >}}
```
{{< /tab >}}

{{% tab name="ELK stack" %}}
To install the ELK version of Jaeger (needs the ELK install above), run the following command:

```bash
kubectl apply --filename {{< artifact repo="serving" file="monitoring-tracing-jaeger.yaml" >}}
```
{{< /tab >}}
{{< /tabs >}}

- Install [Zipkin](https://zipkin.io/) for distributed tracing

   <!-- This indentation is important for things to render properly. -->
   {{< tabs name="zipkin" default="In-Memory (standalone)" >}}
{{% tab name="In-Memory (standalone)" %}}
To install the in-memory (standalone) version of Zipkin, run the following command:

```bash
kubectl apply --filename {{< artifact repo="serving" file="monitoring-tracing-zipkin-in-mem.yaml" >}}
```
{{< /tab >}}

{{% tab name="ELK stack" %}}
To install the ELK version of Zipkin (needs the ELK install above), run the following command:

```bash
kubectl apply --filename {{< artifact repo="serving" file="monitoring-tracing-zipkin.yaml" >}}
```
{{< /tab >}}
{{< /tabs >}}
