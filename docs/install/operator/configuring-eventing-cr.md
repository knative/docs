# Configuring the Eventing Operator custom resource

You can configure the Knative Eventing operator by modifying settings in the `KnativeEventing` custom resource (CR).

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

   You can also run the following commands to make the equivalent change:

    ```bash
    kn operator configure images --component eventing --imageKey default --imageURL docker.io/knative-images/${NAME}:latest -n knative-eventing
    kn operator configure images --component eventing --deployName broker-controller --imageKey eventing-controller --imageURL docker.io/knative-images-repo1/broker-eventing-controller:latest -n knative-eventing
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

You can also run the following commands to make the equivalent change:

```bash
kn operator configure images --component eventing --deployName eventing-controller --imageKey eventing-controller --imageURL docker.io/knative-images-repo1/eventing-controller:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --deployName eventing-webhook --imageKey eventing-webhook --imageURL docker.io/knative-images-repo2/eventing-webhook:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --deployName imc-controller --imageKey controller --imageURL docker.io/knative-images-repo3/imc-controller:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --deployName imc-dispatcher --imageKey dispatcher --imageURL docker.io/knative-images-repo4/imc-dispatcher:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --deployName broker-controller --imageKey eventing-controller --imageURL docker.io/knative-images-repo5/broker-eventing-controller:latest -n knative-eventing
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

You can also run the following commands to make the equivalent change:

```bash
kn operator configure images --component eventing --deployName eventing-controller --imageKey eventing-controller --imageURL docker.io/knative-images-repo1/eventing-controller:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --deployName eventing-webhook --imageKey eventing-webhook --imageURL docker.io/knative-images-repo2/eventing-webhook:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --deployName imc-controller --imageKey controller --imageURL docker.io/knative-images-repo3/imc-controller:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --deployName imc-dispatcher --imageKey dispatcher --imageURL docker.io/knative-images-repo4/imc-dispatcher:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --deployName broker-controller --imageKey eventing-controller --imageURL docker.io/knative-images-repo5/broker-eventing-controller:latest -n knative-eventing
```

```bash
kn operator configure images --component eventing --imageKey DISPATCHER_IMAGE -controller --imageURL docker.io/knative-images-repo5/DISPATCHER_IMAGE:latest -n knative-eventing
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
        memory: 100M
      limits:
        cpu: 1000m
        memory: 250M
```

You can also run the following command to make the equivalent change:

```bash
kn operator configure resources --component eventing --deployName eventing-controller --container eventing-controller --requestCPU 300m --requestMemory 100M --limitCPU 1000m --limitMemory 250M -n knative-eventing
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

You can also run the following command to make the equivalent change:

```bash
kn operator configure nodeSelector --component eventing --deployName eventing-controller --key disktype --value hdd -n knative-eventing
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

You can also run the following command to make the equivalent change:

```bash
kn operator configure tolerations --component eventing --deployName eventing-controller --key key1 --operator Equal --value value1 --effect NoSchedule -n knative-eventing
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

### Override the environment variables

The KnativeEventing resource is able to override or add the environment variables for the containers in the Knative Eventing
deployment resources. For example, if you would like to change the value of environment variable `METRICS_DOMAIN` in the
container `eventing-controller` into "knative.dev/my-repo" for the deployment `eventing-controller`, you need to change
your KnativeEventing CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  deployments:
  - name: eventing-controller
    env:
    - container: eventing-controller
      envVars:
      - name: METRICS_DOMAIN
        value: "knative.dev/my-repo"
```

You can also run the following command to make the equivalent change:

```bash
kn operator configure envvars --component eventing --deployName eventing-controller --container eventing-controller --name METRICS_DOMAIN --value "knative.dev/my-repo" -n knative-eventing
```

## Override system services

If you would like to override some configurations for a specific service, you can override the configuration by using `spec.services` in CR.
Currently `labels`, `annotations` and `selector` are supported.

### Override labels and annotations and selector

The following KnativeEventing resource overrides the `eventing-webhook` service to have the label `mylabel: foo`, the annotation `myannotations: bar`,
the selector `myselector: bar`.

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  services:
  - name: eventing-webhook
    labels:
      mylabel: foo
    annotations:
      myannotations: bar
    selector:
      myselector: bar
```

You can also run the following commands to make the equivalent change:

```bash
kn operator configure labels --component eventing --serviceName eventing-webhook --key mylabel --value foo -n knative-eventing
kn operator configure annotations --component eventing --serviceName eventing-webhook --key myannotations --value bar -n knative-eventing
kn operator configure selectors --component eventing --serviceName eventing-webhook --key myselector --value bar -n knative-eventing
```

## Override system podDisruptionBudgets

A Pod Disruption Budget (PDB) allows you to limit the disruption to your application when its pods need to be rescheduled
for maintenance reasons. Knative Operator allows you to configure the `minAvailable` for a specific podDisruptionBudget
resource in Eventing based on the name. To understand more about the configuration of the resource podDisruptionBudget, click [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/).
For example, if you would like to change `minAvailable` into 70% for the podDisruptionBudget named `eventing-webhook`,
you need to change your KnativeEventing CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  podDisruptionBudgets:
  - name: eventing-webhook
    minAvailable: 70%
```
