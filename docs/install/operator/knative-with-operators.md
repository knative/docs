# Installing Knative using the Operator

Knative provides a [Kubernetes Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) to install, configure and manage Knative.
You can install the Serving component, Eventing component, or both on your cluster.

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

## Installing the Knative Serving component

To install Knative Serving you must create a custom resource (CR), add a networking
layer to the CR, and configure DNS.

### Create the Knative Serving custom resource

=== "Install the current version (default)"

    To create the custom resource for the latest available Knative Serving in the Operator:

    1. Copy the following YAML into a file:

        ```yaml
        apiVersion: v1
        kind: Namespace
        metadata:
          name: knative-serving
        ---
        apiVersion: operator.knative.dev/v1alpha1
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

=== "Install another version of Knative Serving"

    You can install a new release of Knative Serving without upgrading the Operator.
    To install a new version of Knative Serving:

    1. Create a YAML file containing the following:

        ```yaml
        apiVersion: v1
        kind: Namespace
        metadata:
          name: knative-serving
        ---
        apiVersion: operator.knative.dev/v1alpha1
        kind: KnativeServing
        metadata:
          name: knative-serving
          namespace: knative-serving
        spec:
          version: "<new-version>"
          manifests:
            - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-core.yaml
            - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-hpa.yaml
            - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-post-install-jobs.yaml
            - URL: https://github.com/knative/net-istio/releases/download/v${VERSION}/net-istio.yaml
        ```
        <!-- I'm not sure why you need to apply these manifests here, don't these install by default? -->

        Where `<new-version>` is the Knative version you want to use, for example `1.0`. This field is used to set the version of Knative Serving and to automatically replace the tag `${VERSION}`.

        !!! attention
            The field `spec.manifests` is used to specify one or multiple URL links
            of the Knative Serving component.
            The ordering of the URLs is critical. Put the manifest you want to apply first on the top.

            You must add a valid URL of the Knative network ingress plugin. You can use `net-istio`.
            Knative Serving component is tightly-coupled with a network ingress plugin in the Operator.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "Install customized Knative Serving"

    The Operator provides you with the flexibility to install Knative Serving
    customized to your own requirements.
    As long as the manifests of customized Knative Serving are accessible to
    the Operator, you can install them.

    There are two modes available for you to install customized manifests:
    _overwrite mode_ and _append mode_.
    With overwrite mode, you must define all manifests needed for Knative Serving
    to install because the Operator will no longer install any default manifests.
    With append mode, you only need to define your customized manifests.
    The customized manifests are installed after default manifests are applied.

    **Overwrite mode:**

    You can use overwrite mode when you want to customize all Knative Serving manifests.

    For example, if you want to install Knative Serving and istio ingress and you
    want customize both components, you can create the following YAML file:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-serving
    ---
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      version: $spec_version
      manifests:
        - URL: https://my-serving/serving.yaml
        - URL: https://my-net-istio/net-istio.yaml
    ```

    This example installs the customized Knative Serving at version `$spec_version`
    which is available at `https://my-serving/serving.yaml`, and the customized ingress plugin `net-istio`
    which is available at `https://my-net-istio/net-istio.yaml`.

    !!! attention
        You can make the customized Knative Serving available in one or multiple links, as the `spec.manifests` supports a list of links.
        The ordering of the URLs is critical. Put the manifest you want to apply first on the top.

        We strongly recommend you to specify the version and the valid links to the
        customized Knative Serving, by leveraging both `spec_version` and `spec.manifests`.
        Do not skip either field.

    **Append mode:**

    You can use append mode to add your customized manifests into the default manifests.

    For example, if you only want to customize a few resources but you still want
    to install the default Knative Serving, you can create the following YAML file:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-serving
    ---
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      version: $spec_version
      additionalManifests:
        - URL: https://my-serving/serving-custom.yaml
    ```

    This example installs the default Knative Serving, and installs
    your customized resources available at `https://my-serving/serving-custom.yaml`.

    Knative Operator installs the default manifests of Knative Serving at the
    version `$spec_version`, and then installs your customized manifests based on them.

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
        apiVersion: operator.knative.dev/v1alpha1
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
            apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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

