---
audience: administrator
components:
  - serving
  - eventing
function: explanation
---
# Editing ConfigMaps

This page provides information and best practices for editing ConfigMaps. Knative usually uses ConfigMaps to manage most system-level configuration, including default values, minimum and maximum values, and names and addresses of connecting services. Because Knative is implemented as a set of controllers, Knative watches the ConfigMaps and should update behavior live shortly after the ConfigMap is updated.

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

## Value propagation

The ConfigMap change is immediate in the Kubernetes API, but its effect on Pods or applications depends on how the ConfigMap is consumed (volume, environment variables, or API) and whether the application or Pod is designed to pick up the change dynamically or requires a restart. For volumes, updates propagate within seconds, but for environment variables, a Pod restart is needed.

When a ConfigMap currently consumed in a volume is updated, projected keys are eventually updated as well. The `kubelet` checks whether the mounted ConfigMap is fresh on every periodic sync.

Kubernetes does not automatically restart Pods when a ConfigMap changes, even if the ConfigMap is referenced. You may need to trigger a rolling update (e.g., via `kubectl rollout restart`) to ensure the changes are applied to running Pods.

A ConfigMap can be either propagated by watch (default), ttl-based, or by redirecting all requests directly to the API server. Because the `kubelet` uses its local cache for getting the current value of the ConfigMap, there is a delay from the moment when the ConfigMap is updated to the moment when new keys are projected to the Pod. The total delay can be as long as the `kubelet` sync period added to the cache propagation delay. The type of the cache is configurable using the `configMapAndSecretChangeDetectionStrategy` field in the [KubeletConfiguration struct](https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/).

When a field in a ConfigMap is changed, the effect of the change depends on how the ConfigMap is used by the application or resource uses it. Here's a breakdown:

- Immediate Update in Kubernetes API - When you modify a ConfigMap (e.g., using `kubectl edit`, `kubectl apply`, or an API call), the change is immediately reflected in the Kubernetes API and stored in etcd clusters - a consistent and highly-available key value store used as Kubernetes' backing store for all cluster data. The updated ConfigMap is available for querying instantly.

- Mounted as Volumes - If the ConfigMap is mounted as a volume in a Pod, Kubernetes automatically propagates changes to the ConfigMap to the Pod's filesystem. This process typically takes a few seconds to up to 60 seconds because of the kubelet sync interval. Applications should detect or reload these changes (e.g., by watching the file or restarting).
- Environment Variables - If the ConfigMap is used to set environment variables in a Pod, changes to the ConfigMap do not automatically propagate to the Pod. Pods must be restarted (e.g., by deleting and recreating them) for the updated ConfigMap values to take effect, as environment variables are set at container startup.
- Direct API Access - If an application directly queries the ConfigMap via the Kubernetes API, it will see the updated values immediately after the change is applied.
- Special Cases - Some applications or operators (e.g., those using tools like `reloader`) can watch for ConfigMap changes and automatically trigger Pod restarts or reloads.
- If the ConfigMap is used by a controller (e.g., a Deployment), changes might not affect running Pods unless the controller reconciles the change, which depends on its implementation.

## Version control

To maintain version control of Kubernetes ConfigMap settings and the version of the object they represent, you can follow these practices.

### Store ConfigMaps as code

Define ConfigMaps in YAML or JSON files and store them in a version control system (VCS) like Git. For example:

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

- Commit these files to a Git repository to track changes over time.

### Versioning ConfigMaps in Git

- Use meaningful commit messages to describe changes to ConfigMap data (e.g., "Updated app.properties to version 1.2.4").
- Tag commits in Git with version numbers (e.g., `git tag config-v1.2.3`) to mark specific ConfigMap versions.
- Use branches for different environments (e.g., `dev`, `staging`, `prod`) or feature-specific ConfigMap changes.

### Track Object Version in ConfigMap

- Include a version field in the ConfigMap’s data to explicitly track the version of the application or configuration it represents.

    ```yaml
    data:
    app.properties: |
      version=1.2.3
      # other settings
    ```

- Alternatively, use annotations in the ConfigMap’s metadata:

    ```yaml
    metadata:
      name: my-app-config
      annotations:
        app-version: "1.2.3"
    ```

### Use GitOps for Deployment

- Implement a GitOps workflow with tools like ArgoCD or Flux to synchronize ConfigMaps from Git to your Kubernetes cluster.
- These tools detect changes in the Git repository and automatically apply them to the cluster, ensuring the deployed ConfigMap matches the versioned configuration in Git.

### Immutable ConfigMaps with Versioned Names

- Create immutable ConfigMaps by appending a version or hash to the ConfigMap name (e.g., `my-app-config-v1.2.3` or `my-app-config-abc123`).
- Update the application’s Deployment or Pod to reference the new ConfigMap version when rolling out changes.

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    spec:
      template:
        spec:
          containers:
          - name: my-app
            envFrom:
            - configMapRef:
                name: my-app-config-v1.2.3
    ```

- This approach ensures ConfigMaps are not modified in-place, preserving historical versions.

### Track Changes in Kubernetes

Enable audit logging in Kubernetes to track who modified ConfigMaps and when.

### Validate and Test Changes

- Before applying ConfigMaps, validate their syntax and content using tools like `kubeval` or `kubectl apply --dry-run=client`.
- Test ConfigMap changes in a staging environment to ensure compatibility with the application version.

### Best Practices

- Centralize ConfigMaps: Store all ConfigMaps in a dedicated directory in your Git repository (e.g., `k8s/configmaps/`).
- Use Descriptive Naming: Name ConfigMaps clearly (e.g., `app-name-environment-config`) to avoid confusion.
- Document Changes: Include a `CHANGELOG.md` in your repository to document ConfigMap updates alongside application changes.
- Backup ConfigMaps: Periodically export ConfigMaps from the cluster (`kubectl get configmap -o yaml`) and commit them to Git for recovery purposes.

