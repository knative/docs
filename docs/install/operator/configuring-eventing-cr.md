---
title: "Configuring the Eventing Operator Custom Resource"
weight: 10
type: "docs"
aliases:
- /docs/operator/configuring-eventing-cr/
---

Knative Eventing can only be configured using a private repository and private secret.

The Knative Eventing operator CR is configured similarly to the Knative Serving operator CR. For more information,
see the documentation on “[Private repository and private secret](configuring-serving-cr.md#private-repository-and-private-secrets)” in Serving operator for detailed instruction.
The difference is that Knative Eventing Operator only allows us to customize the images for all `deployment` resources:
`eventing-controller`, `eventing-webhook`, `imc-controller`, `imc-dispatcher`, and `broker-controller`. You need to
either use these names as your names of the images in the repository, or to map your image links on a one-on-one basis.

## Download images in a predefined format without secrets:

This example shows how you can define custom image links that can be defined in the CR using the simplified format
`docker.io/knative-images/${NAME}:{CUSTOM-TAG}`.

In the example below:

- the custom tag `v0.13.0` is used for all images
- all image links are accessible without using secrets
- images are defined in the accepted format `docker.io/knative-images/${NAME}:{CUSTOM-TAG}`

First, you need to make sure your images are saved in the following link:

- Image of `eventing-controller`: `docker.io/knative-images/eventing-controller:v0.13.0`.
- Image of `eventing-webhook`: `docker.io/knative-images/eventing-webhook:v0.13.0`.
- Image of `imc-controller`: `docker.io/knative-images/imc-controller:v0.13.0`.
- Image of `imc-dispatcher`: `docker.io/knative-images/imc-dispatcher:v0.13.0`.
- Image of `broker-controller`: `docker.io/knative-images/broker-controller:v0.13.0`.

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

Replace `{CUSTOM-TAG}` with the custom tag `v0.13.0`. `${NAME}` needs to map the same name of each `Deployment` resource.
The field `default` is used to define the image format for all `Deployment` resources, make sure you want to replace the
images for all `Deployment` resources in Knative Eventing with your own images, by specifying this field `default`.

## Download images from different repositories without secrets:

If your custom image links are not defined in a uniform format by default, you will need to individually include each
link in the CR.

For example, to define the list of images:

- Image of `eventing-controller`: `docker.io/knative-images-repo1/eventing-controller:v0.13.0`.
- Image of `eventing-webhook`: `docker.io/knative-images-repo2/eventing-webhook:v0.13.0`.
- Image of `imc-controller`: `docker.io/knative-images-repo3/imc-controller:v0.13.0`.
- Image of `imc-dispatcher`: `docker.io/knative-images-repo4/imc-dispatcher:v0.13.0`.
- Image of `broker-controller`: `docker.io/knative-images-repo5/broker-controller:v0.13.0`.

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
      eventing-controller: docker.io/knative-images-repo1/eventing-controller:v0.13.0
      eventing-webhook: docker.io/knative-images-repo2/eventing-webhook:v0.13.0
      imc-controller: docker.io/knative-images-repo3/imc-controller:v0.13.0
      imc-dispatcher: docker.io/knative-images-repo4/imc-dispatcher:v0.13.0
      broker-controller: docker.io/knative-images-repo5/broker-controller:v0.13.0
```

## Download images with secrets:

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
