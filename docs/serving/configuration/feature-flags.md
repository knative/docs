# Feature and extension flags

The Knative API is designed to be portable, and abstracts away specific implementation details for user deployments. The intention of the API is to empower users to surface extra features and extensions that are possible within their platform of choice.

This document introduces two concepts:

Feature
: A way to stage the introduction of features to the Knative API.

Extension
: A way to extend Knative beyond the portable concepts of the Knative API.

## Configuring flags

Features and extensions are controlled by _flags_.

You can define flags in the `config-features` ConfigMap in the `knative-serving` namespace.

Flags can have the following values:

Enabled
: The feature or extension is enabled and currently in use.

Allowed
: The feature or extension is enabled and can be used, for example, by using an additional annotation or spec configuration for a resource.

Disabled
: The feature cannot be used.

## Lifecycle

When features and extensions are introduced to Knative, they follow a lifecycle of three stages:

Alpha stage
: Might contain bugs.
: Support for the feature might be dropped at any time without notice.
: The API might change in a later software release in ways that make it incompatible with older releases without notice.
: Recommended for use only in short-lived testing clusters, due to increased risk of bugs and lack of long-term support.

Beta stage
: The feature is well tested and safe to enable.
: Support for the overall feature will not be dropped, though details might change.
: The schema and semantics of objects might change in incompatible ways in a subsequent beta or stable release. If this happens, instructions are provided for migrating to the next version. These types of changes might require you to delete, modify, or re-create API objects, and might require downtime for applications that rely on the feature.
: Recommended for only non-business-critical uses because of the potential for incompatible changes in subsequent releases. If you have multiple clusters that can be upgraded independently, you might be able to relax this restriction.

General Availability (GA) stage
: Stable versions of the feature or extension are included in official, stable Knative releases.

### Feature lifecycle stages

Features use flags to safely introduce new changes to the Knative API. The following definitions explain the default implementation for features at different stages:

Alpha stage
: The feature is disabled by default, but you can manually enable it.

Beta stage
: The feature is enabled by default, but you can manually disable it.

GA stage
: The feature is always enabled; you cannot disable it.
: The corresponding feature flag is no longer needed and is removed from Knative.

### Extension lifecycle stages

An extension surfaces details of a specific Knative implementation, or features of the underlying environment.

!!! note
    Extensions are never included in the core Knative API due to their lack of portability.

Each extension is always controlled by a flag and is never enabled by default.

Alpha stage
: The feature is disabled by default, but you can manually enable it.

Beta stage
: The feature is allowed by default.

GA stage
: The feature is allowed by default.

## Available Flags

### Multiple containers

* **Type**: Feature
* **ConfigMap key:** `multi-container`

This flag allows specifying multiple user containers in a Knative Service spec.

Only one container can handle requests, so exactly one container must have a `port` specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      containers:
        - name: first-container
          image: gcr.io/knative-samples/helloworld-go
          ports:
            - containerPort: 8080
        - name: second-container
          image: gcr.io/knative-samples/helloworld-java
```

### Kubernetes EmptyDir Volume

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-volumes-emptydir`

This extension controls whether [`emptyDir`](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) volumes can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      containers:
          ...
          volumeMounts:
            - name: cache
              mountPath: /cache
      volumes:
        - name: cache
          emptyDir: {}
```

### Kubernetes PersistentVolumeClaim (PVC)

* **Type**: Extension
* **ConfigMap keys:** `kubernetes.podspec-persistent-volume-claim` <br/> `kubernetes.podspec-persistent-volume-write`

This extension controls whether [`PersistentVolumeClaim (PVC)`](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) can be specified
and whether write access is allowed for the corresponding volume.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
 template:
   spec:
     containers:
         ...
         volumeMounts:
           - mountPath: /data
             name: mydata
             readOnly: true
     volumes:
       - name: mydata
         persistentVolumeClaim:
           claimName: minio-pv-claim
           readOnly: true
```

### Kubernetes node affinity

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-affinity`

This extension controls whether [node affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/e2e-az-name
                operator: In
                values:
                - e2e-az1
                - e2e-az2
```

### Kubernetes host aliases

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-hostaliases`

This flag controls whether [host aliases](https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/) can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      hostAliases:
      - ip: "127.0.0.1"
        hostnames:
        - "foo.local"
        - "bar.local"
```

### Kubernetes node selector

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-nodeselector`

This flag controls whether [node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      nodeSelector:
        labelName: labelValue
```

### Kubernetes toleration

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-tolerations`

This flag controls whether [tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      tolerations:
      - key: "example-key"
        operator: "Exists"
        effect: "NoSchedule"
```

