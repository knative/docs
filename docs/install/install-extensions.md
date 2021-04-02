---
title: "Installing optional extensions"
linkTitle: "Install optional extensions"
weight: 04
type: "docs"
showlandingtoc: "false"
---

To add extra features to your Knative Serving or Eventing installation, you can install extensions
by applying YAML files using the `kubectl` CLI.

For information about the YAML files in the Knative Serving and Eventing releases, see
[Installation files](./installation-files.md).


# Prerequisites

Before you install any optional extensions, you must install Knative Serving or Eventing.
See [Installing Serving using YAML files](./install-serving-with-yaml.md)
and [Installing Eventing using YAML files](./install-eventing-with-yaml.md).


## Install optional Serving extensions

The tabs below expand to show instructions for installing each Serving extension.

{{< tabs name="serving_extensions" >}}

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


## Install optional Eventing extensions

The tabs below expand to show instructions for installing each Eventing extension.
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

To learn more about the Apache CouchDB source, read the [documentation](https://github.com/knative-sandbox/eventing-couchdb/blob/main/source/README.md).

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
