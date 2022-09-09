# Configuring the Knative Serving Operator custom resource

You can modify the KnativeServing CR to configure different options for Knative Serving.

## Configure the Knative Serving version

Cluster administrators can install a specific version of Knative Serving by using the `spec.version` field.

For example, if you want to install Knative Serving v1.5, you can apply the following `KnativeServing` custom resource:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: "1.5"
```

You can also run the following command to make the equivalent change:

```bash
kn operator install --component serving -v 1.5 -n knative-serving
```

If `spec.version` is not specified, the Knative Operator installs the latest available version of Knative Serving.

If users specify an invalid or unavailable version, the Knative Operator does nothing.

The Knative Operator always includes the latest 3 release versions. For example, if the current version of the Knative Operator is v1.5, the earliest version of Knative Serving available through the Operator is v1.2.

If Knative Serving is already managed by the Operator, updating the `spec.version` field in the `KnativeServing` resource enables upgrading or downgrading the Knative Serving version, without needing to change the Operator.

!!! important
    The Knative Operator only permits upgrades or downgrades by one minor release version at a time. For example, if the current Knative Serving deployment is version v1.3, you must upgrade to v1.4 before upgrading to v1.5.

## Install customized Knative Serving

There are two modes available that you can use to install customized Knative Serving manifests: _overwrite mode_ and _append mode_.

If you are using overwrite mode, under `.spec.manifests`, you must define all required manifests to install Knative Serving, because the Operator does not install any default manifests.

If you are using append mode, under `.spec.additionalManifests`, you only need to define your customized manifests. The customized manifests are installed after default manifests are applied.

### Overwrite mode

You can use overwrite mode when you want to customize all Knative Serving manifests.

!!! important
    You must specify both the version and valid URLs for your custom Knative Serving manifests.

For example, if you want to install customized versions of both Knative Serving and the Istio ingress, you can create a `KnativeServing` CR similar to the following example:

```yaml
apiVersion: operator.knative.dev/v1beta1
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

You can make the customized Knative Serving available in one or multiple links, as the `spec.manifests` supports a list of links.

!!! important
    The ordering of manifest URLs is critical. Put the manifest you want to apply first at the top of the list.

This example installs the customized Knative Serving at version `$spec_version` which is available at `https://my-serving/serving.yaml`, and the customized ingress plugin `net-istio` which is available at `https://my-net-istio/net-istio.yaml`.

### Append mode

You can use append mode to add your customized Knative Serving manifests in addition to the default manifests.

For example, if you only want to customize a few resources but you still want to install the default Knative Serving, you can create a `KnativeServing` CR similar to the following example:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: $spec_version
  additionalManifests:
  - URL: https://my-serving/serving-custom.yaml
```

This example installs the default Knative Serving manifests, and then installs the customized resources available at `https://my-serving/serving-custom.yaml` for the version `$spec_version`.

## Private repository and private secrets

You can use the `spec.registry` section of the Operator CR to change the image references to point to a private registry or [specify imagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod):

- `default`: this field defines a image reference template for all Knative images. The format
is `example-registry.io/custom/path/${NAME}:{CUSTOM-TAG}`. If you use the same tag for all your images, the only difference is the image name. `${NAME}` is
a pre-defined variable in the operator corresponding to the container name. If you name the images in your private repo to align with the container names (
`activator`, `autoscaler`, `controller`, `webhook`, `autoscaler-hpa`, `net-istio-controller`, and `queue-proxy`), the `default` argument should be sufficient.

- `override`: a map from container name to the full registry
location. This section is only needed when the registry images do not match the common naming format. For containers whose name matches a key, the value is used in preference to the image name calculated by `default`. If a container's name does not match a key in `override`, the template in `default` is used.

- `imagePullSecrets`: a list of Secret names used when pulling Knative container images. The Secrets
must be created in the same namespace as the Knative Serving Deployments. See
[deploying images from a private container registry](../../serving/deploying-from-private-registry.md) for configuration details.

### Download images in a predefined format without secrets

This example shows how you can define custom image links that can be defined in the CR using the simplified format
`docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

In the following example:

- The custom tag `latest` is used for all images.
- All image links are accessible without using secrets.
- Images are pushed as `docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

To define your image links:

1. Push images to the following image tags:

    | Container | Docker Image |
    |----|----|
    |`activator` | `docker.io/knative-images/activator:latest` |
    | `autoscaler` | `docker.io/knative-images/autoscaler:latest` |
    | `controller` | `docker.io/knative-images/controller:latest` |
    | `webhook` | `docker.io/knative-images/webhook:latest` |
    | `autoscaler-hpa` | `docker.io/knative-images/autoscaler-hpa:latest` |
    | `net-istio-controller` | `docker.io/knative-images/net-istio-controller:latest` |
    | `queue-proxy` | `docker.io/knative-images/queue-proxy:latest` |

