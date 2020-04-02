- [All the ConfigMaps](#all-the-configmaps)
- [Private repository and private secret](#private-repository-and-private-secrets)

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
a pre-defined container variable in operator. If you name the images after the names of the `Deployment` resources:
`activator`, `autoscaler`, `controller`, `webhook`, `autoscaler-hpa` & `networking-istio`, for all `Deployment` resources,
and name the image after `queue-proxy`, for the `Image` resource, you do not need to do any further configuration in the
next section `override`, because operator can automatically replace `${NAME}` with the corresponding name of the `Deployment`
resource.

- `override`: this field expects a map of key-value pairs, with container name or image name as the key, and the full image
location as the value. We usually need to configure this section, when we do not have a common format for all the image
links. This field is used alternatively with the previous field `default`.

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

Replace `{CUSTOM-TAG}` with the custom tag `v0.13.0`. `${NAME}` needs to map the same name of each `Deployment` resource.
The field `default` is used to define the image format for all `Deployment` and `Image` resources, make sure you want to
replace the images for all `Deployment` and `Image` resources in Knative Serving with your own images, by specifying
the field `default`.

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