### Kubernetes Downward API

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-fieldref`

This flag controls whether the [Downward API (environment variable based)](https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/) can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      containers:
        - name: user-container
          image: gcr.io/knative-samples/helloworld-go
          env:
            - name: MY_NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
```

### Kubernetes priority class name

- **Type**: extension
- **ConfigMap key:** `kubernetes.podspec-priorityclassname`

This flag controls whether the [`priorityClassName`](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#pod-priority) can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      priorityClassName: high-priority
...
```

### Kubernetes dry run

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-dryrun`

This flag controls whether Knative attempts to validate the Pod spec derived from a Knative Service spec, by using the Kubernetes API server before accepting the object.

When this extension is `enabled`, the server always runs this validation.

When this extension is `allowed`, the server does not run this validation by default.

When this extension is `allowed`, you can run this validation for individual Services, by adding the `features.knative.dev/podspec-dryrun: enabled` annotation:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  annotations: features.knative.dev/podspec-dryrun: enabled
...
```

### Kubernetes runtime class

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-runtimeclassname`

This flag controls whether the [runtime class](https://kubernetes.io/docs/concepts/containers/runtime-class/) can be used.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      runtimeClassName: myclass
...
```

### Kubernetes security context

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-securitycontext`

This flag controls whether a subset of the [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) can be used.

When set to `enabled` or `allowed`, the following `PodSecurityContext` properties are permitted:

- FSGroup
- RunAsGroup
- RunAsNonRoot
- SupplementalGroups
- RunAsUser

When set to `enabled` or `allowed`, the following container `SecurityContext` properties are permitted:

- `RunAsNonRoot` (also allowed without this flag only when set to true)
- `RunAsGroup`
- `RunAsUser` (already allowed without this flag)

!!! warning
    Use this flag with caution. `PodSecurityContext` properties can affect non-user sidecar containers that come from Knative or your service mesh.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      securityContext:
        runAsUser: 1000
...
```

### Kubernetes security context capabilities

* **Type**: Extension
* **ConfigMap key**: `kubernetes.containerspec-addcapabilities`

This flag controls whether users can add capabilities on the `securityContext` of the container.

When set to `enabled` or `allowed` it allows [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) to be added to the container.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
spec:
 template:
  spec:
   containers:
     - image: gcr.io/knative-samples/helloworld-go
       env:
         - name: TARGET
           value: "Go Sample v1"
       securityContext:
         capabilities:
           add:
             - NET_BIND_SERVICE
```

### Tag header based routing

* **Type**: Extension
* **ConfigMap key:** `tag-header-based-routing`

This flags controls whether [tag header based routing](https://github.com/knative/docs/tree/main/code-samples/serving/tag-header-based-routing) is enabled.

### Kubernetes init containers

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-init-containers`

This flag controls whether [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) can be used.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      ...
      initContainers:
        - name: init-myservice
          image: busybox
          command: ['sh', '-c', "service_setup.sh"]
...
```

### Queue Proxy Pod Info

* **Type**: Extension
* **ConfigMap key:** `queueproxy.mount-podinfo`

You must set this feature to either "enabled or "allowed" when using QPOptions. The flag controls whether Knative mounts the `pod-info` volume to the `queue-proxy` container.

Mounting the `pod-info` volume allows extensions that use QPOptions to access the Service annotations, by reading the `/etc/podinfo/annnotations` file. See [Extending Queue Proxy image with QPOptions](../queue-extensions.md) for more details.

When this feature is `enabled`, the `pod-info` volume is always mounted. This is helpful in case where all or most of the cluster Services are required to use extensions that rely on QPOptions.

When this feature is `allowed`, the `pod-info` volume is not mounted by default. Instead, the volume is mounted only for Services that add the `features.knative.dev/queueproxy-podinfo: enabled` annotation as shown below:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  annotations: features.knative.dev/queueproxy-podinfo: enabled
...
```

### Kubernetes Topology Spread Constraints

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-topologyspreadconstraints`

This flag controls whether [`topology spread constraints`](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      ...
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: node
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            foo: bar
...
```

### Kubernetes DNS Policy

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-dnspolicy`

This flag controls whether a [`DNS policy`](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) can be specified.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      dnsPolicy: ClusterFirstWithHostNet
...
```

### Kubernetes Scheduler Name

* **Type**: Extension
* **ConfigMap key:** `kubernetes.podspec-schedulername`

This flag controls whether a [`scheduler name`](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) can be specified.
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
...
spec:
  template:
    spec:
      ...
      schedulerName: custom-scheduler-example
...
```