2. Define your operator CR with following content:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      registry:
        default: docker.io/knative-images/${NAME}:latest
    ```

   You can also run the following command to make the equivalent change:

    ```bash
    kn operator configure images --component serving --imageKey default --imageURL docker.io/knative-images/${NAME}:latest -n knative-serving
    ```

### Download images individually without secrets

If your custom image links are not defined in a uniform format by default, you will need to individually include each
link in the CR.

For example, given the following images:

| Container | Docker Image |
|----|----|
| `activator` | `docker.io/knative-images-repo1/activator:latest` |
| `autoscaler` | `docker.io/knative-images-repo2/autoscaler:latest` |
| `controller` | `docker.io/knative-images-repo3/controller:latest` |
| `webhook` | `docker.io/knative-images-repo4/webhook:latest` |
| `autoscaler-hpa` | `docker.io/knative-images-repo5/autoscaler-hpa:latest` |
| `net-istio-controller` | `docker.io/knative-images-repo6/prefix-net-istio-controller:latest` |
| `net-istio-webhook` | `docker.io/knative-images-repo6/net-istio-webhooko:latest` |
| `queue-proxy` | `docker.io/knative-images-repo7/queue-proxy-suffix:latest` |

You must modify the Operator CR to include the full list. For example:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    override:
      activator: docker.io/knative-images-repo1/activator:latest
      autoscaler: docker.io/knative-images-repo2/autoscaler:latest
      controller: docker.io/knative-images-repo3/controller:latest
      webhook: docker.io/knative-images-repo4/webhook:latest
      autoscaler-hpa: docker.io/knative-images-repo5/autoscaler-hpa:latest
      net-istio-controller/controller: docker.io/knative-images-repo6/prefix-net-istio-controller:latest
      net-istio-webhook/webhook: docker.io/knative-images-repo6/net-istio-webhook:latest
      queue-proxy: docker.io/knative-images-repo7/queue-proxy-suffix:latest
```

You can also run the following commands to make the equivalent change:

```bash
kn operator configure images --component serving --imageKey activator --imageURL docker.io/knative-images-repo1/activator:latest -n knative-serving
kn operator configure images --component serving --imageKey autoscaler --imageURL docker.io/knative-images-repo2/autoscaler:latest -n knative-serving
kn operator configure images --component serving --imageKey controller --imageURL docker.io/knative-images-repo3/controller:latest -n knative-serving
kn operator configure images --component serving --imageKey webhook --imageURL docker.io/knative-images-repo4/webhook:latest -n knative-serving
kn operator configure images --component serving --imageKey autoscaler-hpa --imageURL docker.io/knative-images-repo5/autoscaler-hpa:latest -n knative-serving
kn operator configure images --component serving --deployName net-istio-controller --imageKey controller --imageURL docker.io/knative-images-repo6/prefix-net-istio-controller:latest -n knative-serving
kn operator configure images --component serving --deployName net-istio-webhook --imageKey webhook --imageURL docker.io/knative-images-repo6/net-istio-webhook:latest -n knative-serving
kn operator configure images --component serving --imageKey queue-proxy --imageURL docker.io/knative-images-repo7/queue-proxy-suffix:latest -n knative-serving
```

!!! note
    If the container name is not unique across all Deployments, DaemonSets and Jobs, you can prefix the container name with the parent container name and a slash. For example, `istio-webhook/webhook`.

### Download images with secrets

If your image repository requires private secrets for
access, include the `imagePullSecrets` attribute.

This example uses a secret named `regcred`. You must create your own private secrets if these are required:

- [From existing docker credentials](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials)
- [From command line for docker credentials](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)
- [Create your own secret](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets)

After you create this secret, edit the Operator CR by appending the following content:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    ...
    imagePullSecrets:
      - name: regcred
```

The field `imagePullSecrets` expects a list of secrets. You can add multiple secrets to access the images as follows:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    ...
    imagePullSecrets:
      - name: regcred
      - name: regcred-2
      ...
```

## SSL certificate for controller

To [enable tag to digest resolution](../../serving/tag-resolution.md), the Knative Serving controller needs to access the container registry.
To allow the controller to trust a self-signed registry cert, you can use the Operator to specify the certificate using a ConfigMap or Secret.

Specify the following fields in `spec.controller-custom-certs` to select a custom registry certificate:

- `name`: the name of the ConfigMap or Secret.
- `type`: either the string "ConfigMap" or "Secret".

If you create a ConfigMap named `testCert` containing the certificate, change your CR:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  controller-custom-certs:
    name: testCert
    type: ConfigMap
