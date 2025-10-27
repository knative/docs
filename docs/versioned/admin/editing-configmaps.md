---
audience: administrator
components:
  - serving
  - eventing
function: explanation
---
# Editing ConfigMaps

This page provides information and best practices for editing ConfigMaps. Knative uses ConfigMaps to manage most system-level configuration, including default values, minimum and maximum values, and names and addresses of connecting services. Because Knative is implemented as a set of controllers, Knative watches the ConfigMaps and updates behavior live shortly after the ConfigMap is updated.

## Configurations overview

### Knative Operator and YAML installations

To be written.

### Brokers

When creating a Broker class, you can define default values and settings on different levels of scope. You can specify a ConfigMap that defines the implementation of the Broker, and apply it in different ways.

Knative uses `MTChannelBasedBroker` as the default class for creating Brokers. On the more wider level of scope, you can specify which Broker class to use for a particular namespace.

To create a customized Broker class, you can do either or both of the following:

- For a scope on a cluster wide or on a per namespace basis, use the `config-br-defaults` ConfigMap or the `kafka-channel` ConfigMap to define default values for the Broker. These ConfigMaps are used when a  `spec.config` is *not* the class. For example, use this method if you want to use a `KafkaBroker` Broker class for all other Brokers created on the cluster, but a particular Broker class for Brokers created in `namespace-1`. In the `config-br-defaults` ConfigMap, set the default Broker configuration for one or more dedicated namespaces by including them in the `namespaceDefaults` section.

- Specify a ConfigMap to use in the `spec.config` keys in the Broker class you're defining. That ConfigMap must have a `channel-template-spec` that defines the channel implementation for the Broker.

Set other default configurations for Brokers with these ConfigMaps:

- `config-features` - Defines defaults for features including integration, sender identity, and transport encryption.
- `default-ch-webhook` - Defines default channel implementation settings.
- `config-kafka-sink-data-plane` - Used for sending events to the Apache Kafka cluster.
- `config-ping-defaults` - Defines event resources, such as the the maximum amount of data PingSource can add to cloud events.
- `sugar-controller` - Manages eventing resources in a cluster or namespace. Disable Sugar Controller by setting `namespace-selector` and `trigger-selector` to an empty string.

### Observability and logging

To be written.

### Deployments and resources

To be written.

### Networking and domains

To be written.

### Security

To be written.

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
- Use Descriptive Naming: Name ConfigMaps cn
 
- learly (e.g., `app-name-environment-config`) to avoid confusion.
- Document Changes: Include a `CHANGELOG.md` in your repository to document ConfigMap updates alongside application changes.
- Backup ConfigMaps: Periodically export ConfigMaps from the cluster (`kubectl get configmap -o yaml`) and commit them to Git for recovery purposes.

