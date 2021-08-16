# Exclude namespaces from the Knative webhook

The Knative webhook examines resources that are created, read, updated, or deleted. This includes system namespaces, which can cause issues during an upgrade if the webhook becomes non-responsive. Cluster administrators may want to disable the Knative webhook on system namespaces to prevent issues during upgrades.

You can configure the label `webhooks.knative.dev/exclude` to allow namespaces to bypass the Knative webhook.

``` yaml
apiVersion: v1
kind: Namespace
metadata:
  name: knative-dev
  labels:
    webhooks.knative.dev/exclude: "true"
```
