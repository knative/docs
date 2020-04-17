---
title: "Configuring the Serving Operator Custom Resource"
weight: 20
type: "docs"
aliases:
- /docs/operator/configuring-serving-cr/
---

The Knative Serving operator can be configured with these options:

- [Service Configuration by ConfigMap](#service-configuration-by-configMap)
- [Private repository and private secret](#private-repository-and-private-secrets)
- [SSL certificate for controller](#ssl-certificate-for-controller)
- [Knative ingress gateway](#configuration-of-knative-ingress-gateway)
- [Cluster local gateway](#configuration-of-cluster-local-gateway)
- [High availability](#high-availability)
- [System Resource Settings](#system-resource-settings)

## Service Configuration by ConfigMap

Because the operator manages the Knative Serving installation, it will overwrite any updates to the `ConfigMaps` which are used to configure Knative Serving.
The `KnativeServing` custom resource allows you to set values for these ConfigMaps via the operator. Knative Serving has multiple ConfigMaps named with the prefix
`config-`. The `spec.config` in `KnativeServing` has one entry `<name>` for each ConfigMap named `config-<name>`, with a value which will be used for the ConfigMap's `data`.

In the [setup a custom domain example](https://knative.dev/development/serving/using-a-custom-domain/), you can see the content of the ConfigMap
`config-domain` is:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
data:
  example.org: |
    selector:
      app: prod
  example.com: ""
```

Using the operator, specify the ConfigMap `config-domain` using the operator CR:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  config:
    domain:
      example.org: |
        selector:
          app: prod
      example.com: ""
```

You can apply values to multiple ConfigMaps. This example sets `stable-window` to 60s in `config-autoscaler` as well as specifying `config-domain`:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  config:
    domain:
      example.org: |
        selector:
          app: prod
      example.com: ""
    autoscaler:
      stable-window: "60s"
```

All the ConfigMaps are created in the same namespace as the operator CR. You can use the operator CR as the
unique entry point to edit all of them.

## Private repository and private secrets


You can use the `spec.registry` section of the operator CR to change the image references to point to a private registry or [specify imagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod):

- `default`: this field defines a image reference template for all Knative images. The format
is `example-registry.io/custom/path/${NAME}:{CUSTOM-TAG}`. If you use the same tag for all your images, the only difference is the image name. `${NAME}` is
a pre-defined variable in the operator corresponding to the container name. If you name the images in your private repo to align with the container names (
`activator`, `autoscaler`, `controller`, `webhook`, `autoscaler-hpa`, `networking-istio`, and `queue-proxy`), the `default` argument should be sufficient.

- `override`: a map from container name to the full registry
location. This section is only needed when the registry images do not match the common naming format. For containers whose name matches a key, the value is used in preference to the image name calculated by `default`. If a container's name does not match a key in `override`, the template in `default` is used.

- `imagePullSecrets`: a list of Secret names used when pulling Knative container images. The Secrets
must be created in the same namespace as the Knative Serving Deployments. See [deploying images
from a private container registry](https://knative.dev/development/serving/deploying/private-registry/) for configuration details.


### Download images in a predefined format without secrets:

This example shows how you can define custom image links that can be defined in the CR using the simplified format
`docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

In the example below:

- the custom tag `v0.13.0` is used for all images
- all image links are accessible without using secrets
- images are pushed as `docker.io/knative-images/${NAME}:{CUSTOM-TAG}`

First, you need to make sure your images pushed to the following image tags:

| Container | Docker Image |
|----|----|
|`activator` | `docker.io/knative-images/activator:v0.13.0` |
| `autoscaler` | `docker.io/knative-images/autoscaler:v0.13.0` |
| `controller` | `docker.io/knative-images/controller:v0.13.0` |
| `webhook` | `docker.io/knative-images/webhook:v0.13.0` |
| `autoscaler-hpa` | `docker.io/knative-images/autoscaler-hpa:v0.13.0` |
| `networking-istio` | `docker.io/knative-images/networking-istio:v0.13.0` |
| `queue-proxy` | `docker.io/knative-images/queue-proxy:v0.13.0` |

Then, you need to define your operator CR with following content:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    default: docker.io/knative-images/${NAME}:v0.13.0
```


### Download images individually without secrets:

If your custom image links are not defined in a uniform format by default, you will need to individually include each
link in the CR.

For example, to given the following images:

| Container | Docker Image |
|----|----|
| `activator` | `docker.io/knative-images-repo1/activator:v0.13.0` |
| `autoscaler` | `docker.io/knative-images-repo2/autoscaler:v0.13.0` |
| `controller` | `docker.io/knative-images-repo3/controller:v0.13.0` |
| `webhook` | `docker.io/knative-images-repo4/webhook:v0.13.0` |
| `autoscaler-hpa` | `docker.io/knative-images-repo5/autoscaler-hpa:v0.13.0` |
| `networking-istio` | `docker.io/knative-images-repo6/prefix-networking-istio:v0.13.0` |
| `queue-proxy` | `docker.io/knative-images-repo7/queue-proxy-suffix:v0.13.0` |

The operator CR should be modified to include the full list:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    override:
      activator: docker.io/knative-images-repo1/activator:v0.13.0
      autoscaler: docker.io/knative-images-repo2/autoscaler:v0.13.0
      controller: docker.io/knative-images-repo3/controller:v0.13.0
      webhook: docker.io/knative-images-repo4/webhook:v0.13.0
      autoscaler-hpa: docker.io/knative-images-repo5/autoscaler-hpa:v0.13.0
      networking-istio: docker.io/knative-images-repo6/prefix-networking-istio:v0.13.0
      queue-proxy: docker.io/knative-images-repo7/queue-proxy-suffix:v0.13.0
```

### Download images with secrets:

If your image repository requires private secrets for
access, include the `imagePullSecrets` attribute.

This example uses a secret named `regcred`. You must create your own private secrets if these are required:

- [From existing docker credentials](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials)
- [From command line for docker credentials](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)
- [Create your own secret](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets)

After you create this secret, edit your operator CR by appending the content below:

```
apiVersion: operator.knative.dev/v1alpha1
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

The field `imagePullSecrets` expects a list of secrets. You can add multiple secrets to access the images as below:

```
apiVersion: operator.knative.dev/v1alpha1
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

To [enable tag to digest resolution](https://knative.dev/development/serving/tag-resolution/), the Knative Serving controller needs to access the container registry.
To allow the controller to trust a self-signed registry cert, you can use the Operator to specify the certificate using a ConfigMap or Secret.

Specify the following fields in `spec.controller-custom-certs` to select a custom registry certificate:

- `name`: the name of the ConfigMap or Secret.
- `type`: either the string "ConfigMap" or "Secret".


If you create a ConfigMap named `testCert` containing the certificate, change your CR:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  controller-custom-certs:
    name: testCert
    type: ConfigMap
```


## Configuration of Knative ingress gateway

To set up custom ingress gateway, follow [**Step 1: Create Gateway Service and Deployment Instance**](https://knative.dev/development/serving/setting-up-custom-ingress-gateway/).

### Step 2: Update the Knative gateway

Update `spec.knative-ingress-gateway` to select the labels of the new ingress gateway:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  knative-ingress-gateway:
    selector:
      custom: ingressgateway
```

### Step 3: Update Gateway ConfigMap

Additionally, you will need to update the Istio ConfigMap:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  knative-ingress-gateway:
    selector:
      custom: ingressgateway
  config:
    istio:
      gateway.knative-serving.knative-ingress-gateway: "custom-ingressgateway.istio-system.svc.cluster.local"
```

The key in `spec.config.istio` is in the format of `gateway.{{gateway_namespace}}.{{gateway_name}}`.

## Configuration of cluster local gateway

Update `spec.cluster-local-gateway` to select the labels of the new cluster-local ingress gateway:

### Default local gateway name:

Go through the guide [here](https://knative.dev/development/install/installing-istio/#updating-your-install-to-use-cluster-local-gateway) to use local cluster gateway,
if you use the default gateway called `cluster-local-gateway`.

### Non-default local gateway name:

If you create custom local gateway with a name other than `cluster-local-gateway`, update `config.istio` and the
`cluster-local-gateway` selector:

This example shows a service and deployment `custom-local-gateway` in the namespace `istio-system`, with the
label `custom: custom-local-gw`:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  cluster-local-gateway:
    selector:
      custom: custom-local-gateway
  config:
    istio:
      local-gateway.knative-serving.cluster-local-gateway: "custom-local-gateway.istio-system.svc.cluster.local"
```

## High availability

By default, Knative Serving runs a single instance of each controller. The `spec.high-availability` field allows you to configure the number of replicas for the following master-elected controllers: `controller`, `autoscaler-hpa`, `networking-istio`. This field also configures the `HorizontalPodAutoscaler` resources for the data plane (`activator`):

The following configuration specifies a replica count of 3 for the controllers and a minimum of 3 activators (which may scale higher if needed):

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  high-availability:
    replicas: 3
```

## System Resource Settings

The operator custom resource allows you allows you to configure system resources for the Knative system containers.
Requests and limits can be configured for the following containers: `activator`, `autoscaler`, `controller`, `webhook`, `autoscaler-hpa`,
`networking-istio` and `queue-proxy`.

To override resource settings for a specific container, create an entry in the `spec.resources` list with the container name and the [Kubernetes resource settings](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container).

For example, the following KnativeServing resource configures the `activator` to request 0.3 CPU and 100MB of RAM, and sets hard limits of 1 CPU, 250MB RAM, and 4GB of local storage:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  resources:
  - container: activator
    requests:
      cpu: 300m
      memory: 100Mi
    limits:
      cpu: 1000m
      memory: 250Mi
      ephemeral-storage: 4Gi
```

If you would like to add another container `autoscaler` with the same configuration, you need to change your CR as below:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  resources:
  - container: activator
    requests:
      cpu: 300m
      memory: 100Mi
    limits:
      cpu: 1000m
      memory: 250Mi
      ephemeral-storage: 4Gi
  - container: autoscaler
    requests:
      cpu: 300m
      memory: 100Mi
    limits:
      cpu: 1000m
      memory: 250Mi
      ephemeral-storage: 4Gi
```
