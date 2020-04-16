---
title: "Configuring the Serving Operator Custom Resource"
weight: 10
type: "docs"
aliases:
- /docs/operator/configuring-serving-cr/
---

The Knative Serving operator can be configured with these options:

- [All the ConfigMaps](#all-the-configmaps)
- [Private repository and private secret](#private-repository-and-private-secrets)
- [SSL certificate for controller](#ssl-certificate-for-controller)
- [Knative ingress gateway](#configuration-of-knative-ingress-gateway)
- [Cluster local gateway](#configuration-of-cluster-local-gateway)
- [High availability](#high-availability)
- [Managing Resources for Containers](#managing-resources-for-containers)

__NOTE:__ Kubernetes spec level policies cannot be configured using the Knative operators.

## All the ConfigMaps

All the ConfigMaps can be configured in Knative Serving with the custom resource. The values in the custom resource will
overwrite the existing values in ConfigMaps. In the latest release of Knative Serving, there are multiple ConfigMaps,
e.g. `config-autoscaler`, `config-default`, `config-deployment`, etc. All the ConfigMaps are named with the prefix
`config-`. and in the format of `config-<name>`. A field named `config` is defined under the section `spec` to specify
all the ConfigMaps. Under the section `spec.config`, use the name after the hyphen(`-`) sign, `<name>`, as the field to
specify all the key-value pairs, which are exactly the same as we have in the section `data` for each ConfigMap.

As in the example of how to [setup a custom domain](https://knative.dev/development/serving/using-a-custom-domain/), you can see the content of the ConfigMap
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

To specify the ConfigMap `config-domain`, you can change the content of the operator CR into:

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

Next, save the CR into a file named `operator-cr.yaml`, and run the command:

```
kubectl apply -f operator-cr.yaml
```

If you want to change another ConfigMap, e.g. `config-autoscaler`, by specifying `stable-window` to `60s`. Continue to
change your operator CR into:

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

Then, save the content in a file named `operator-cr.yaml`, and run the command:

```
kubectl apply -f operator-cr.yaml
```

All the ConfigMaps should be defined under the same namespace as the operator CR. You can use the operator CR as the
unique entry point to edit all of them.

## Private repository and private secrets

As in the latest release of Knative Serving, there are six `Deployment` resources: `activator`, `autoscaler`, `controller`,
`webhook`, `autoscaler-hpa` & `networking-istio`, under the apiVersion `apps/v1`, and one image: `queue-proxy`, under the
apiVersion `caching.internal.knative.dev/v1alpha1`. The images can be downloaded from the links specified in the `spec.image`
section for each of the resources. Knative Serving Operator provides us a way to download the images from private
repositories for Knative deployments and image(s).

Under the section `spec` of the operator CR, you can create a section of `registry`, containing all the fields to define
the information about the private registry:

- `default`: this field expects a string value, used to define image reference template for all Knative images. The format
is in `example-registry.io/custom/path/${NAME}:{CUSTOM-TAG}`. Since all your private images can be saved in the same
repository with the same tag, the only difference is the image name. `${NAME}` should be kept as it is, because this is
a pre-defined container variable in operator. If you name the images after the container names within all `Deployment` resources:
`activator`, `autoscaler`, `controller`, `webhook`, `autoscaler-hpa` & `networking-istio`, for all `Deployment` resources,
and name the image after `queue-proxy`, for the `Image` resource, you do not need to do any further configuration in the
next section `override`, because operator can automatically replace `${NAME}` with the corresponding container name. For
serving-operator, there is only one container defined in each `Deployment` resource. The container shares the same as
its parent deployment.

- `override`: this field expects a map of key-value pairs, with container name or image name as the key, and the full image
location as the value. We usually need to configure this section, when we do not have a common format for all the image
links. This field is used alternatively with the previous field `default`. If the image for a certain container or `Image`
resource is specified in both this field and the `default` field, this `override` field takes precedence. This field can
also be used as the supplement of the `default` field, if the image link can not match the predefined format.

- `imagePullSecrets`: this field is used to define a list of secrets to be used when pulling the knative images. The secret
must be created in the same namespace as the Knative Serving deployments. You do not need to define any secret here if
your image is publicly available. Configuration of this field is equivalent to the configuration of [deploying images
from a private container registry](https://knative.dev/development/serving/deploying/private-registry/).

This `registry` section is used to specify the links of the custom Knative images, and the appropriate credentials to access
them. We will use examples to illustrate how we define all the fields, regarding your custom image links and private secrets.

### Download images in a predefined format without secrets:

This example shows how you can define custom image links that can be defined in the CR using the simplified format
`docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

In the example below:

- the custom tag `v0.13.0` is used for all images
- all image links are accessible without using secrets
- images are defined in the accepted format `docker.io/knative-images/${NAME}:{CUSTOM-TAG}`

First, you need to make sure your images are saved in the following link:

- Image of `activator`: `docker.io/knative-images/activator:v0.13.0`.
- Image of `autoscaler`: `docker.io/knative-images/autoscaler:v0.13.0`.
- Image of `controller`: `docker.io/knative-images/controller:v0.13.0`.
- Image of `webhook`: `docker.io/knative-images/webhook:v0.13.0`.
- Image of `autoscaler-hpa`: `docker.io/knative-images/autoscaler-hpa:v0.13.0`.
- Image of `networking-istio`: `docker.io/knative-images/networking-istio:v0.13.0`.
- Cache image `queue-proxy`: `docker.io/knative-images/queue-proxy:v0.13.0`.

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

Replace `{CUSTOM-TAG}` with the custom tag `v0.13.0`. `${NAME}` needs to map the same name of each container or each
`Image` resource. The field `default` is used to define the image format for all containers and the `Image` resource.
Make sure you want to replace the images for all containers and `Image` resources in Knative Serving with your own
images, by specifying the field `default`.

### Download images individually without secrets:

If your custom image links are not defined in a uniform format by default, you will need to individually include each
link in the CR.

For example, to define the list of images:

- Image of `activator`: `docker.io/knative-images-repo1/activator:v0.13.0`.
- Image of `autoscaler`: `docker.io/knative-images-repo2/autoscaler:v0.13.0`.
- Image of `controller`: `docker.io/knative-images-repo3/controller:v0.13.0`.
- Image of `webhook`: `docker.io/knative-images-repo4/webhook:v0.13.0`.
- Image of `autoscaler-hpa`: `docker.io/knative-images-repo5/autoscaler-hpa:v0.13.0`.
- Image of `networking-istio`: `docker.io/knative-images-repo6/prefix-networking-istio:v0.13.0`.
- Cache image `queue-proxy`: `docker.io/knative-images-repo7/queue-proxy-suffix:v0.13.0`.

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

If you use the default or override attributes to define image links, and the image links require private secrets for
access, you must append the `imagePullSecrets` attribute.

This example uses a secret named `regcred`. You must create your own private secrets if these are required:

- [From existing docker credentials](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials)
- [From command line for docker credentials](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)
- [Create your own secret](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets)

After you create this secret, edit your operator CR by appending the content below ...:

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

Knative Serving needs to access the container registry, based on the feature [enabling tag to digest resolution](https://knative.dev/development/serving/tag-resolution/). The
Serving Operator CR allows you to specify either a custom ConfigMap or a Secret as a self-signed certificate for the
deployment called `controller`. It enables the `controller` to trust registries with self-signed certificates.

Under the section `spec` of the operator CR, you can create a section of `controller-custom-certs` to contain all the
fields to define the certificate:

- `name`: this field is used to specify the name of the ConfigMap or the Secret.
- `type`: the value for this field can be either ConfigMap or Secret, indicating the type for the name.

This section `controller-custom-certs` is used to access the user's images in private repositories with the appropriate
certificate.

If you create a configMap named `testCertas` as the certificate, you need to change your CR into:

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

It will make sure this custom certificate is mounted as a volume to the containers launched by the `Deployment` resource
`controller`, and the environment variable is `SSL_CERT_DIR` set correctly.

## Configuration of Knative ingress gateway

To set up custom ingress gateway, follow “**Step 1: Create Gateway Service and Deployment Instance**” [here](https://knative.dev/development/serving/setting-up-custom-ingress-gateway/).

**Step 2: Update the Knative gateway**

We use the field `knative-ingress-gateway` to override the knative-ingress-gateway. We only support the field `selector`
to define the selector for ingress-gateway.

Instead of updating the gateway directly, we modify the operator CR as below:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    knative-ingress-gateway:
      selector:
        custom: ingressgateway
```

**Step 3: Update Gateway ConfigMap**

As we explained, all ConfigMaps can be edited as editing the the operator CR. For this example, take the following content
as your operator CR:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    knative-ingress-gateway:
      selector:
        custom: ingressgateway
    config:
      istio:
        gateway.knative-serving.knative-ingress-gateway: "custom-ingressgateway.istio-system.svc.cluster.local"
```

The key in `spec.config.istio` is in the format of `gateway.{{gateway_namespace}}.{{gateway_name}}`.

## Configuration of cluster local gateway:

We use the field `cluster-local-gateway` to override the the gateway cluster-local-gateway. We only support the field
`selector` to define the selector for the local gateway.

**Default local gateway name**:

Go through the guide [here](https://knative.dev/development/install/installing-istio/#updating-your-install-to-use-cluster-local-gateway) to use local cluster gateway.

After following the above step, your service and deployment for the local gateway are both named `cluster-local-gateway`.
You only need to configure the operator CR as below:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    cluster-local-gateway:
      selector:
        istio: cluster-local-gateway
```

You can even skip the above change, since there is a gateway called `cluster-local-gateway`, which has
`istio: cluster-local-gateway` as the default selector. If the operator CR does not define the section
cluster-local-gateway, the default `istio: cluster-local-gateway` of the gateway cluster-local-gateway will be chosen.

**Non-default local gateway name**:

If you create custom service and deployment for local gateway with a name other than `cluster-local-gateway`, you need
to update gateway configmap `config-istio` under the Knative Serving namespace, and change the selector for the gateway
cluster-local-gateway.

If you name both of the service and deployment after `custom-local-gateway` in the namespace `istio-system`, with the
label `custom: custom-local-gateway`, the operator CR should be like:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    cluster-local-gateway:
      selector:
        custom: custom-local-gateway
    config:
      istio:
        local-gateway.knative-serving.cluster-local-gateway: "custom-local-gateway.istio-system.svc.cluster.local"
```

## High availability:

Knative Serving Operator CR provides the capability to configure the high availability for the following `Deployment`
resources: `controller`, `autoscaler-hpa` & `networking-istio`, and all the `HorizontalPodAutoscaler` resources. A field
named `high-availability` is defined under the section `spec` to configure the high availability control plane. In the
latest release of Knative Serving Operator, you can specify the minimum number of replicas for the `Deployment` and
`HorizontalPodAutoscaler` resources.

If you want to specify 3 as the minimum number of replicas for three of the `Deployment` resources and the `HorizontalPodAutoscaler`
resources, change your CR into:

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

## Managing resources for containers

Knative Serving Operator CR allows you to configure the resources for the containers defined in the `Deployment` resource.
Each `Deployment` resource has only one container with the same deployment name. The following containers can be configured
in terms of the required and maximum resources to be allocated: `activator`, `autoscaler`, `controller`, `webhook`, `autoscaler-hpa`,
`networking-istio` and `queue-proxy`. The field called `resources` holds the stanza of a list of containers for resource
configuration. The field `require` defines how much resource the container requires. The field `limit` defines the maximum
resource the container can use. Within each field, each container can be configured individually with the following
parameters: `memory`, `cpu`, `storage` and `ephemeral-storage`. The value in `require` should always be smaller than the
corresponding value in `limit`. The field `container` is used to specify the container name.

Suppose you would like to configure the container called `activator` with the required resources:

```
cpu: 30m
memory: 40Mi
storage: 1Gi
ephemeral-storage: 2Gi
```

, and the limit resources:

```
cpu: 300m
memory: 4000Mi
storage: 2Gi
ephemeral-storage: 4Gi
```

Here is how you should write your CR:

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
        cpu: 30m
        memory: 40Mi
        storage: 1Gi
        ephemeral-storage: 2Gi
      limits:
        cpu: 300m
        memory: 400Mi
        storage: 2Gi
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
        cpu: 30m
        memory: 40Mi
        storage: 1Gi
        ephemeral-storage: 2Gi
      limits:
        cpu: 300m
        memory: 400Mi
        storage: 2Gi
        ephemeral-storage: 4Gi
  - container: autoscaler
      requests:
        cpu: 30m
        memory: 40Mi
        storage: 1Gi
        ephemeral-storage: 2Gi
      limits:
        cpu: 300m
        memory: 400Mi
        storage: 2Gi
        ephemeral-storage: 4Gi
```
