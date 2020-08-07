---
title: "Webhook Customizations"
weight: 70
type: "docs"
---

## Exclude Namespaces from Webhook

A namespace can use the label `webhooks.knative.dev/exclude` to bypass the Knative Webhook.

``` yaml
apiVersion: v1
kind: Namespace
metadata:
  name: knative-dev
  labels: 
    webhooks.knative.dev/exclude: "true"
```

By default the webhook will examine resources that are created/read/updated/deleted. This includes system namespaces which can cause issues during an upgrade if the webhook is not responding.  Cluster administrators may want to disable the Knative Webhook on system namespaces to prevent issues during upgrades.