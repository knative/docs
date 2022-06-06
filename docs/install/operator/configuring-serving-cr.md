# Configuring the Knative Serving Operator custom resource

You can configure Knative Serving with the following options:

- [Version configuration](#version-configuration)
- [Install customized Knative Serving](#install-customized-knative-serving)
- [Private repository and private secret](#private-repository-and-private-secrets)
- [SSL certificate for controller](#ssl-certificate-for-controller)
- [Replace the default istio-ingressgateway service](#replace-the-default-istio-ingressgateway-service)
- [Replace the knative-ingress-gateway gateway](#replace-the-knative-ingress-gateway-gateway)
- [Cluster local gateway](#configuration-of-cluster-local-gateway)
- [High availability](#high-availability)
- [Override system deployments](#override-system-deployments)

## Version configuration

Cluster administrators can install a specific version of Knative Serving by using the `spec.version` field.

For example, if you want to install Knative Serving v0.23.0, you can apply the following `KnativeServing` custom resource:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: 0.23.0
```

If `spec.version` is not specified, the Knative Operator installs the latest available version of Knative Serving. If users specify an invalid or unavailable version, the Knative Operator will do nothing. The Knative Operator always includes the latest 3 minor release versions. For example, if the current version of the Knative Operator is v0.24.0, the earliest version of Knative Serving available through the Operator is v0.22.0.

If Knative Serving is already managed by the Operator, updating the `spec.version` field in the `KnativeServing` resource
enables upgrading or downgrading the Knative Serving version, without needing to change the Operator.

!!! important
    The Knative Operator only permits upgrades or downgrades by one minor release version at a time. For example, if the current Knative Serving deployment is version v0.22.0, you must upgrade to v0.23.0 before upgrading to v0.24.0.

## Install customized Knative Serving

The Operator provides you with the flexibility to install Knative Serving customized to your own requirements. As long
as the manifests of customized Knative Serving are accessible to the Operator, you can install them.

There are two modes available for you to install customized manifests: _overwrite mode_ and _append mode_.
With overwrite mode, under `.spec.manifests`, you must define all manifests needed for
Knative Serving to install because the Operator will no longer install any default manifests.
With append mode, under `.spec.additionalManifests`, you only need to define your customized manifests.
The customized manifests are installed after default manifests are applied.

### Overwrite mode

You can use overwrite mode when you want to customize all Knative Serving manifests.

For example, if you want to install Knative Serving and Istio ingress and you want customize both components, you can
create the following YAML file:

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
spec:
  version: $spec_version
  manifests:
  - URL: https://my-serving/serving.yaml
  - URL: https://my-net-istio/net-istio.yaml
```

This example installs the customized Knative Serving at version `$spec_version` which is available at
`https://my-serving/serving.yaml`, and the customized ingress plugin `net-istio` which is available at
`https://my-net-istio/net-istio.yaml`.

!!! attention
    You can make the customized Knative Serving available in one or multiple links, as the `spec.manifests` supports a list of links.
    The ordering of the URLs is critical. Put the manifest you want to apply first on the top.

We strongly recommend you to specify the version and the valid links to the customized Knative Serving, by leveraging
both `spec_version` and `spec.manifests`. Do not skip either field.

### Append mode

You can use append mode to add your customized manifests into the default manifests.

For example, if you only want to customize a few resources but you still want to install the default Knative Serving,
you can create the following YAML file:

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
spec:
  version: $spec_version
  additionalManifests:
  - URL: https://my-serving/serving-custom.yaml
```

This example installs the default Knative Serving, and installs your customized resources available at
`https://my-serving/serving-custom.yaml`.

Knative Operator installs the default manifests of Knative Serving at the version `$spec_version`, and then installs
your customized manifests based on them.

## Private repository and private secrets

You can use the `spec.registry` section of the operator CR to change the image references to point to a private registry or [specify imagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod):

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

## Replace the default istio-ingressgateway-service

To set up a custom ingress gateway, follow [**Step 1: Create Gateway Service and Deployment Instance**](../../serving/setting-up-custom-ingress-gateway.md#step-1-create-the-gateway-service-and-deployment-instance).

### Step 2: Update the Knative gateway

Update `spec.ingress.istio.knative-ingress-gateway` to select the labels of the new ingress gateway:

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

### Step 3: Update Gateway ConfigMap

Additionally, you will need to update the Istio ConfigMap:

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

## Replace the knative-ingress-gateway gateway

To create the ingress gateway, follow [**Step 1: Create the Gateway**](../../serving/setting-up-custom-ingress-gateway.md#step-1-create-the-gateway).

### Step 2: Update Gateway ConfigMap

You will need to update the Istio ConfigMap:

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

If you would like to override some configurations for a specific deployment, you can override the configuration by using `spec.deployments` in CR.
Currently `resources`, `replicas`, `labels`, `annotations` and `nodeSelector` are supported.

### Override the resources

The KnativeServing custom resource is able to configure system resources for the Knative system containers based on the deployment.
Requests and limits can be configured for all the available containers within the deployment, like `activator`, `autoscaler`,
`controller`, etc.

For example, the following KnativeServing resource configures the container `controller` in the deployment `controller` to request
0.3 CPU and 100MB of RAM, and sets hard limits of 1 CPU and 250MB RAM:

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

### Override replicas, labels and annotations

The following KnativeServing resource overrides the `webhook` deployment to have `3` Replicas, the label `mylabel: foo`, and the annotation `myannotataions: bar`,
while other system deployments have `2` Replicas by using `spec.high-availability`.

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
      myannotataions: bar
```

!!! note
    The KnativeServing resource `label` and `annotation` settings override the webhook's labels and annotations for both Deployments and Pods.

### Override the nodeSelector

The following KnativeServing resource overrides the `webhook` deployment to use the `disktype: hdd` nodeSelector:

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