```

## Replace the default Istio ingress gateway service

1. [Create a gateway Service and Deployment instance](../../serving/setting-up-custom-ingress-gateway.md#step-1-create-the-gateway-service-and-deployment-instance).

1. Update the Knative gateway by updating the `ingress.istio.knative-ingress-gateway` spec to select the labels of the new ingress gateway:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      ingress:
        istio:
          enabled: true
          knative-ingress-gateway:
            selector:
              istio: ingressgateway
    ```

1. Update the Istio ingress gateway ConfigMap:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      ingress:
        istio:
          enabled: true
          knative-ingress-gateway:
            selector:
              istio: ingressgateway
      config:
        istio:
          gateway.knative-serving.knative-ingress-gateway: "custom-ingressgateway.custom-ns.svc.cluster.local"
    ```

    The key in `spec.config.istio` is in the format of `gateway.<gateway_namespace>.<gateway_name>`.

## Replace the ingress gateway

1. [Create a gateway](../../serving/setting-up-custom-ingress-gateway.md#step-1-create-the-gateway).

1. Update the Istio ingress gateway ConfigMap:

    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
      namespace: knative-serving
    spec:
      config:
        istio:
          gateway.custom-ns.knative-custom-gateway: "istio-ingressgateway.istio-system.svc.cluster.local"
    ```

    The key in `spec.config.istio` is in the format of `gateway.<gateway_namespace>.<gateway_name>`.

## Configuration of cluster local gateway

Update `spec.ingress.istio.knative-local-gateway` to select the labels of the new cluster-local ingress gateway:

### Default local gateway name