=== "Install the current version (default)"

    To create the custom resource for the latest available Knative Eventing in the Operator:

    1. Copy the following YAML into a file:

        ```yaml
        apiVersion: v1
        kind: Namespace
        metadata:
          name: knative-eventing
        ---
        apiVersion: operator.knative.dev/v1alpha1
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

=== "Install another version of Knative Eventing"

    You can install a new release of Knative Eventing without upgrading the Operator.
    To install a new version of Knative Eventing:

    1. Create a YAML file containing the following:

        ```yaml
        apiVersion: v1
        kind: Namespace
        metadata:
          name: knative-eventing
        ---
        apiVersion: operator.knative.dev/v1alpha1
        kind: KnativeEventing
        metadata:
          name: knative-eventing
          namespace: knative-eventing
        spec:
          version: "<new-version>"
          manifests:
            - URL: https://github.com/knative/eventing/releases/download/v${VERSION}/eventing.yaml
            - URL: https://github.com/knative/eventing/releases/download/v${VERSION}/eventing-post-install-jobs.yaml
        ```
        Where `<new-version>` is the Knative version you want to use, for example `1.0`. This field is used to set the version of Knative Eventing and to automatically replace the tag `${VERSION}`.
        !!! attention
            The field `spec.manifests` is used to specify one or multiple URL links
            of the Knative Serving component.
            The ordering of the URLs is critical. Put the manifest you want to apply first on the top.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "Install customized Knative Eventing"

    The Operator provides you with the flexibility to install Knative Eventing
    customized to your own requirements.
    As long as the manifests of customized Knative Eventing are accessible to
    the Operator, you can install them.

    There are two modes available for you to install customized manifests:
    _overwrite mode_ and _append mode_.
    With overwrite mode, you must define all manifests needed for Knative Eventing
    to install because the Operator will no longer install any default manifests.
    With append mode, you only need to define your customized manifests.
    The customized manifests are installed after default manifests are applied.

    **Overwrite mode:**

    Use overwrite mode when you want to customize all Knative Eventing manifests to be installed.

    For example, if you want to install a customized Knative Eventing only,
    you can create and apply the following Eventing CR:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-eventing
    ---
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeEventing
    metadata:
      name: knative-eventing
      namespace: knative-eventing
    spec:
      version: $spec_version
      manifests:
        - URL: https://my-eventing/eventing.yaml
    ```

    This example installs the customized Knative Eventing at version `$spec_version`
    which is available at `https://my-eventing/eventing.yaml`.

    !!! attention
        You can make the customized Knative Eventing available in one or multiple links, as the `spec.manifests` supports a list of links.
        The ordering of the URLs is critical. Put the manifest you want to apply first on the top.

        We strongly recommend you to specify the version and the valid links to the
        customized Knative Eventing, by leveraging both `spec.version` and `spec.manifests`.
        Do not skip either field.

    **Append mode:**

    You can use append mode to add your customized manifests into the default manifests.

    For example, if you only want to customize a few resources but you still want
    to install the default Knative Eventing,
    you can create and apply the following Eventing CR:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-eventing
    ---
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeEventing
    metadata:
      name: knative-eventing
      namespace: knative-eventing
    spec:
      version: $spec_version
      additionalManifests:
        - URL: https://my-eventing/eventing-custom.yaml
    ```

    This example installs the default Knative Eventing, and installs your customized
    resources available at `https://my-eventing/eventing-custom.yaml`.

    Knative Operator installs the default manifests of Knative Eventing at the
    version `$spec_version`, and then installs your customized manifests based on them.

### Installing Knative Eventing with event sources

Knative Operator can configure the Knative Eventing component with different event sources.
Click on each of the following tabs to
see how you can configure Knative Eventing with different event sources:

=== "Ceph"

    To configure Knative Eventing to install Ceph as the event source:

    1. Add `spec.source.ceph` to your Eventing CR YAML file as follows:

        ```yaml
        apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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
        apiVersion: operator.knative.dev/v1alpha1
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
