---
title: "Checking the version of your Knative components"
linkTitle: "Checking your install version"
weight: 20
type: "docs"
---


To obtain the version of the Knative component that you have running on your cluster, you query for the 
`[component].knative.dev/release` label with the following commands:

* Knative Serving
   ```bash
   kubectl get namespace knative-serving -o 'go-template={{index .metadata.labels
   "serving.knative.dev/release"}}'
   ```

* Knative Eventing
   ```bash
   kubectl get namespace knative-eventing -o 'go-template={{index .metadata.labels
   "eventing.knative.dev/release"}}'
   ```

## Older versions

Early versions of Knative Eventing and Serving do not have release version
labels on those components. Release labels were added in the following releases:

* Knative Serving 0.4.0
* Knative Eventing 0.7.0

If you have an earlier version that excludes release labels, you must obtain the
version from the container images of your Knative controllers:

1. Query your Knative Controller to receive the `Image` URL. For example, you can run `kubectl describe deploy controller --namespace knative-serving` or `kubectl describe deploy eventing-controller --namespace knative-eventing`
1. Navigate to the full `gcr.io` URL with your browser. 
1. Review the contents for the release version from with the `Tags` section.
