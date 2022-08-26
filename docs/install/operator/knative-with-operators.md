# Advanced Operator installation options

## Track the log

To track the log of the Operator, run the command:

```bash
kubectl logs -f deploy/knative-operator
```

## Install the networking layer

Knative Operator can configure the Knative Serving component with different network layer options.
Istio is the default network layer if the ingress is not specified in the
Knative Serving CR. If you choose to use the default Istio network layer, you must install Istio on your cluster.
Because of this, you might find it easier to configure Kourier as your networking layer.

Click on each of the following tabs to see how you can configure
Knative Serving with different ingresses:

=== "Kourier (Choose this if you are not sure)"

    The following steps install Kourier and enable its Knative integration:

    1. To configure Knative Serving to use Kourier, add `spec.ingress.kourier` and
    `spec.config.network` to your Serving CR YAML file as follows:

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

    1. Apply the YAML file for your Serving CR by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of your Serving CR file.

    1. Fetch the External IP or CNAME by running the command:

        ```bash
        kubectl --namespace knative-serving get service kourier
        ```

        Save this for configuring DNS later.

=== "Istio (default)"

    The following steps install Istio to enable its Knative integration:

    1. [Install Istio](../installing-istio.md).

    1. If you installed Istio under a namespace other than the default `istio-system`:
        1. Add `spec.config.istio` to your Serving CR YAML file as follows:

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
                  local-gateway.<local-gateway-namespace>.knative-local-gateway: "knative-local-gateway.<istio-namespace>.svc.cluster.local"
            ```

            Where:

            - `<local-gateway-namespace>` is the local gateway namespace, which is the same as Knative Serving namespace `knative-serving`.
            - `<istio-namespace>` is the namespace where Istio is installed.

        1. Apply the YAML file for your Serving CR by running the command:

            ```bash
            kubectl apply -f <filename>.yaml
            ```

            Where `<filename>` is the name of your Serving CR file.

    1. Fetch the External IP or CNAME by running the command:

        ```bash
        kubectl get svc istio-ingressgateway -n <istio-namespace>
        ```

        Save this for configuring DNS later.

=== "Contour"

    The following steps install Contour and enable its Knative integration:

    1. Install a properly configured Contour:

        ```bash
        kubectl apply --filename {{artifact(repo="net-contour",file="contour.yaml")}}
        ```

    1. To configure Knative Serving to use Contour, add `spec.ingress.contour`
    `spec.config.network` to your Serving CR YAML file as follows:

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

    1. Apply the YAML file for your Serving CR by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of your Serving CR file.

    1. Fetch the External IP or CNAME by running the command:

        ```bash
        kubectl --namespace contour-external get service envoy
        ```

        Save this for configuring DNS later.

<!-- These are snippets from the docs/snippets directory -->
{% include "dns.md" %}
{% include "real-dns-operator.md" %}
{% include "temporary-dns.md" %}

## Installing a specific version of Eventing

Cluster administrators can install a specific version of Knative Eventing by using the `spec.version` field. For example, if you want to install Knative Eventing v1.6, you can apply the following KnativeEventing CR:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: "1.6"
```

You can also run the following command to make the equivalent change:

```bash
kn operator install --component eventing -v 1.6 -n knative-eventing
```

If `spec.version` is not specified, the Knative Operator installs the latest available version of Knative Eventing.
If users specify an invalid or unavailable version, the Knative Operator will do nothing. The Knative Operator always
includes the latest 3 minor release versions.

If Knative Eventing is already managed by the Operator, updating the `spec.version` field in the KnativeEventing CR enables upgrading or downgrading the Knative Eventing version, without requiring modifications to the Operator.

Note that the Knative Operator only permits upgrades or downgrades by one minor release version at a time. For example, if the current Knative Eventing deployment is version 1.4, you must upgrade to 1.5 before upgrading to 1.6.

### Installing customized Knative Eventing

The Operator provides you with the flexibility to install Knative Eventing customized to your own requirements.
As long as the manifests of customized Knative Eventing are accessible to the Operator, you can install them.

There are two modes available for you to install customized manifests: _overwrite mode_ and _append mode_.
With overwrite mode, under `.spec.manifests`, you must define all manifests needed for Knative Eventing
to install because the Operator will no longer install any default manifests.
With append mode, under `.spec.additionalManifests`, you only need to define your customized manifests.
The customized manifests are installed after default manifests are applied.

#### Overwrite mode

Use overwrite mode when you want to customize all Knative Eventing manifests to be installed.

For example, if you want to install a customized Knative Eventing only, you can create and apply the following
Eventing CR:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: knative-eventing
---
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: $spec_version
  manifests:
  - URL: https://my-eventing/eventing.yaml
```

This example installs the customized Knative Eventing at version `$spec_version` which is available at
`https://my-eventing/eventing.yaml`.

!!! attention
    You can make the customized Knative Eventing available in one or multiple links, as the `spec.manifests` supports a list of links.
    The ordering of the URLs is critical. Put the manifest you want to apply first on the top.

We strongly recommend you to specify the version and the valid links to the customized Knative Eventing, by leveraging
both `spec.version` and `spec.manifests`. Do not skip either field.

#### Append mode

You can use append mode to add your customized manifests into the default manifests.

For example, if you only want to customize a few resources but you still want to install the default Knative Eventing,
you can create and apply the following Eventing CR:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: knative-eventing
---
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: $spec_version
  additionalManifests:
  - URL: https://my-eventing/eventing-custom.yaml
```

This example installs the default Knative Eventing, and installs your customized resources available at
`https://my-eventing/eventing-custom.yaml`.

Knative Operator installs the default manifests of Knative Eventing at the version `$spec_version`, and then
installs your customized manifests based on them.

### Installing Knative Eventing with event sources

Knative Operator can configure the Knative Eventing component with different event sources.
Click on each of the following tabs to
see how you can configure Knative Eventing with different event sources:

=== "Ceph"

    To configure Knative Eventing to install Ceph as the event source:

    1. Add `spec.source.ceph` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            ceph:
              enabled: true
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "GitHub"

    To configure Knative Eventing to install GitHub as the event source:

    1. Add `spec.source.github` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            github:
              enabled: true
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "GitLab"

    To configure Knative Eventing to install GitLab as the event source:

    1. Add `spec.source.gitlab` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            gitlab:
              enabled: true
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "Apache Kafka"

    To configure Knative Eventing to install Kafka as the event source:

    1. Add `spec.source.kafka` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            kafka:
              enabled: true
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "RabbitMQ"

    To configure Knative Eventing to install RabbitMQ as the event source,

    1. Add `spec.source.rabbitmq` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            rabbitmq:
              enabled: true
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "Redis"

    To configure Knative Eventing to install Redis as the event source:

    1. Add `spec.source.redis` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            redis:
              enabled: true
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

## What's next

- [Configure Knative Serving using Operator](configuring-serving-cr.md)
- [Configure Knative Eventing using Operator](configuring-eventing-cr.md)
