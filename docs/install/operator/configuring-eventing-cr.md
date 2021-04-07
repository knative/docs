---
title: "Configuring the Eventing Operator custom resource"
weight: 60
type: "docs"
aliases:
- /docs/operator/configuring-eventing-cr/
---

You can configure the Knative Eventing operator by modifying settings in the KnativeEventing custom resource (CR).

**NOTE:** Kubernetes spec level policies cannot be configured using the Knative Operators.

<!--TODO: break this into sub sections like for the channels sections, i.e. a page per topic-->

## Installing a specific version of Eventing

Cluster administrators can install a specific version of Knative Eventing by using the `spec.version` field. For example,
if you want to install Knative Eventing v0.19.0, you can apply the following KnativeEventing CR:

```yaml
apiVersion: operator.knative.dev/v1alpha1
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

## Configuring Knative Eventing using ConfigMaps

The Operator manages the Knative Eventing installation. It overwrites any updates to ConfigMaps which are used to configure Knative Eventing.
The KnativeEventing CR allows you to set values for these ConfigMaps by using the Operator.

All Knative Eventing ConfigMaps are created in the same namespace as the KnativeEventing CR. You can use the KnativeEventing CR as a unique entry point to edit all ConfigMaps.

Knative Eventing has multiple ConfigMaps that are named with the prefix `config-`.
The `spec.config` in the KnativeEventing CR has one `<name>` entry for each ConfigMap, named `config-<name>`, with a value which will be used for the ConfigMap `data`.

### Setting a default channel

If you are using different channel implementations, like the KafkaChannel, or you want a specific configuration of the InMemoryChannel to be default you can change the default behavior by updating the `default-ch-webhook` ConfigMap. You can do this by modifying the KnativeEventing CR:

```yaml
apiVersion: operator.knative.dev/v1alpha1
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

**NOTE:** The `clusterDefault` setting determines the global, cluster-wide default channel type. You can configure channel defaults for individual namespaces by using the `namespaceDefaults` setting.

### Setting the default channel for the broker

If you are using a channel-based broker, you can change the default channel type for the broker from InMemoryChannel to KafkaChannel, by updating the `config-br-default-channel` ConfigMap. You can do this by modifying the KnativeEventing CR:

```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  config:
    config-br-default-channel:
      channelTemplateSpec: |
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

In the example below:

- The custom tag `latest` is used for all images.
- All image links are accessible without using secrets.
- Images are defined in the accepted format `docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

1. Push images to the following image tags:

  | Deployment | Container | Docker image |
  |----|----|----|
  | `eventing-controller` | `eventing-controller` | `docker.io/knative-images/eventing-controller:latest` |
  |  | `eventing-webhook` | `docker.io/knative-images/eventing-webhook:latest` |
  | `broker-controller` | `eventing-controller` | `docker.io/knative-images/broker-eventing-controller:latest` |
  |  | `controller` | `docker.io/knative-images/controller:latest` |
  |  | `dispatcher` | `docker.io/knative-images/dispatcher:latest` |

2. Define your the KnativeEventing CR with following content:

  ```yaml
  apiVersion: operator.knative.dev/v1alpha1
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

For example, to define the following list of images:

| Deployment | Container | Docker Image |
|----|----|----|
| `eventing-controller` | `eventing-controller` | `docker.io/knative-images/eventing-controller:latest` |
|  | `eventing-webhook` | `docker.io/knative-images/eventing-webhook:latest` |
|  | `controller` | `docker.io/knative-images/controller:latest` |
|  | `dispatcher` | `docker.io/knative-images/dispatcher:latest` |
| `broker-controller` | `eventing-controller` | `docker.io/knative-images/broker-eventing-controller:latest` |

The KnativeEventing CR must be modified to include the full list. For example:

```yaml
apiVersion: operator.knative.dev/v1alpha1
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
apiVersion: operator.knative.dev/v1alpha1
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
apiVersion: operator.knative.dev/v1alpha1
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
apiVersion: operator.knative.dev/v1alpha1
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
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  defaultBrokerClass: MTChannelBasedBroker
```

## System resource settings

The KnativeEventing CR allows you to configure system resources for Knative system containers.

Requests and limits can be configured for the following containers:

- `eventing-controller`
- `eventing-webhook`
- `imc-controller`
- `imc-dispatcher`
- `mt-broker-ingress`
- `mt-broker-ingress`
- `mt-broker-controller`

To override resource settings for a specific container, you must create an entry in the `spec.resources` list with the container name and the [Kubernetes resource settings](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container).

For example, the following KnativeEventing CR configures the `eventing-webhook` container to request 0.3 CPU and 100MB of RAM, and sets hard limits of 1 CPU, 250MB RAM, and 4GB of local storage:

```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  resources:
  - container: eventing-webhook
    requests:
      cpu: 300m
      memory: 100Mi
    limits:
      cpu: 1000m
      memory: 250Mi
```
