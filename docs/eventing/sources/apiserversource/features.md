# ApiServerSource features

ApiServerSource has features that can be added using annotations to the resource definition.

## Skipping Permissions Check

When the ApiServerSource resource is changed, Knative Eventing checks that it has the required
permissions for the resources and namespaces defined before updating the ApiServerSource Deployment.
On large clusters checking for permissions can put pressure on the Kubernetes API leading to
resource pressure. To make the ApiServerSource skip permissions set the following annotation:

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
  name: <apiserversource>
  namespace: <namespace>
  annotations:
    features.knative.dev/apiserversource-skip-permissions: "true"
spec:
  ...
```

This makes the ApiServerSource Deployment fail if any of the watches fails to start.
