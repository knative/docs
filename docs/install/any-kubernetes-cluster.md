---
title: "YAML-based installation"
weight: 01
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
  - /docs/install/knative-with-minishift
  - /docs/install/knative-with-pks
showlandingtoc: "false"
---

You can install Knative by applying YAML files using the `kubectl` CLI.

## Prerequisites

- You have a cluster that uses Kubernetes v1.18 or newer.
- You have installed the [`kubectl` CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- If you have only one node in your cluster, you will need at least 6 CPUs, 6 GB of memory, and 30 GB of disk storage.
- If you have multiple nodes in your cluster, for each node you will need at least 2 CPUs, 4 GB of memory, and 20 GB of disk storage.
<!--TODO: Verify these requirements-->
- Your Kubernetes cluster must have access to the internet, since Kubernetes needs to be able to fetch images.

## Installing the Serving component

1. Install the required custom resources:

   ```bash
   kubectl apply -f {{< artifact repo="serving" file="serving-crds.yaml" >}}
   ```

1. Install the core components of Serving (see below for optional extensions):

   ```bash
   kubectl apply -f {{< artifact repo="serving" file="serving-core.yaml" >}}
   ```

### Installing a Networking Layer (Listed Alphabetically):

      <!-- TODO: Link to document/diagram describing what is a networking layer.  -->

      <!-- This indentation is important for things to render properly. -->

   {{< tabs name="serving_networking" default="Istio" >}}
   {{% tab name="Ambassador" %}}

The following commands install Ambassador and enable its Knative integration.

1. Create a namespace to install Ambassador in:

   ```bash
   kubectl create namespace ambassador
   ```

1. Install Ambassador:

   ```bash
   kubectl apply --namespace ambassador \
     -f https://getambassador.io/yaml/ambassador/ambassador-crds.yaml \
     -f https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml \
     -f https://getambassador.io/yaml/ambassador/ambassador-service.yaml
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

The following commands install Contour and enable its Knative integration.

1. Install a properly configured Contour:

   ```bash
   kubectl apply -f {{< artifact repo="net-contour" file="contour.yaml" >}}
   ```

   <!-- TODO(https://github.com/knative-sandbox/net-contour/issues/11): We need a guide on how to use/modify a pre-existing install. -->

1. Install the Knative Contour controller:

   ```bash
   kubectl apply -f {{< artifact repo="net-contour" file="net-contour.yaml" >}}
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

_For a detailed guide on Gloo integration, see
[Installing Gloo for Knative](https://docs.solo.io/gloo/latest/installation/knative/)
in the Gloo documentation._

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

   Or following the
   [Gloo CLI install instructions](https://docs.solo.io/gloo/latest/installation/knative/#install-command-line-tool-cli).

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

The following commands install Istio and enable its Knative integration.

1. Install a properly configured Istio ([Advanced installation](./installing-istio.md))

   ```bash
   kubectl apply -f {{< artifact repo="net-istio" file="istio.yaml" >}}
   ```


1. Install the Knative Istio controller:

   ```bash
   kubectl apply -f {{< artifact repo="net-istio" file="net-istio.yaml" >}}
   ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace istio-system get service istio-ingressgateway
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Kong" %}}

The following commands install Kong and enable its Knative integration.

1. Install Kong Ingress Controller:

   ```bash
   kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/0.9.x/deploy/single/all-in-one-dbless.yaml
   ```

1. To configure Knative Serving to use Kong by default:

   ```bash
   kubectl patch configmap/config-network \
     --namespace knative-serving \
     --type merge \
     --patch '{"data":{"ingress.class":"kong"}}'
   ```

1. Fetch the External IP or CNAME:

   ```bash
   kubectl --namespace kong get service kong-proxy
   ```

   Save this for configuring DNS below.

{{< /tab >}}

{{% tab name="Kourier" %}}

The following commands install Kourier and enable its Knative integration.

1. Install the Knative Kourier controller:

   ```bash
   kubectl apply -f {{< artifact repo="net-kourier" file="kourier.yaml" >}}
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

{{< /tab >}} {{< /tabs >}}

### Configuring DNS

      <!-- This indentation is important for things to render properly. -->

   {{< tabs name="serving_dns" default="Magic DNS (xip.io)" >}}
   {{% tab name="Magic DNS (xip.io)" %}}

We ship a simple Kubernetes Job called "default domain" that will (see caveats)
configure Knative Serving to use <a href="http://xip.io">xip.io</a> as the
default DNS suffix.

```bash
kubectl apply -f {{< artifact repo="serving" file="serving-default-domain.yaml" >}}
```

**Caveat**: This will only work if the cluster LoadBalancer service exposes an
IPv4 address or hostname, so it will not work with IPv6 clusters or local setups
like Minikube. For these, see "Real DNS" or "Temporary DNS".

{{< /tab >}}

{{% tab name="Real DNS" %}}

To configure DNS for Knative, take the External IP
or CNAME from setting up networking, and configure it with your DNS provider as
follows:

- If the networking layer produced an External IP address, then configure a
  wildcard `A` record for the domain:

  ```
  # Here knative.example.com is the domain suffix for your cluster
  *.knative.example.com == A 35.233.41.212
  ```

- If the networking layer produced a CNAME, then configure a CNAME record for
  the domain:

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

{{% tab name="Temporary DNS" %}}

If you are using `curl` to access the sample
applications, or your own Knative app, and are unable to use the "Magic DNS
(xip.io)" or "Real DNS" methods, there is a temporary approach. This is useful
for those who wish to evaluate Knative without altering their DNS configuration,
as per the "Real DNS" method, or cannot use the "Magic DNS" method due to using,
for example, minikube locally or IPv6 clusters.

To access your application using `curl` using this method:

1. After starting your application, get the URL of your application:

   ```bash
   kubectl get ksvc
   ```

   The output should be similar to:

   ```bash
   NAME            URL                                        LATESTCREATED         LATESTREADY           READY   REASON
   helloworld-go   http://helloworld-go.default.example.com   helloworld-go-vqjlf   helloworld-go-vqjlf   True
   ```

1. Instruct `curl` to connect to the External IP or CNAME defined by the
   networking layer in section 3 above, and use the `-H "Host:"` command-line
   option to specify the Knative application's host name. For example, if the
   networking layer defines your External IP and port to be
   `http://192.168.39.228:32198` and you wish to access the above
   `helloworld-go` application, use:

   ```bash
   curl -H "Host: helloworld-go.default.example.com" http://192.168.39.228:32198
   ```

   In the case of the provided `helloworld-go` sample application, the output
   should, using the default configuration, be:

   ```
   Hello Go Sample v1!
   ```

Refer to the "Real DNS" method for a permanent solution.

{{< /tab >}} {{< /tabs >}}

1. Monitor the Knative components until all of the components show a `STATUS` of
   `Running` or `Completed`:

   ```bash
   kubectl get pods --namespace knative-serving
   ```

At this point, you have a basic installation of Knative Serving!

### Optional Serving extensions

{{< tabs name="serving_extensions" default="TLS via HTTP01" >}}

{{% tab name="HPA autoscaling" %}}

Knative also supports the use of the Kubernetes Horizontal Pod Autoscaler (HPA)
for driving autoscaling decisions. The following command will install the
components needed to support HPA-class autoscaling:

```bash
kubectl apply -f {{< artifact repo="serving" file="serving-hpa.yaml" >}}
```

<!-- TODO(https://github.com/knative/docs/issues/2152): Link to a more in-depth guide on HPA-class autoscaling -->

{{< /tab >}}

{{% tab name="TLS with cert-manager" %}}

Knative supports automatically provisioning TLS certificates via
[cert-manager](https://cert-manager.io/docs/). The following commands will
install the components needed to support the provisioning of TLS certificates
via cert-manager.

1. First, install
   [cert-manager version `0.12.0` or higher](../serving/installing-cert-manager.md)

2. Next, install the component that integrates Knative with cert-manager:

   ```bash
   kubectl apply -f {{< artifact repo="net-certmanager" file="release.yaml" >}}
   ```

3. Now configure Knative to
   [automatically configure TLS certificates](../serving/using-auto-tls.md).
   {{< /tab >}}

{{% tab name="TLS via HTTP01" %}}

Knative supports automatically provisioning TLS certificates using Let's Encrypt
HTTP01 challenges. The following commands will install the components needed to
support that.

1. First, install the `net-http01` controller:

   ```bash
   kubectl apply -f {{< artifact repo="net-http01" file="release.yaml" >}}
   ```

2. Next, configure the `certificate.class` to use this certificate type.

   ```bash
   kubectl patch configmap/config-network \
     --namespace knative-serving \
     --type merge \
     --patch '{"data":{"certificate.class":"net-http01.certificate.networking.knative.dev"}}'
   ```

3. Lastly, enable auto-TLS.

   ```bash
   kubectl patch configmap/config-network \
     --namespace knative-serving \
     --type merge \
     --patch '{"data":{"autoTLS":"Enabled"}}'
   ```

{{< /tab >}}

{{% tab name="TLS wildcard support" %}}

If you are using a Certificate implementation that supports provisioning
wildcard certificates (e.g. cert-manager with a DNS01 issuer), then the most
efficient way to provision certificates is with the namespace wildcard
certificate controller. The following command will install the components needed
to provision wildcard certificates in each namespace:

```bash
kubectl apply -f {{< artifact repo="serving" file="serving-nscert.yaml" >}}
```

> Note this will not work with HTTP01 either via cert-manager or the net-http01
> options.

{{< /tab >}}

{{% tab name="DomainMapping CRD" %}}

The `DomainMapping` CRD allows a user to map a Domain Name that they own to a
specific Knative Service.

```bash
kubectl apply -f {{< artifact repo="serving" file="serving-domainmapping-crds.yaml" >}}
kubectl wait --for=condition=Established --all crd
kubectl apply -f {{< artifact repo="serving" file="serving-domainmapping.yaml" >}}
```

{{< /tab >}} {{< /tabs >}}

## Installing the Eventing component

1. Install the required custom resources:

   ```bash
   kubectl apply -f {{< artifact repo="eventing" file="eventing-crds.yaml" >}}
   ```

1. Install the core components of Eventing (see below for optional extensions):

   ```bash
   kubectl apply -f {{< artifact repo="eventing" file="eventing-core.yaml" >}}
   ```

### Installing a Default Channel (Messaging) Layer (Listed Alphabetically).

      <!-- This indentation is important for things to render properly. -->

   {{< tabs name="eventing_channels" default="In-Memory (standalone)" >}}
   {{% tab name="Apache Kafka Channel" %}}

1. First,
   [Install Apache Kafka for Kubernetes](../eventing/samples/kafka/README.md)

1. Then install the Apache Kafka Channel:

   ```bash
   curl -L "{{< artifact org="knative-sandbox" repo="eventing-kafka" file="channel-consolidated.yaml" >}}" \
    | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
    | kubectl apply -f -
   ```

To learn more about the Apache Kafka channel, try
[our sample](../eventing/samples/kafka/channel/README.md)

{{< /tab >}}

{{% tab name="Google Cloud Pub/Sub Channel" %}}

1. Install the Google Cloud Pub/Sub Channel:

   ```bash
   # This installs both the Channel and the GCP Sources.
   kubectl apply -f {{< artifact org="google" repo="knative-gcp" file="cloud-run-events.yaml" >}}
   ```

To learn more about the Google Cloud Pub/Sub Channel, try
[our sample](https://github.com/google/knative-gcp/blob/master/docs/examples/channel/README.md)

{{< /tab >}}

{{% tab name="In-Memory (standalone)" %}}

The following command installs an implementation of Channel that runs in-memory.
This implementation is nice because it is simple and standalone, but it is
unsuitable for production use cases.

```bash
kubectl apply -f {{< artifact repo="eventing" file="in-memory-channel.yaml" >}}
```

{{< /tab >}}

{{% tab name="NATS Channel" %}}

1. First, [Install NATS Streaming for
   Kubernetes](https://github.com/knative-sandbox/eventing-natss/tree/master/config)

1. Then install the NATS Streaming Channel:

   ```bash
   kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-natss" file="300-natss-channel.yaml" >}}
   ```

{{< /tab >}}

<!-- TODO(https://github.com/knative/docs/issues/2153): Add more Channels here -->

{{< /tabs >}}

### Installing a Broker (Eventing) Layer:

      <!-- This indentation is important for things to render properly. -->
   {{< tabs name="eventing_brokers" default="MT-Channel-based" >}}
   {{% tab name="Apache Kafka Broker" %}}

The following commands install the Apache Kafka broker, and run event routing in a system namespace,
`knative-eventing`, by default.

1. Install the Kafka controller by entering the following command:

    ```bash
    kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-controller.yaml" >}}
    ```

1. Install the Kafka Broker data plane by entering the following command:

    ```bash
    kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-broker.yaml" >}}
    ```

For more information, see the [Kafka Broker](./../eventing/broker/kafka-broker.md) documentation.
{{< /tab >}}

   {{% tab name="MT-Channel-based" %}}

The following command installs an implementation of Broker that utilizes
Channels and runs event routing components in a System Namespace, providing a
smaller and simpler installation.

```bash
kubectl apply -f {{< artifact repo="eventing" file="mt-channel-broker.yaml" >}}
```

To customize which broker channel implementation is used, update the following
ConfigMap to specify which configurations are used for which namespaces:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    # This is the cluster-wide default broker channel.
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: imc-channel
      namespace: knative-eventing
    # This allows you to specify different defaults per-namespace,
    # in this case the "some-namespace" namespace will use the Kafka
    # channel ConfigMap by default (only for example, you will need
    # to install kafka also to make use of this).
    namespaceDefaults:
      some-namespace:
        brokerClass: MTChannelBasedBroker
        apiVersion: v1
        kind: ConfigMap
        name: kafka-channel
        namespace: knative-eventing
```

The referenced `imc-channel` and `kafka-channel` example ConfigMaps would look
like:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: imc-channel
  namespace: knative-eventing
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-channel
  namespace: knative-eventing
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1alpha1
    kind: KafkaChannel
    spec:
      numPartitions: 3
      replicationFactor: 1
```

_In order to use the KafkaChannel make sure it is installed on the cluster as
discussed above._

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

{{% tab name="Apache Kafka Sink" %}}

1. Install the Kafka controller:

    ```bash
    kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-controller.yaml" >}}
    ```

1. Install the Kafka Sink data plane:

    ```bash
    kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-sink.yaml" >}}
    ```

For more information, see the [Kafka Sink](./../eventing/sink/kafka-sink.md) documentation.

{{< /tab >}}

{{% tab name="Sugar Controller" %}}

<!-- Unclear when this feature came in -->

The following command installs the Eventing Sugar Controller:

```bash
kubectl apply -f {{< artifact repo="eventing" file="eventing-sugar-controller.yaml" >}}
```

The Knative Eventing Sugar Controller will react to special labels and
annotations and produce Eventing resources. For example:

- When a Namespace is labeled with `eventing.knative.dev/injection=enabled`, the
  controller will create a default broker in that namespace.
- When a Trigger is annotated with `eventing.knative.dev/injection=enabled`, the
  controller will create a Broker named by that Trigger in the Trigger's
  Namespace.

The following command enables the default Broker on a namespace (here
`default`):

```bash
kubectl label namespace default eventing.knative.dev/injection=enabled
```

{{< /tab >}}

{{% tab name="Github Source" %}}

The following command installs the single-tenant Github source:

```bash
kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-github" file="github.yaml" >}}
```

The single-tenant GitHub source creates one Knative service per GitHub source.

The following command installs the multi-tenant GitHub source:

```bash
kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-github" file="mt-github.yaml" >}}
```

The multi-tenant GitHub source creates only one Knative service handling all
GitHub sources in the cluster. This source does not support logging or tracing
configuration yet.

To learn more about the Github source, try
[our sample](../eventing/samples/github-source/README.md)

{{< /tab >}}

{{% tab name="Apache Camel-K Source" %}}

The following command installs the Apache Camel-K Source:

```bash
kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-camel" file="camel.yaml" >}}
```

To learn more about the Apache Camel-K source, try
[our sample](../eventing/samples/apache-camel-source/README.md)

{{< /tab >}}

{{% tab name="Apache Kafka Source" %}}

The following command installs the Apache Kafka Source:

```bash
kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-kafka" file="source.yaml" >}}
```

To learn more about the Apache Kafka source, try
[our sample](../eventing/samples/kafka/source/README.md)

{{< /tab >}}

{{% tab name="GCP Sources" %}}

The following command installs the GCP Sources:

```bash
# This installs both the Sources and the Channel.
kubectl apply -f {{< artifact org="google" repo="knative-gcp" file="cloud-run-events.yaml" >}}
```

To learn more about the Cloud Pub/Sub source, try
[our sample](../eventing/samples/cloud-pubsub-source/README.md).

To learn more about the Cloud Storage source, try
[our sample](../eventing/samples/cloud-storage-source/README.md).

To learn more about the Cloud Scheduler source, try
[our sample](../eventing/samples/cloud-scheduler-source/README.md).

To learn more about the Cloud Audit Logs source, try
[our sample](../eventing/samples/cloud-audit-logs-source/README.md).

{{< /tab >}}

{{% tab name="Apache CouchDB Source" %}}

The following command installs the Apache CouchDB Source:

```bash
kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-couchdb" file="couchdb.yaml" >}}
```

To learn more about the Apache CouchDB source, read the [documentation](https://github.com/knative-sandbox/eventing-couchdb/blob/master/source/README.md).

{{< /tab >}}

{{% tab name="VMware Sources and Bindings" %}}

The following command installs the VMware Sources and Bindings:

```bash
kubectl apply -f {{< artifact org="vmware-tanzu" repo="sources-for-knative" file="release.yaml" >}}
```

To learn more about the VMware sources and bindings, try
[our samples](https://github.com/vmware-tanzu/sources-for-knative/tree/master/samples/README.md).

{{< /tab >}}

{{< /tabs >}}
