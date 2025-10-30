---
audience: administrator
components:
  - serving
  - eventing
function: explanation
---

# Working with ConfigMaps

This page provides important information and best practices for working with Kubernetes ConfigMaps.

## The _example key

ConfigMap files installed by Knative contain an `_example` key that shows the usage and purpose of a configuration key. This key does not affect Knative behavior, but contains a value which acts as a documentation comment.

In case a user edits the `_example` key by mistakenly thinking their edits would have an affect, the administrator needs to be alerted. The Knative webhook server determines if the `_example key` has been altered. The edit is caught when the value of the checksum for the `_example` key is different when compared with the pod's template annotations. If the checksum is null however, it does not create the warning.

Accordingly, you cannot alter the contents of the `_example` key, but you can delete the `_example` key altogether or delete the annotation:

```yml
...
annotations:
    knative.dev/example-checksum: "47c2487f"
```

To accurately create a ConfigMap using an existing file, use the Kubernetes[Define the key to use when creating a configmap from a file](https://kubernetes.io/dos/tasks/configure-pod-container/configure-pod-configmap/#define-the-key-to-use-when-creating-a-configmap-from-a-file)

## Monitoring values

When a field in a ConfigMap is changed, the effect of the change depends on how the ConfigMap is used by the application or resource uses it. Here's a breakdown:

- Immediate Update in Kubernetes API - When you modify a ConfigMap (e.g., using `kubectl edit`, `kubectl apply`, or an API call), the change is immediately reflected in the Kubernetes API and stored in etcd clusters - a consistent and highly-available key value store used as Kubernetes' backing store for all cluster data. The updated ConfigMap is available for querying instantly.
- Mounted as Volumes - If the ConfigMap is mounted as a volume in a Pod, Kubernetes automatically propagates changes to the ConfigMap to the Pod's filesystem. This process typically takes a few seconds to up to 60 seconds because of the kubelet sync interval. Applications should detect or reload these changes (e.g., by watching the file or restarting).
- Environment Variables - If the ConfigMap is used to set environment variables in a Pod, changes to the ConfigMap do not automatically propagate to the Pod. Pods must be restarted (e.g., by deleting and recreating them) for the updated ConfigMap values to take effect, as environment variables are set at container startup.
- Direct API Access - If an application directly queries the ConfigMap via the Kubernetes API, it will see the updated values immediately after the change is applied.
- Special Cases - Some applications or operators (e.g., those using tools like `reloader`) can watch for ConfigMap changes and automatically trigger Pod restarts or reloads.
- If the ConfigMap is used by a controller (e.g., a Deployment), changes might not affect running Pods unless the controller reconciles the change, which depends on its implementation.

## Best practices

This section provides recommended procedures for storage, monitoring, and version control of ConfigMaps.

### Validate and Test Changes

- Before applying ConfigMaps, validate their syntax and content using tools like `kubeval` or `kubectl apply --dry-run=server`.
- Test ConfigMap changes in a staging environment to ensure compatibility with the application version.

### Storage and versioning

Periodically export ConfigMaps from the cluster (`kubectl get configmap -o yaml`) and commit them to Git for recovery purposes. Include applicable version numbers in `app.properties` as needed.

You can also define ConfigMaps in YAML or JSON files and store them in a version control system (VCS) like Git. For example:

    ```yml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: my-app-config
      namespace: default
    data:
      _example | ...
      app.properties: |
        version=1.2.3
        db.host=localhost
        db.port=5432
    ```

### Git recommendations

In addition to diligent usage of commit messages, here are some suggestions for ConfigMaps in GitHub:

- Centralize ConfigMaps: Store all ConfigMaps in a dedicated directory in your Git repository (e.g., `k8s/configmaps/`).
- Tag commits in Git with version numbers (e.g., `git tag config-v1.2.3`) to mark specific ConfigMap versions.
- Implement a GitOps workflow with tools like ArgoCD or Flux to synchronize ConfigMaps from Git to your Kubernetes cluster.
- These tools detect changes in the Git repository and automatically apply them to the cluster, ensuring the deployed ConfigMap matches the versioned configuration in Git.

