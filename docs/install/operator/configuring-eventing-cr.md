# Configuring the Eventing Operator custom resource

You can configure the Knative Eventing operator by modifying settings in the KnativeEventing custom resource (CR).
You can configure Knative Eventing with the following options:

- [Installing a specific version of Eventing](#installing-a-specific-version-of-eventing)
- [Installing customized Knative Eventing](#installing-customized-knative-eventing)
- [Setting a default channel](#setting-a-default-channel)
- [Setting the default channel for the broker](#setting-the-default-channel-for-the-broker)
- [Private repository and private secrets](#private-repository-and-private-secrets)
- [Download images in a predefined format without secrets](#download-images-in-a-predefined-format-without-secrets)
- [Download images from different repositories without secrets](#download-images-from-different-repositories-without-secrets)
- [Download images with secrets](#download-images-with-secrets)
- [Configuring the default broker class](#configuring-the-default-broker-class)
- [Override system deployments](#override-system-deployments)

## Installing a specific version of Eventing

Cluster administrators can install a specific version of Knative Eventing by using the `spec.version` field. For example,
if you want to install Knative Eventing v0.19.0, you can apply the following KnativeEventing CR:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: 0.19.0
```

If `spec.version` is not specified, the Knative Operator will install the latest available version of Knative Eventing.
If users specify an invalid or unavailable version, the Knative Operator will do nothing. The Knative Operator always
includes the latest 3 minor release versions.

If Knative Eventing is already managed by the Operator, updating the `spec.version` field in the KnativeEventing CR enables upgrading or downgrading the Knative Eventing version, without requiring modifications to the Operator.

Note that the Knative Operator only permits upgrades or downgrades by one minor release version at a time. For example,
if the current Knative Eventing deployment is version 0.18.x, you must upgrade to 0.19.x before upgrading to 0.20.x.

## Installing customized Knative Eventing

The Operator provides you with the flexibility to install Knative Eventing customized to your own requirements.
As long as the manifests of customized Knative Eventing are accessible to the Operator, you can install them.

There are two modes available for you to install customized manifests: _overwrite mode_ and _append mode_.
With overwrite mode, under `.spec.manifests`, you must define all manifests needed for Knative Eventing
to install because the Operator will no longer install any default manifests.
With append mode, under `.spec.additionalManifests`, you only need to define your customized manifests.
The customized manifests are installed after default manifests are applied.

### Overwrite mode

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

### Append mode

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

## Setting a default channel

If you are using different channel implementations, like the KafkaChannel, or you want a specific configuration of the InMemoryChannel to be the default configuration, you can change the default behavior by updating the `default-ch-webhook` ConfigMap.

You can do this by modifying the KnativeEventing CR:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  config:
    default-ch-webhook:
      default-ch-config: |
        clusterDefault:
          apiVersion: messaging.knative.dev/v1beta1
          kind: KafkaChannel
          spec:
            numPartitions: 10
            replicationFactor: 1
        namespaceDefaults:
          my-namespace:
            apiVersion: messaging.knative.dev/v1
            kind: InMemoryChannel
            spec:
              delivery:
                backoffDelay: PT0.5S
                backoffPolicy: exponential
                retry: 5
```

!!! note
    The `clusterDefault` setting determines the global, cluster-wide default channel type. You can configure channel defaults for individual namespaces by using the `namespaceDefaults` setting.

## Setting the default channel for the broker

If you are using a channel-based broker, you can change the default channel type for the broker from InMemoryChannel to KafkaChannel, by updating the `config-br-default-channel` ConfigMap.

You can do this by modifying the KnativeEventing CR:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  config:
    config-br-default-channel:
      channel-template-spec: |
        apiVersion: messaging.knative.dev/v1beta1
        kind: KafkaChannel
        spec:
          numPartitions: 6
          replicationFactor: 1
```

## Private repository and private secrets

The Knative Eventing Operator CR is configured the same way as the Knative Serving Operator CR.
See the documentation on [Private repository and private secret](configuring-serving-cr.md#private-repository-and-private-secrets).

Knative Eventing also specifies only one container within each Deployment resource. However, the container does not use
the same name as its parent Deployment, which means that the container name in Knative Eventing is not the same unique identifier
as it is in Knative Serving.

List of containers within each Deployment resource:

| Component | Deployment name | Container name |
|-----------|-----------------|----------------|
| Core eventing | `eventing-controller` | `eventing-controller` |
| Core eventing | `eventing-webhook` | `eventing-webhook` |
| Eventing Broker | `broker-controller` | `eventing-controller` |
| In-Memory Channel | `imc-controller` | `controller` |
| In-Memory Channel | `imc-dispatcher` | `dispatcher` |

The `default` field can still be used to replace the images in a predefined format. However, if the container name is not
a unique identifier, for example `eventing-controller`, you must use the `override` field to replace it, by specifying
`deployment/container` as the unique key.

Some images are defined by using the environment variable in Knative Eventing. They can be replaced by taking advantage of the
`override` field.

### Download images in a predefined format without secrets

This example shows how you can define custom image links that can be defined in the KnativeEventing CR using the simplified format
`docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

In this example:

- The custom tag `latest` is used for all images.
- All image links are accessible without using secrets.
- Images are defined in the accepted format `docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

To define your image links:

1. Push images to the following image tags:

    | Deployment | Container | Docker image |
    |----|----|----|
    | `eventing-controller` | `eventing-controller` | `docker.io/knative-images/eventing-controller:latest` |
    |  | `eventing-webhook` | `docker.io/knative-images/eventing-webhook:latest` |
    | `broker-controller` | `eventing-controller` | `docker.io/knative-images/broker-eventing-controller:latest` |
    |  | `controller` | `docker.io/knative-images/controller:latest` |
    |  | `dispatcher` | `docker.io/knative-images/dispatcher:latest` |

2. Define your KnativeEventing CR with following content:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeEventing
    metadata:
      name: knative-eventing
      namespace: knative-eventing
    spec:
      registry:
        default: docker.io/knative-images/${NAME}:latest
        override:
          broker-controller/eventing-controller: docker.io/knative-images-repo1/broker-eventing-controller:latest
    ```

    - `${NAME}` maps to the container name in each `Deployment` resource.
    - `default` is used to define the image format for all containers, except the container `eventing-controller` in the deployment `broker-controller`. To replace the image for this container, use the `override`
    field to specify individually, by using `broker-controller/eventing-controller` as the key.
<!-- TODO: check that this is still relevant, I don't see default in this example?-->

### Download images from different repositories without secrets

If your custom image links are not defined in a uniform format, you will need to individually include each link in the KnativeEventing CR.

For example, given the following list of images:

| Deployment | Container | Docker Image |
|----|----|----|
| `eventing-controller` | `eventing-controller` | `docker.io/knative-images-repo1/eventing-controller:latest` |
|  | `eventing-webhook` | `docker.io/knative-images-repo2/eventing-webhook:latest` |
|  | `controller` | `docker.io/knative-images-repo3/imc-controller:latest` |
|  | `dispatcher` | `docker.io/knative-images-repo4/imc-dispatcher:latest` |
| `broker-controller` | `eventing-controller` | `docker.io/knative-images-repo5/broker-eventing-controller:latest` |

You must modify the KnativeEventing CR to include the full list. For example:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  registry:
    override:
      eventing-controller/eventing-controller: docker.io/knative-images-repo1/eventing-controller:latest
      eventing-webhook/eventing-webhook: docker.io/knative-images-repo2/eventing-webhook:latest
      imc-controller/controller: docker.io/knative-images-repo3/imc-controller:latest
      imc-dispatcher/dispatcher: docker.io/knative-images-repo4/imc-dispatcher:latest
      broker-controller/eventing-controller: docker.io/knative-images-repo5/broker-eventing-controller:latest
```

If you want to replace the image defined by the environment variable, you must modify the KnativeEventing CR.
For example, if you want to replace the image defined by the environment variable `DISPATCHER_IMAGE`, in the container `controller`, of the deployment `imc-controller`, and the target image is `docker.io/knative-images-repo5/DISPATCHER_IMAGE:latest`, the KnativeEventing CR would be as follows:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  registry:
    override:
      eventing-controller/eventing-controller: docker.io/knative-images-repo1/eventing-controller:latest
      eventing-webhook/eventing-webhook: docker.io/knative-images-repo2/eventing-webhook:latest
      imc-controller/controller: docker.io/knative-images-repo3/imc-controller:latest
      imc-dispatcher/dispatcher: docker.io/knative-images-repo4/imc-dispatcher:latest
      broker-controller/eventing-controller: docker.io/knative-images-repo5/broker-eventing-controller:latest
      DISPATCHER_IMAGE: docker.io/knative-images-repo5/DISPATCHER_IMAGE:latest
```

### Download images with secrets

If your image repository requires private secrets for access, you must append the `imagePullSecrets` attribute to the KnativeEventing CR.

This example uses a secret named `regcred`. Refer to the [Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod) to create your own private secrets.

After you create the secret, edit the KnativeEventing CR:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  registry:
    ...
    imagePullSecrets:
      - name: regcred
```

The field `imagePullSecrets` requires a list of secrets. You can add multiple secrets to access the images:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  registry:
    ...
    imagePullSecrets:
      - name: regcred
      - name: regcred-2
      ...
```

## Configuring the default broker class

Knative Eventing allows you to define a default broker class when the user does not specify one.
The Operator provides two broker classes by default: ChannelBasedBroker and MTChannelBasedBroker.

The field `defaultBrokerClass` indicates which class to use; if empty, the ChannelBasedBroker is used.

The following example CR specifies MTChannelBasedBroker as the default:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  defaultBrokerClass: MTChannelBasedBroker
```

## Override system deployments

If you would like to override some configurations for a specific deployment, you can override the configuration by using `spec.deployments` in the CR.
Currently `resources`, `replicas`, `labels`, `annotations` and `nodeSelector` are supported.

### Override the resources

The KnativeEventing custom resource is able to configure system resources for the Knative system containers based on the deployment.
Requests and limits can be configured for all the available containers within the deployment, like `eventing-controller`, `eventing-webhook`,
`imc-controller`, etc.

For example, the following KnativeEventing resource configures the container `eventing-controller` in the deployment `eventing-controller` to request
0.3 CPU and 100MB of RAM, and sets hard limits of 1 CPU and 250MB RAM:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  deployments:
  - name: eventing-controller
    resources:
    - container: eventing-controller
      requests:
        cpu: 300m
        memory: 100Mi
      limits:
        cpu: 1000m
        memory: 250Mi
```

### Override the nodeSelector

The KnativeEventing resource is able to override the nodeSelector for the Knative Eventing deployment resources.
For example, if you would like to add the following tolerations

```yaml
nodeSelector:
  disktype: hdd
```

to the deployment `eventing-controller`, you need to change your KnativeEventing CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  deployments:
  - name: eventing-controller
    nodeSelector:
      disktype: hdd
```

### Override the tolerations

The KnativeEventing resource is able to override tolerations for the Knative Eventing deployment resources.
For example, if you would like to add the following tolerations

```yaml
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
```

to the deployment `eventing-controller`, you need to change your KnativeEventing CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  deployments:
  - name: eventing-controller
    tolerations:
    - key: "key1"
      operator: "Equal"
      value: "value1"
      effect: "NoSchedule"
```

### Override the affinity

The KnativeEventing resource is able to override the affinity, including nodeAffinity, podAffinity, and podAntiAffinity,
for the Knative Eventing deployment resources. For example, if you would like to add the following nodeAffinity

```yaml
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      preference:
        matchExpressions:
        - key: disktype
          operator: In
          values:
          - ssd
```

to the deployment `activator`, you need to change your KnativeEventing CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  deployments:
  - name: activator
    affinity:
      nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          preference:
            matchExpressions:
            - key: disktype
              operator: In
              values:
              - ssd
```
