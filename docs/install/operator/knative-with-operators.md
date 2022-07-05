# Install by using the Knative Operator

Knative provides a [Kubernetes Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) to install, configure and manage Knative.
You can install the Serving component, Eventing component, or both on your cluster.

The following table describes the supported versions of Serving and Eventing for the Knative Operator:

| Operator             | Serving                                                                                                       | Eventing                                                                                                                 |
|----------------------|---------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| v1.5.0               | v1.5.0<br/>v1.4.0<br/>v1.3.0, v1.3.1 and v1.3.2<br/>v1.2.0, v1.2.1, v1.2.2, v1.2.3, v1.2.4 and v1.2.5 | v1.5.0<br/>v1.4.0 and v1.4.1<br/>v1.3.0, v1.3.1, v1.3.2 and v1.3.3<br/>v1.2.0, v1.2.1, v1.2.2 and v1.2.3 |

--8<-- "prerequisites.md"

## Install the Knative Operator

Before you install the Knative Serving and Eventing components, first install the Knative Operator.

### Install the latest Knative Operator release

To install the latest stable Operator release, run the command:

```bash
kubectl apply -f {{artifact(org="knative",repo="operator",file="operator.yaml" )}}
```

You can find information about the released versions of the Knative Operator on the [releases page](https://github.com/knative/operator/releases).

### Verify your Knative Operator installation

1. Because the Operator is installed to the `default` namespace, ensure you set the current namespace to `default` by running the command:

    ```bash
    kubectl config set-context --current --namespace=default
    ```

1. Check the Operator deployment status by running the command:

    ```bash
    kubectl get deployment knative-operator
    ```

    If the Operator is installed correctly, the deployment shows a `Ready` status:

    ```{.bash .no-copy}
    NAME               READY   UP-TO-DATE   AVAILABLE   AGE
    knative-operator   1/1     1            1           19h
    ```

### Track the log

To track the log of the Operator, run the command:

```bash
kubectl logs -f deploy/knative-operator
```

### Upgrade the existing custom resources

If you are upgrading an existing Operator install from v1.2 or earlier to v1.3 or later, run the following command
to upgrade the existing custom resources to `v1beta1`:

```bash
kubectl create -f {{artifact(org="knative",repo="operator",file="operator-post-install.yaml" )}}
```

## Installing the Knative Serving component

To install Knative Serving you must create a custom resource (CR), add a networking
layer to the CR, and configure DNS.

### Create the Knative Serving custom resource

To create the custom resource for the latest available Knative Serving in the Operator:

1. Copy the following YAML into a file:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-serving
    ---
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    ```
    !!! note
        When you don't specify a version by using `spec.version` field, the Operator defaults to the latest available version.

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

### Install the networking layer

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

### Verify the Knative Serving deployment

1. Monitor the Knative deployments:

    ```bash
    kubectl get deployment -n knative-serving
    ```

    If Knative Serving has been successfully deployed, all deployments of the
    Knative Serving will show `READY` status. Here is a sample output:

    ```{ .bash .no-copy }
    NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
    activator              1/1     1            1           18s
    autoscaler             1/1     1            1           18s
    autoscaler-hpa         1/1     1            1           14s
    controller             1/1     1            1           18s
    domain-mapping         1/1     1            1           12s
    domainmapping-webhook  1/1     1            1           12s
    webhook                1/1     1            1           17s
    ```

1. Check the status of Knative Serving Custom Resource:

    ```bash
    kubectl get KnativeServing knative-serving -n knative-serving
    ```

    If Knative Serving is successfully installed, you should see:

    ```{ .bash .no-copy }
    NAME              VERSION             READY   REASON
    knative-serving   <version number>    True
    ```

<!-- These are snippets from the docs/snippets directory -->
{% include "dns.md" %}
{% include "real-dns-operator.md" %}
{% include "temporary-dns.md" %}

## Installing the Knative Eventing component

To install Knative Eventing you must apply the custom resource (CR).
Optionally, you can install the Knative Eventing component with different event sources.

### Create the Knative Eventing custom resource

To create the custom resource for the latest available Knative Eventing in the Operator:

1. Copy the following YAML into a file:

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
    ```

    !!! note
        When you do not specify a version by using `spec.version` field, the Operator defaults to the latest available version.

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

Where `<filename>` is the name of the file you created in the previous step.

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

=== "Apache CouchDB"

    To configure Knative Eventing to install Apache CouchDB as the event source:

    1. Add `spec.source.couchdb` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            couchdb:
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

=== "NATS Streaming"

    To configure Knative Eventing to install NATS Streaming as the event source:

    1. Add `spec.source.natss` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            natss:
              enabled: true
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "Prometheus"

    To configure Knative Eventing to install Prometheus as the event source:

    1. Add `spec.source.prometheus` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1beta1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          # ...
          source:
            prometheus:
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

### Verify the Knative Eventing deployment

1. Monitor the Knative deployments:

    ```bash
    kubectl get deployment -n knative-eventing
    ```

    If Knative Eventing has been successfully deployed, all deployments of the
    Knative Eventing will show `READY` status. Here is a sample output:

    ```{.bash .no-copy}
    NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
    eventing-controller     1/1     1            1           43s
    eventing-webhook        1/1     1            1           42s
    imc-controller          1/1     1            1           39s
    imc-dispatcher          1/1     1            1           38s
    mt-broker-controller    1/1     1            1           36s
    mt-broker-filter        1/1     1            1           37s
    mt-broker-ingress       1/1     1            1           37s
    pingsource-mt-adapter   0/0     0            0           43s
    sugar-controller        1/1     1            1           36s
    ```

1. Check the status of Knative Eventing Custom Resource:

    ```bash
    kubectl get KnativeEventing knative-eventing -n knative-eventing
    ```

    If Knative Eventing is successfully installed, you should see:

    ```{.bash .no-copy}
    NAME               VERSION             READY   REASON
    knative-eventing   <version number>    True
    ```

## Uninstalling Knative

Knative Operator prevents unsafe removal of Knative resources. Even if the Knative Serving and Knative Eventing CRs are
successfully removed, all the CRDs in Knative are still kept in the cluster. All your resources relying on Knative CRDs
can still work.

### Removing the Knative Serving component

To remove the Knative Serving CR run the command:

```bash
kubectl delete KnativeServing knative-serving -n knative-serving
```

### Removing Knative Eventing component

To remove the Knative Eventing CR run the command:

```bash
kubectl delete KnativeEventing knative-eventing -n knative-eventing
```

### Removing the Knative Operator:

If you have installed Knative using the release page, remove the operator by running the command:

```bash
kubectl delete -f {{artifact(org="knative",repo="operator",file="operator.yaml")}}
```

If you have installed Knative from source, uninstall it using the following command while in the root directory
for the source:

```bash
ko delete -f config/
```

## What's next

- [Configure Knative Serving using Operator](configuring-serving-cr.md)
- [Configure Knative Eventing using Operator](configuring-eventing-cr.md)
