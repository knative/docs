# Knative Operator installation

Knative provides a [Kubernetes Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) to install, configure and manage Knative.
You can install the Serving component, Eventing component, or both on your cluster.

!!! warning
    The Knative Operator is still in Alpha phase. It has not been tested in a production environment, and should be used for development or test purposes only.

--8<-- "prerequisites.md"

## Installing the latest release

You can find information about the different released versions of the Knative Operator on the [Releases page](https://github.com/knative/operator/releases).

Install the latest stable Operator release:

```
kubectl apply -f {{artifact(org="knative",repo="operator",file="operator.yaml" )}}
```

## Verify your installation

Verify your installation:

```
kubectl get deployment knative-operator
```

If the operator is installed correctly, the deployment shows a `Ready` status:

```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
knative-operator   1/1     1            1           19h
```

## Track the log

Track the log of the operator:

```
kubectl logs -f deploy/knative-operator
```

## Installing the Knative Serving component

### Create and apply the Knative Serving CR:

!!! note "Install Current Serving"

    === "Install Current Serving (default)"

        You can install the latest available Knative Serving in the
        operator by applying a YAML file containing the following:

        ```
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

        If you do not specify a version by using spec_version, the operator defaults to the latest available version.

    === "Install Future Knative Serving"

        You do not need to upgrade the operator to a newer version to install
        new releases of Knative Serving. If Knative Serving launches a new version, e.g. `$spec_version`, you can install it by
        applying a YAML file containing the following:

        ```
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
            - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-core.yaml
            - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-hpa.yaml
            - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-post-install-jobs.yaml
            - URL: https://github.com/knative/net-istio/releases/download/v${VERSION}/net-istio.yaml
        ```

        The field `$spec_version` is used to set the version of Knative Serving. Replace `$spec_version` with the correct version number.
        The tag `${VERSION}` is automatically replaced with the version number from `spec_version` by the operator.

        The field `spec.manifests` is used to specify one or multiple URL links of Knative Serving component. Do not forget to
        add the valid URL of the Knative network ingress plugin. Knative Serving component is still tightly-coupled with a network
        ingress plugin in the operator. As in the above example, you can use `net-istio`. The ordering of the URLs is critical.
        Put the manifest you want to apply first on the top.

    === "Install Customized Knative Serving"

        The operator provides you the flexibility to install customized
        Knative Serving based your own requirements. As long as the manifests of customized Knative Serving are accessible to
        the operator, they can be installed.

        There are two modes available for you to install the customized manifests: overwrite mode and append mode. With the
        overwrite mode, you need to define all the manifests for Knative Serving to install, because the operator will no long
        install any available default manifests. With the append mode, you only need to define your customized manifests, and
        the customized manifests are installed, after default manifests are applied.

        1. You can use the overwrite mode to customize all the Knative Serving manifests. For example, the version of the customized
        Knative Serving is `$spec_version`, and it is available at `https://my-serving/serving.yaml`. You choose `net-istio`
        as the ingress plugin, which is available at `https://my-net-istio/net-istio.yaml`. You can create the content of Serving
        CR as below to install your Knative Serving and the istio ingress:
        ```
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

        You can make the customized Knative Serving available in one or multiple links, as the `spec.manifests` supports a list
        of links. The ordering of the URLs is critical. Put the manifest you want to apply first on the top. We strongly recommend
        you to specify the version and the valid links to the customized Knative Serving, by leveraging both `spec_version`
        and `spec.manifests`. Do not skip either field.

        1. You can use the append mode to add your customized manifests into the default manifests. For example, you only customize
        a few resources, and make them available at `https://my-serving/serving-custom.yaml`. You still need to install the default
        Knative Serving. In this case, you can create the content of Serving CR as below:
        ```
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

        Knative operator will install the default manifests of Knative Serving at the version `$spec_version`, and then install
        your customized manifests based on them.

### Verify the Knative Serving deployment:

1. Monitor the Knative deployments:
```
kubectl get deployment -n knative-serving
```
If Knative Serving has been successfully deployed, all deployments of the Knative Serving will show `READY` status. Here
is a sample output:
```
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
activator              1/1     1            1           18s
autoscaler             1/1     1            1           18s
autoscaler-hpa         1/1     1            1           14s
controller             1/1     1            1           18s
net-istio-webhook      1/1     1            1           12s
net-istio-controller   1/1     1            1           12s
webhook                1/1     1            1           17s
```

1. Check the status of Knative Serving Custom Resource:
```
kubectl get KnativeServing knative-serving -n knative-serving
```
If Knative Serving is successfully installed, you should see:
```
NAME              VERSION             READY   REASON
knative-serving   <version number>    True
```

### Installing with Different Networking Layers

??? "Installing the Knative Serving component with different network layers"

    Knative Operator can configure Knative Serving component with different network layer options. Istio is the default network
    layer, if the ingress is not specified in the Knative Serving CR. Click on each tab below to see how you can configure
    Knative Serving with different ingresses:

    === "Ambassador"

        The following commands install Ambassador and enable its Knative integration.

        1. Create a namespace to install Ambassador in:
          ```bash
          kubectl create namespace ambassador
          ```

        1. Install Ambassador:
          ```bash
          kubectl apply --namespace ambassador \
            --filename https://getambassador.io/yaml/ambassador/ambassador-crds.yaml \
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

        1. To configure Knative Serving to use Ambassador, apply the content of the Serving CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeServing
          metadata:
            name: knative-serving
            namespace: knative-serving
          spec:
            config:
              network:
                ingress.class: "ambassador.ingress.networking.knative.dev"
          EOF
          ```

        1. Fetch the External IP or CNAME:
          ```bash
          kubectl --namespace ambassador get service ambassador
          ```

          Save this for configuring DNS below.

    === "Contour"

        The following commands install Contour and enable its Knative integration.

        1. Install a properly configured Contour:
          ```bash
          kubectl apply --filename {{artifact(repo="net-contour",file="contour.yaml")}}
          ```

        1. To configure Knative Serving to use Contour, apply the content of the Serving CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeServing
          metadata:
            name: knative-serving
            namespace: knative-serving
          spec:
            ingress:
              contour:
                enabled: true
            config:
              network:
                ingress.class: "contour.ingress.networking.knative.dev"
          EOF
          ```

        1. Fetch the External IP or CNAME:
          ```bash
          kubectl --namespace contour-external get service envoy
          ```

          Save this for configuring DNS below.

    === "Kourier"

        The following commands install Kourier and enable its Knative integration.

        1. To configure Knative Serving to use Kourier, apply the content of the Serving CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeServing
          metadata:
            name: knative-serving
            namespace: knative-serving
          spec:
            ingress:
              kourier:
                enabled: true
            config:
              network:
                ingress.class: "kourier.ingress.networking.knative.dev"
          EOF
          ```

        1. Fetch the External IP or CNAME:
          ```bash
          kubectl --namespace knative-serving get service kourier
          ```

          Save this for configuring DNS below.

{% include "dns.md" %}

## Installing the Knative Eventing component

1. Create and apply the Knative Eventing CR:

    You can install the latest available Knative Eventing in the
    operator by applying a YAML file containing the following:

    === "Install Current Evenintg (default)"

        ```
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

        If you do not specify a version by using spec.version, the operator defaults to the latest available version.

    === "Install Future Knative Eventing"

        You do not need to upgrade the operator to a newer version to install
        new releases of Knative Eventing. If Knative Eventing launches a new version, e.g. `$spec_version`, you can install it by
        applying a YAML file containing the following:

        ```
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
            - URL: https://github.com/knative/eventing/releases/download/v${VERSION}/eventing.yaml
            - URL: https://github.com/knative/eventing/releases/download/v${VERSION}/eventing-post-install-jobs.yaml
        ```

        The field `spec.version` is used to set the version of Knative Eventing. Replace `$spec_version` with the correct version number.
        The tag `${VERSION}` is automatically replaced with the version number from `spec.version` by the operator.

        The field `spec.manifests` is used to specify one or multiple URL links of Knative Eventing component. Do not forget to
        add the valid URL of the Knative network ingress plugin. The ordering of the URLs is critical. Put the manifest you want
        to apply first on the top.

    === "Install Customized Knative Evening"

        The operator provides you the flexibility to install customized
        Knative Eventing based your own requirements. As long as the manifests of customized Knative Eventing are accessible to
        the operator, they can be installed.

        There are two modes available for you to install the customized manifests: overwrite mode and append mode. With the
        overwrite mode, you need to define all the manifests for Knative Eventing to install, because the operator will no long
        install any available default manifests. With the append mode, you only need to define your customized manifests, and
        the customized manifests are installed, after default manifests are applied.

        1. You can use the overwrite mode to customize all the Knative Eventing manifests. For example, the version of the customized
          Knative Eventing is `$spec_version`, and it is available at `https://my-eventing/eventing.yaml`. You can create the
          content of Eventing CR as below to install your Knative Eventing:

        ```
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

        You can make the customized Knative Eventing available in one or multiple links, as the `spec.manifests` supports a list
        of links. The ordering of the URLs is critical. Put the manifest you want to apply first on the top. We strongly recommend
        you to specify the version and the valid links to the customized Knative Eventing, by leveraging both `spec.version`
        and `spec.manifests`. Do not skip either field.

        1. You can use the append mode to add your customized manifests into the default manifests. For example, you only customize
          a few resources, and make them available at `https://my-eventing/eventing-custom.yaml`. You still need to install the default
          Knative eventing. In this case, you can create the content of Eventing CR as below:

        ```
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

        Knative operator will install the default manifests of Knative Eventing at the version `$spec_version`, and then install
        your customized manifests based on them.

### Verify the Knative Eventing deployment:

```
kubectl get deployment -n knative-eventing
```

If Knative Eventing has been successfully deployed, all deployments of the Knative Eventing will show `READY` status. Here
is a sample output:

```
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
broker-controller      1/1     1            1           63s
broker-filter          1/1     1            1           62s
broker-ingress         1/1     1            1           62s
eventing-controller    1/1     1            1           67s
eventing-webhook       1/1     1            1           67s
imc-controller         1/1     1            1           59s
imc-dispatcher         1/1     1            1           59s
mt-broker-controller   1/1     1            1           62s
```

### Check the status of Knative Eventing Custom Resource:

```
kubectl get KnativeEventing knative-eventing -n knative-eventing
```

If Knative Eventing is successfully installed, you should see:

```
NAME               VERSION             READY   REASON
knative-eventing   <version number>    True
```

### Installing with Different Eventing Sources

??? "Installing the Knative Eventing component with different eventing sources"

    Knative Operator can configure Knative Eventing component with different eveting sources. Click on each tab below to
    see how you can configure Knative Eventing with different eventing sources:

    === "Ceph"

        To configure Knative Eventing to install Ceph as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              ceph:
                enabled: true
          EOF
          ```

    === "Apache CouchDB"

        To configure Knative Eventing to install Apache CouchDB as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              couchdb:
                enabled: true
          EOF
          ```

    === "GitHub"

        To configure Knative Eventing to install GitHub as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              github:
                enabled: true
          EOF
          ```

    === "GitLab"

        To configure Knative Eventing to install GitLab as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              gitlab:
                enabled: true
          EOF
          ```

    === "Apache Kafka"

        To configure Knative Eventing to install GitLab as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              kafka:
                enabled: true
          EOF
          ```

    === "NATS Streaming"

        To configure Knative Eventing to install NATS Streaming as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              natss:
                enabled: true
          EOF
          ```

    === "Prometheus"

        To configure Knative Eventing to install Prometheus as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              prometheus:
                enabled: true
          EOF
          ```

    === "RabbitMQ"

        To configure Knative Eventing to install RabbitMQ as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              rabbitmq:
                enabled: true
          EOF
          ```

    === "Redis"

        To configure Knative Eventing to install Redis as the eventing source, apply the content of the Eventing CR as below:
          ```bash
          cat <<-EOF | kubectl apply -f -
          apiVersion: operator.knative.dev/v1alpha1
          kind: KnativeEventing
          metadata:
            name: knative-eventing
            namespace: knative-eventing
          spec:
            source:
              redis:
                enabled: true
          EOF
          ```

## Uninstall Knative

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

Knative operator prevents unsafe removal of Knative resources. Even if the Knative Serving and Knative Eventing CRs are
successfully removed, all the CRDs in Knative are still kept in the cluster. All your resources relying on Knative CRDs
can still work.

### Removing the Knative Operator:

If you have installed Knative using the Release page, remove the operator using the following command:

```
kubectl delete -f {{artifact(org="knative",repo="operator",file="operator.yaml")}}
```

If you have installed Knative from source, uninstall it using the following command while in the root directory
for the source:

```
ko delete -f config/
```

## What's next

- [Configure Knative Serving using Operator](./operator/configuring-serving-cr.md)
- [Configure Knative Eventing using Operator](./operator/configuring-eventing-cr.md)
