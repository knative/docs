---
title: "Checking the version of your Knative components"
linkTitle: "Checking your install version"
weight: 20
type: "docs"
---

## Knative Serving (0.4.0 and later)

If your installed version of Knative Serving is v0.4.0 or later, enter the following command:

```bash
kubectl get deploy -n knative-serving --label-columns=serving.knative.dev/release
```

This will return a list of deployments in the `knative-serving` namespace and their release versions:

```
NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE       RELEASE
activator                1         1         1            0           8s        v0.6.0
autoscaler               1         1         1            0           8s        v0.6.0
controller               1         1         1            1           6s        v0.6.0
networking-certmanager   1         1         1            1           6s        v0.6.0
networking-istio         1         1         1            1           6s        v0.6.0
webhook                  1         1         1            1           6s        v0.6.0
```

## Knative Serving (pre-0.4.0)

If your installed version of Knative Serving is earlier than v0.4.0, enter
the following command:

```bash
kubectl describe deploy controller --namespace knative-serving
```

This will return the description for the `knative-serving` controller; this
information contains the link to the container that was used to install Knative:

```yaml
---
Pod Template:
  Labels: app=controller
  Annotations: sidecar.istio.io/inject=false
  Service Account: controller
  Containers:
    controller:
      # Link to container used to run the Knative Serving controller
      Image: gcr.io/knative-releases/github.com/knative/serving/cmd/controller@sha256:59abc8765d4396a3fc7cac27a932a9cc151ee66343fa5338fb7146b607c6e306
```

Copy the full `gcr.io` link to the container and paste it into your browser. If
you are already signed in to a Google account, you'll be taken to the Google
Container Registry page for that container in the Google Cloud Platform console.
If you aren't already signed in, you'll need to sign in to a Google account
before you can view the container details.

On the container details page, you'll see a section titled "Container
classification," and in that section is a list of tags. The versions of Knative
you have installed will appear in the list as `v0.1.1`, or whatever version you
have installed:

![Shows list of tags on container details page; v0.1.1 is the Knative version and is the first tag.](../../images/knative-version.png)

## Knative Eventing

To check what version of Knative serving you have installed, enter
the following command:

```bash
kubectl describe deploy eventing-controller --namespace knative-eventing
```

This will return the description for the `knative-eventing` controller; this
information contains the link to the container that was used to install Knative:

```yaml
---
Pod Template:
  Labels:           app=eventing-controller
                    eventing.knative.dev/release=devel
  Service Account:  eventing-controller
  Containers:
   eventing-controller:
    # Link to container used to run the Knative Eventing controller
    Image:      gcr.io/knative-releases/github.com/knative/eventing/cmd/controller@sha256:85c010633944c06f4c16253108c2338dba271971b2b5f2d877b8247fa19ff5cb
```

Copy the full `gcr.io` link to the container and paste it into your browser. If
you are already signed in to a Google account, you'll be taken to the Google
Container Registry page for that container in the Google Cloud Platform console.
If you aren't already signed in, you'll need to sign in to a Google account
before you can view the container details.

On the container details page, you'll see a section titled "Container
classification," and in that section is a list of tags. The versions of Knative
you have installed will appear in the list as `v0.1.1`, or whatever version you
have installed:

![Shows list of tags on container details page; v0.1.1 is the Knative version and is the first tag.](../../images/knative-version.png)