Go through the [installing Istio](../installing-istio.md#installing-istio-without-sidecar-injection) guide to use local cluster gateway,
if you use the default gateway called `knative-local-gateway`.

### Non-default local gateway name

If you create custom local gateway with a name other than `knative-local-gateway`, update `config.istio` and the
`knative-local-gateway` selector:

This example shows a service and deployment `knative-local-gateway` in the namespace `istio-system`, with the
label `custom: custom-local-gw`:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  ingress:
    istio:
      enabled: true
      knative-local-gateway:
        selector:
          custom: custom-local-gateway
  config:
    istio:
      local-gateway.knative-serving.knative-local-gateway: "custom-local-gateway.istio-system.svc.cluster.local"
```

## Servers configuration for Istio gateways:

You can leverage the KnativeServing CR to configure the hosts and port of the servers stanzas for `knative-local-gateway`
or `knative-ingress-gateway` gateways. For example, you would like to specify the host into `<test-ip>` and configure the
port with `number: 443`, `name: https`, `protocol: HTTPS`, and `target_port: 8443` for `knative-local-gateway`,
apply the following yaml content:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  ingress:
    istio:
      enabled: true
      knative-local-gateway:
        servers:
        - port:
            number: 443
            name: https
            protocol: HTTPS
            target_port: 8443
          hosts:
          - <test-ip>
  config:
    istio:
      local-gateway.knative-serving.knative-local-gateway: "custom-local-gateway.istio-system.svc.cluster.local"
```

## High availability

By default, Knative Serving runs a single instance of each deployment. The `spec.high-availability` field allows you to configure the number of replicas for all deployments managed by the operator.

The following configuration specifies a replica count of 3 for the deployments:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  high-availability:
    replicas: 3
```

You can also run the following command to make the equivalent change:

```bash
kn operator configure replicas --component serving --replicas 3 -n knative-serving
```

The `replicas` field also configures the `HorizontalPodAutoscaler` resources based on the `spec.high-availability`. Let's say the operator includes the following HorizontalPodAutoscaler:

```yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  ...
spec:
  minReplicas: 3
  maxReplicas: 5
```

If you configure `replicas: 2`, which is less than `minReplicas`, the operator transforms `minReplicas` to `1`.

If you configure `replicas: 6`, which is more than `maxReplicas`, the operator transforms `maxReplicas` to `maxReplicas + (replicas - minReplicas)` which is `8`.

## Override system deployments

If you would like to override some configurations for a specific deployment, you can override the configuration by modifying the `deployments` spec in the `KnativeServing` CR. Currently `resources`, `replicas`, `labels`, `annotations` and `nodeSelector` are supported.

### Override the resources

The `KnativeServing` CR is able to configure system resources for the Knative system containers based on the deployment. Requests and limits can be configured for all the available containers within a deployment.

For example, the following `KnativeServing` CR configures the container `controller` in the deployment `controller` to request 0.3 CPU and 100MB of RAM, and sets hard limits of 1 CPU and 250MB RAM:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  deployments:
  - name: controller
    resources:
    - container: controller
      requests:
        cpu: 300m
        memory: 100Mi
      limits:
        cpu: 1000m
        memory: 250Mi
```

You can also run the following command to make the equivalent change:

```bash
kn operator configure resources --component serving --deployName controller --container controller --requestCPU 300m --requestMemory 100Mi --limitCPU 1000m --limitMemory 250Mi -n knative-serving
```

### Override replicas, labels and annotations

The following KnativeServing resource overrides the `webhook` deployment to have `3` Replicas, the label `mylabel: foo`, and the annotation `myannotations: bar`, while other system deployments have `2` Replicas by using `spec.high-availability`.

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  high-availability:
    replicas: 2
  deployments:
  - name: webhook
    replicas: 3
    labels:
      mylabel: foo
    annotations:
      myannotations: bar
```

You can also run the following commands to make the equivalent change:

```bash
kn operator configure replicas --component serving --replicas 2 -n knative-serving
kn operator configure replicas --component serving --deployName webhook --replicas 3 -n knative-serving
kn operator configure labels --component serving --deployName webhook --key mylabel --value foo -n knative-serving
kn operator configure annotations --component serving --deployName webhook --key myannotations --value bar -n knative-serving
```

!!! note
    The `KnativeServing` CR `label` and `annotation` settings override the webhook's labels and annotations for Deployments and Pods.

### Override the nodeSelector

The following `KnativeServing` CR overrides the `webhook` deployment to use the `disktype: hdd` nodeSelector:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  deployments:
  - name: webhook
    nodeSelector:
      disktype: hdd
```

You can also run the following command to make the equivalent change:

```bash
kn operator configure nodeSelectors --component serving --deployName webhook --key disktype --value hdd -n knative-serving
```

### Override the tolerations

The KnativeServing resource is able to override tolerations for the Knative Serving deployment resources.
For example, if you would like to add the following tolerations

```yaml
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
```

to the deployment `activator`, you need to change your KnativeServing CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  deployments:
  - name: activator
    tolerations:
    - key: "key1"
      operator: "Equal"
      value: "value1"
      effect: "NoSchedule"
```

You can also run the following command to make the equivalent change:

```bash
kn operator configure tolerations --component serving --deployName activator --key key1 --operator Equal --value value1 --effect NoSchedule -n knative-serving
```

### Override the affinity

The KnativeServing resource is able to override the affinity, including nodeAffinity, podAffinity, and podAntiAffinity,
for the Knative Serving deployment resources. For example, if you would like to add the following nodeAffinity

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

to the deployment `activator`, you need to change your KnativeServing CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
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

### Override the environment variables

The KnativeServing resource is able to override or add the environment variables for the containers in the Knative Serving
deployment resources. For example, if you would like to change the value of environment variable `METRICS_DOMAIN` in the
container `controller` into "knative.dev/my-repo" for the deployment `controller`, you need to change your KnativeServing
CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  deployments:
  - name: controller
    env:
    - container: controller
      envVars:
      - name: METRICS_DOMAIN
        value: "knative.dev/my-repo"
```

You can also run the following command to make the equivalent change:

```bash
kn operator configure envvars --component serving --deployName controller --container controller --name METRICS_DOMAIN --value "knative.dev/my-repo" -n knative-serving
```

## Override system services

If you would like to override some configurations for a specific service, you can override the configuration by using `spec.services` in CR.
Currently `labels`, `annotations` and `selector` are supported.

### Override labels and annotations and selector

The following KnativeServing resource overrides the `webhook` service to have the label `mylabel: foo`, the annotation `myannotations: bar`,
the selector `myselector: bar`.

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  services:
  - name: webhook
    labels:
      mylabel: foo
    annotations:
      myannotations: bar
    selector:
      myselector: bar
```

You can also run the following commands to make the equivalent change:

```bash
kn operator configure labels --component serving --serviceName webhook --key mylabel --value foo -n knative-serving
kn operator configure annotations --component serving --serviceName webhook --key myannotations --value bar -n knative-serving
kn operator configure selectors --component serving --serviceName webhook --key myselector --value bar -n knative-serving
```

## Override system podDisruptionBudgets

A Pod Disruption Budget (PDB) allows you to limit the disruption to your application when its pods need to be rescheduled
for maintenance reasons. Knative Operator allows you to configure the `minAvailable` for a specific podDisruptionBudget
resource in Serving based on the name. To understand more about the configuration of the resource podDisruptionBudget, click [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/).
For example, if you would like to change `minAvailable` into 70% for the podDisruptionBudget named `activator-pdb`, you
need to change your KnativeServing CR as below:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  podDisruptionBudgets:
  - name: activator-pdb
    minAvailable: 70%
```
