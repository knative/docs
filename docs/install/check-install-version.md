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
  kubectl get namespace knative-serving -o 'go-template={{index .metadata.labels "serving.knative.dev/release"}}'
  ```

* Knative Eventing

  ```bash
  kubectl get namespace knative-eventing -o 'go-template={{index .metadata.labels "eventing.knative.dev/release"}}'
  ```
