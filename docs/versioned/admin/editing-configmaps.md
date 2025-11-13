---
audience: administrator
components:
  - serving
  - eventing
function: explanation
---

# Working with ConfigMaps

This page provides important Knative-specific information and best practices for managing cluster configuration using ConfigMaps. ConfigMaps are the primary means for managing configuration values for Knative controllers.

If you are using the Knative Operator to install and manage your Knative cluster, you should not edit the ConfigMaps directly as the Operator will overwrite the changes. See [Configuring Knative by using the Operator](../install/operator/configuring-with-operator.md) for information on how to manage ConfigMaps using the operator.

## The _example key

ConfigMap files installed by Knative contain an `_example` key that shows the usage and purpose of all the known configuration keys in that ConfigMap. This key does not affect Knative behavior, but contains a value which acts as a documentation comment.

If a user edits the `_example` key by mistakenly thinking their edits don't effect on the cluster operation, the Knative webhook catches the error and alerts the user that their update could not be patched. More specifically, the edit is caught when the value of the checksum for the `_example` key is different when compared with the `knative.dev/example-checksum` annotation on the ConfigMap. If the checksum is null or missing, the webhook server does not create the warning.

Accordingly, you cannot alter the contents of the `_example` key, but you can delete the `_example` key altogether or delete the annotation.

For example, the following YAML code shows the first 24 lines of the `config-defaults` ConfigMap with the checkum highlighted.

```yml linenums="1" hl_lines="11"
piVersion: v1
kind: ConfigMap
metadata:
  name: config-defaults
  namespace: knative-serving
  labels:
    app.kubernetes.io/name: knative-serving
    app.kubernetes.io/component: controller
    app.kubernetes.io/version: devel
  annotations:
    knative.dev/example-checksum: "5b64ff5c"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
```

## Best practices

### Validate and Test Changes

Knative controllers process new values, including roll-backs to previous values, within a few seconds after being applied. 

- Before applying ConfigMaps, validate their syntax and content using tools like `kubeval` or `kubectl apply --dry-run=server`.
- Test ConfigMap changes in a staging environment to ensure compatibility with the application version.

### Storage and versioning

How you manage storage relates the canonical locations of both the cluster and Git. If your cluster is canonical, then you're exporting or backing up the configuration to Git. If Git is canonical, then you're practicing GitOps, and you should make changes in Git and then apply the files from Git to your cluster.

If you manage the ConfigMap by using `kubectl edit`, periodically export ConfigMaps from the cluster (`kubectl get configmap -o yaml`) and commit them to Git for recovery purposes. Include applicable version numbers in `app.properties` as needed.

If you manage the ConfigMap by keeping the definition in Git and automatically applying it to the cluster (GitOps), you can apply the changes manually  sor use automation (for example Flux or ArgoCD) to apply the changes once they are committed.

### Git recommendations

In addition to diligent usage of commit messages, here are some suggestions for ConfigMaps in GitHub:

- Centralize ConfigMaps: Store all ConfigMaps in a dedicated directory in your Git repository (e.g., `k8s/configmaps/`).
- Tag commits in Git with version numbers (e.g., `git tag config-v1.2.3`) to mark specific ConfigMap versions.
- Implement a GitOps workflow with tools like ArgoCD or Flux to synchronize ConfigMaps from Git to your Kubernetes cluster.
