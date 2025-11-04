---
audience: administrator
components:
  - serving
  - eventing
function: explanation
---

# Using ConfigMaps

This page provides important information and best practices for working with Kubernetes ConfigMaps. ConfigMaps and YAML resource files are the primary means for storing configuration values in Knative.

## The _example key

ConfigMap files installed by Knative contain an `_example` key that shows the usage and purpose of a configuration key. This key does not affect Knative behavior, but contains a value which acts as a documentation comment.

If a user edits the `_example` key by mistakenly thinking their edits will have an affect, the Knative webhook server catches the error with the following alert text (using the `config-defaults` ConfigMap as a example):

```bash
error: configmaps "config-defaults" could not be patched: admission webhook "config.webhook.serving.knative.dev" denied the request: validation failed: the update modifies a key in "_example" which is probably not what you want. Instead, copy the respective setting to the top-level of the ConfigMap, directly below "data"
You can run `kubectl replace -f /var/folders/9t/yzwp6zrx765clbvl1c_dqc2r0000gn/T/kubectl-edit-2068368769.yaml` to try this update again.
```

More specifically, the edit is caught when the value of the checksum for the `_example` key is different when compared with the pod's template annotations. If the checksum is null or missing, the webhook server does not create the warning.

Accordingly, you cannot alter the contents of the `_example` key, but you can delete the `_example` key altogether or delete the annotation. 

### Example

The following example shows the abbreviated content of the `config-defaults` ConfigMap with most of the file removed except for the last four lines. The checksum is in the annotations as `Knative.dev/example-checksum: "5b64ff5c"`

```yml
apiVersion: v1
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
  . . . 
    # In environments with large number of services it is suggested
    # to set this value to `false`.
    # See https://github.com/knative/serving/issues/8498.
    enable-service-links: "false"
```

## Values propagation to Pods

When a field in a ConfigMap is changed, the effect of the change depends on how the ConfigMap is used by the application or resource uses it. Here's a breakdown:

- Immediate update in Kubernetes API - When you modify a ConfigMap (e.g., using `kubectl edit`, `kubectl apply`, or an API call), the change is immediately reflected in the Kubernetes API and stored in etcd clusters. The updated ConfigMap is available for querying instantly.
- Mounted as Volumes - If the ConfigMap is mounted as a volume in a Pod, Kubernetes automatically propagates changes to the ConfigMap to the Pod's filesystem. This process typically takes a few seconds to up to 60 seconds because of the kubelet sync interval. Applications should detect or reload these changes (e.g., by watching the file or restarting).
- Environment Variables - If the ConfigMap is used to set environment variables in a Pod, changes to the ConfigMap do not automatically propagate to the Pod. Because container values are set at container startup, pods must be deleted and recreated for the updated ConfigMap values to take effect.
- Direct API Access - If an application directly queries the ConfigMap through the Kubernetes API, it will get the updated values immediately after the change is applied.
- Special Cases - Some applications or operators, such as the `reloader` tool, can watch for ConfigMap changes and automatically trigger Pod restarts or reloads.
- If the ConfigMap is used by a controller, changes might not affect running Pods unless the change is recognized by the controller as defined by the implementation.

## Best practices

### Validate and Test Changes

- Before applying ConfigMaps, validate their syntax and content using tools like `kubeval` or `kubectl apply --dry-run=server`.
- Test ConfigMap changes in a staging environment to ensure compatibility with the application version.

### Storage and versioning

- Periodically export ConfigMaps from the cluster (`kubectl get configmap -o yaml`) and commit them to Git for recovery purposes. Include applicable version numbers in `app.properties` as needed.

- You can also define ConfigMaps in YAML or JSON files and store them in a repository like GitHub.

### Git recommendations

In addition to diligent usage of commit messages, here are some suggestions for ConfigMaps in GitHub:

- Centralize ConfigMaps: Store all ConfigMaps in a dedicated directory in your Git repository (e.g., `k8s/configmaps/`).
- Tag commits in Git with version numbers (e.g., `git tag config-v1.2.3`) to mark specific ConfigMap versions.
- Implement a GitOps workflow with tools like ArgoCD or Flux to synchronize ConfigMaps from Git to your Kubernetes cluster.
