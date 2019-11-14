---
title: "Checking the version of your Knative components"
linkTitle: "Checking your install version"
weight: 20
type: "docs"
---

## Knative Serving

To query the version of Knative Serving running on the cluster enter the
following command:

```bash
kubectl get namespace knative-serving -o 'go-template={{index .metadata.labels
"serving.knative.dev/release"}}'
```

## Knative Eventing

To query the version of Knative Eventing running on the cluster enter the
following command:

```bash
kubectl get namespace knative-eventing -o 'go-template={{index .metadata.labels
"eventing.knative.dev/release"}}'
```


## Older versions

Early versions of Knative Eventing and Serving do not have release version
labels on the components. Release labels were added in:

* Knative Serving 0.4.0
* Knative Eventing 0.7.0

If you have a version earlier than the versions above, the release version will not
be returned from the commands. The version will need to be determined from the
container images of your Knative controllers.

Query a Knative Controller and copy the full `gcr.io` url into into your browser. From
this page you will be able to look up the release version from the `Tags`
section.
