---
title: "Configuring the Eventing Operator Custom Resource"
weight: 10
type: "docs"
aliases:
- /docs/operator/configuring-eventing-cr/
---

The Knative Eventing operator can be configured with these options:

- [Private repository and private secret](#private-repository-and-private-secrets)
- [Configuring default broker class](#configuring-default-broker-class)

__NOTE:__ Kubernetes spec level policies cannot be configured using the Knative operators.

## Private repository and private secrets

The Knative Eventing operator CR is configured the same way as the Knative Serving operator CR. For more information,
see the documentation on “[Private repository and private secret](configuring-serving-cr.md#private-repository-and-private-secrets)” in Serving operator for detailed instruction.

Knative Eventing also specifies only one container, within one `Deployment` resource. However, the container does not use
the same name as its parent `Deployment`, which means the container name in Knative Eventing is not the unique identifier
as in Knative Serving. Here is the list of containers within each `Deployment` resource:

- Container in Deployment `eventing-controller`: eventing-controller
- Container in Deployment `eventing-webhook`: eventing-webhook
- Container in Deployment `broker-controller`: eventing-controller
- Container in Deployment `imc-controller`: controller
- Container in Deployment `imc-dispatcher`: dispatcher

The `default` field can still be used to replace the images in a predefined format. However, if the container name is not
a unique identifier, e.g. `eventing-controller`, you need to use the `override` field to replace it, by specifying
`deployment/container` as the unique key.

Some images are defined via environment variable in Knative Eventing. They can be replaced by taking advantage of the
`override` field.

### Download images in predefined format without secrets:

This example shows how you can define custom image links that can be defined in the CR using the simplified format
`docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

In the example below:

- the custom tag `v0.13.0` is used for all images
- all image links are accessible without using secrets
- images are defined in the accepted format `docker.io/knative-images/${NAME}:{CUSTOM-TAG}`

First, you need to make sure your images are saved in the following link:

- Image of `eventing-controller` in the deployment `eventing-controller`: `docker.io/knative-images/eventing-controller:v0.13.0`.
- Image of `eventing-webhook`: `docker.io/knative-images/eventing-webhook:v0.13.0`.
- Image of `controller`: `docker.io/knative-images/controller:v0.13.0`.
- Image of `dispatcher`: `docker.io/knative-images/dispatcher:v0.13.0`.
- Image of `eventing-controller` in the deployment `broker-controller`: `docker.io/knative-images/broker-eventing-controller:v0.13.0`.

Then, you need to define your operator CR with following content:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  registry:
    default: docker.io/knative-images/${NAME}:v0.13.0
```

Replace `{CUSTOM-TAG}` with the custom tag `v0.13.0`. `${NAME}` needs to map the container name in each `Deployment` resource.
The field `default` is used to define the image format for all containers, except the container `eventing-controller` in
the deployment `broker-controller`. To replace the image for this container, you need to take advatage of the `override`
field to specify individually, by using `broker-controller/eventing-controller` as the key`. Change your CR into the following:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  registry:
    default: docker.io/knative-images/${NAME}:v0.13.0
    override:
      broker-controller/eventing-controller: docker.io/knative-images-repo1/broker-eventing-controller:v0.13.0
```

### Download images from different repositories without secrets:

If your custom image links are not defined in a uniform format by default, you will need to individually include each
link in the CR.

For example, to define the list of images:

- Image of `eventing-controller` in the deployment `eventing-controller`: `docker.io/knative-images/eventing-controller:v0.13.0`.
- Image of `eventing-webhook`: `docker.io/knative-images/eventing-webhook:v0.13.0`.
- Image of `controller`: `docker.io/knative-images/controller:v0.13.0`.
- Image of `dispatcher`: `docker.io/knative-images/dispatcher:v0.13.0`.
- Image of `eventing-controller` in the deployment `broker-controller`: `docker.io/knative-images/broker-eventing-controller:v0.13.0`.


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
      eventing-controller/eventing-controller: docker.io/knative-images-repo1/eventing-controller:v0.13.0
      eventing-webhook/eventing-webhook: docker.io/knative-images-repo2/eventing-webhook:v0.13.0
      imc-controller/controller: docker.io/knative-images-repo3/imc-controller:v0.13.0
      imc-dispatcher/dispatcher: docker.io/knative-images-repo4/imc-dispatcher:v0.13.0
      broker-controller/eventing-controller: docker.io/knative-images-repo5/broker-eventing-controller:v0.13.0
```

If you would like to replace the image defined by environment variable, e.g. the envorinment variable `DISPATCHER_IMAGE`
in the container `controller` of the deployment `imc-controller`, you need to adjust your CR into the following, if the
target image is `docker.io/knative-images-repo5/DISPATCHER_IMAGE:v0.13.0`:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    override:
      eventing-controller/eventing-controller: docker.io/knative-images-repo1/eventing-controller:v0.13.0
      eventing-webhook/eventing-webhook: docker.io/knative-images-repo2/eventing-webhook:v0.13.0
      imc-controller/controller: docker.io/knative-images-repo3/imc-controller:v0.13.0
      imc-dispatcher/dispatcher: docker.io/knative-images-repo4/imc-dispatcher:v0.13.0
      broker-controller/eventing-controller: docker.io/knative-images-repo5/broker-eventing-controller:v0.13.0
      DISPATCHER_IMAGE: docker.io/knative-images-repo5/DISPATCHER_IMAGE:v0.13.0
```

### Download images with secrets:

If you use the default or override attributes to define image links, and the image links require private secrets for
access, you must append the `imagePullSecrets` attribute.

This example uses a secret named `regcred`. You must create your own private secrets if these are required. After you
create this secret, edit your operator CR by appending the content below ...:

```
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

The field `imagePullSecrets` expects a list of secrets. You can add multiple secrets to access the images as below:

```
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

## Configuring default broker class

Knative Eventing support two types of default broker classes: `ChannelBasedBroker` and `MTChannelBasedBroker`. It is can
be specified with the field called `defaultBrokerClass`. If this field is left empty, `ChannelBasedBroker` will be taken
as the broker class. If we would like to specify the default broker class to `MTChannelBasedBroker`, the Eventing
Operator CR should be:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  defaultBrokerClass: MTChannelBasedBroker
```
