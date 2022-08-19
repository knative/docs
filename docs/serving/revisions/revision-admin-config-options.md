# Administrator configuration options

If you have cluster administrator permissions for your Knative installation, you can modify ConfigMaps to change the global default configuration options for Revisions of Knative Services on the cluster.

## Garbage collection

--8<-- "about-revisions-garbage-collection.md"

You can set cluster-wide garbage collection configurations for your cluster by modifying the `config-gc` ConfigMap.

The following garbage collection settings can be modified:

Name|Description
-|-
`retain-since-create-time`| The time that must have elapsed since a Revision was created before a Revision is considered for garbage collection.
`retain-since-last-active-time`| The time that must have elapsed since a Revision was last active before a Revision is considered for garbage collection.
`min-non-active-revisions`| The minimum number of inactive Revisions to retain.
`max-non-active-revisions`| The maximum number of inactive Revisions to retain.

Revisions are always retained if they belong to any one of the following categories:

- The Revision is active and is being reference by a Route.
- The Revision was created within the time specified by the `retain-since-create-time` setting.
- The Revision was last referenced by a Route within the time specified by the `retain-since-last-active-time` setting.
- There are fewer existing Revisions than the number specified by the `min-non-active-revisions` setting.

### Examples

- Immediately clean up any inactive Revisions:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-gc
      namespace: knative-serving
    data:
      min-non-active-revisions: "0"
      max-non-active-revisions: "0"
      retain-since-create-time: "disabled"
      retain-since-last-active-time: "disabled"
    ...
    ```

- Retain the last ten inactive revisions:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-gc
      namespace: knative-serving
    data:
      retain-since-create-time: "disabled"
      retain-since-last-active-time: "disabled"
      max-non-active-revisions: "10"
    ...
    ```

- Disable garbage collection on the cluster:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-gc
      namespace: knative-serving
    data:
      retain-since-create-time: "disabled"
      retain-since-last-active-time: "disabled"
      max-non-active-revisions: "disabled"
    ...
    ```
