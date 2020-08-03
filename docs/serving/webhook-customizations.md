---
title: "Webhook Customizations"
weight: 70
type: "docs"
---

## Exclude Namespaces from Webhook

Certain situations may come up that require bypassing the Knative Webhook in a cluster for specific namespaces. A namespace can use the label `webhooks.knative.dev/exclude` to bypass the Knative Webhook. 

``` yaml
apiVersion: v1
kind: Namespace
metadata:
  name: knative-dev
  labels: 
    webhooks.knative.dev/exclude: "true"
```