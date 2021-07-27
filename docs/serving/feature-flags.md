---
title: "Feature/Extension Flags"
weight: 50
type: "docs"
---

# Feature/Extension Flags

Knative is deliberate about the concepts it incorporates into its core API. The API aims to be portable and abstracts away the specificities of each users' implementation. That being said, the Knative API should empower users to surface extra features and extensions possible within their platform of choice.

This document introduces two concepts:
* Feature: a way to stage the introduction of features to the Knative API.
* Extension: a way to extend Knative beyond the portable concepts of the Knative API.

## Control
Features and extensions are controlled by flags defined in the `config-features` ConfigMap in the `knative-serving` namespace.
Flags can have the following values:
* Enabled: the feature is enabled.
* Allowed: the feature may be enabled (e.g. using an annotation or looser validation).
* Disabled: the feature cannot be enabled.

These three states don't make sense for all features.
Let's consider two types of features: `multi-container` and `kubernetes.podspec-dryrun`.

`multi-container` allows the user to specify more than one container in the Knative Service spec. In this case, `Enabled` and `Allowed` are equivalent because using this feature requires to actually use it in the Knative Service spec. If a single container is specified, whether the feature is enabled or not doesn't change anything.

`kubernetes.podspec-dryrun` changes the behavior of the Kubernetes implementation of the Knative API, but it has nothing to do with the Knative API itself. In this case, `Enabled` means the feature will be enabled unconditionally, `Allowed` means that the feature will be enabled only when specified with an annotation, and `Disabled` means that the feature cannot be used at all.

## Lifecyle
Features and extensions go through 3 similar phases (Alpha, Beta, GA) but with important differences.

Alpha means:
* Might be buggy. Enabling the feature may expose bugs.
* Support for feature may be dropped at any time without notice.
* The API may change in incompatible ways in a later software release without notice.
* Recommended for use only in short-lived testing clusters, due to increased risk of bugs and lack of long-term support.

Beta means:
* The feature is well tested. Enabling the feature is considered safe.
* Support for the overall feature will not be dropped, though details may change.
* The schema and/or semantics of objects may change in incompatible ways in a subsequent beta or stable release. When this happens, we will provide instructions for migrating to the next version. This may require deleting, editing, or re-creating API objects. The editing process may require some thought. This may require downtime for applications that rely on the feature.
* Recommended for only non-business-critical uses because of potential for incompatible changes in subsequent releases. If you have multiple clusters that can be upgraded independently, you may be able to relax this restriction.

General Availability (GA) means:
* Stable versions of features/extensions will appear in released software for many subsequent versions.

# Feature
Features use flags to safely introduce new changes to the Knative API. Eventually, each feature will graduate to become fully part of the Knative API, and the flag guard will be removed.

## Alpha
* Disabled by default.

## Beta
* Enabled by default.

## GA
* The feature is always enabled; you cannot disable it.
* The corresponding feature flag is no longer needed.

# Extension
An extension may surface details of a specific Knative implementation or features of the underlying environment. It is never intended for inclusion in the core Knative API due to its lack of portability. Each extension will always be controlled by a flag and never enabled by default.

## Alpha
* Disabled by default.

## Beta
* Allowed by default.

## GA
* Allowed by default.

# Available Flags

## Multi Containers
* **Type**: feature
* **ConfigMap key:** `multi-container`

This flag allows specifying multiple "user containers" in a Knative Service spec.
Only one container can handle the requests, and therefore exactly one container must
have a `port` specified.

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

## Kubernetes Node Affinity
* **Type**: extension
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

## Kubernetes Host Aliases
* **Type**: extension
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

## Kubernetes Node Selector
* **Type**: extension
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

## Kubernetes Toleration
* **Type**: extension
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

## Kubernetes FieldRef
* **Type**: extension
* **ConfigMap key:** `kubernetes.podspec-fieldref`

This flag controls whether the [Downward API (env based)](https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/) can be specified.

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

## Kubernetes Dry Run
* **Type**: extension
* **ConfigMap key:** `kubernetes.podspec-dryrun`

This flag controls whether Knative will try to validate the Pod spec derived from the Knative Service spec using the Kubernetes API server before accepting the object.

When "enabled", the server will always run the extra validation.
When "allowed", the server will not run the dry-run validation by default.
However, clients may enable the behavior on an individual Service by
attaching the following metadata annotation: "features.knative.dev/podspec-dryrun":"enabled".

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  annotations: features.knative.dev/podspec-dryrun":"enabled
...
spec:
  template:
    spec:
    ...
```

## Kubernetes Runtime Class
* **Type**: extension
* **ConfigMap key:** `kubernetes.podspec-runtimeclass`

This flag controls whether the [runtime class](https://kubernetes.io/docs/concepts/containers/runtime-class/) can be used or not.

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

## Kubernetes Security Context
* **Type**: extension
* **ConfigMap key:** `kubernetes.podspec-securitycontext`

This flag controls whether a subset of the [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) can be used.

When set to "enabled" or "allowed" it allows the following
PodSecurityContext properties:
- FSGroup
- RunAsGroup
- RunAsNonRoot
- SupplementalGroups
- RunAsUser

When set to "enabled" or "allowed" it allows the following
Container SecurityContext properties:
- RunAsNonRoot (also allowed without this flag only when set to true)
- RunAsGroup
- RunAsUser (already allowed without this flag)

This flag should be used with caution as the PodSecurityContext
properties may have a side-effect on non-user sidecar containers that come
from Knative or your service mesh

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

## Kubernetes Security Context Capabilities

* **Type**: extension
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

## Tag Header Based Routing
* **Type**: extension
* **ConfigMap key:** `tag-header-based-routing`

This flags controls whether [tag header based routing](./samples/tag-header-based-routing/) is enabled.
