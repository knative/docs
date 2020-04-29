# Knative Serving API Specification

Authors: [argent@google.com](mailto:argent@google.com),
[dangerd@google.com](mailto:dangerd@google.com)

<table>
  <tr>
   <td><p style="text-align: right">
<strong>Status</strong></p>

   </td>
   <td><p style="text-align: right">
APPROVED</p>

   </td>
  </tr>
  <tr>
   <td><p style="text-align: right">
<strong>Created</strong></p>

   </td>
   <td><p style="text-align: right">
2019-06-24</p>

   </td>
  </tr>
  <tr>
   <td><p style="text-align: right">
<strong>Last Updated</strong></p>

   </td>
   <td><p style="text-align: right">
2019-11-04</p>

   </td>
  </tr>
  <tr>
   <td><p style="text-align: right">
<strong>Version</strong></p>
   </td>
   <td> 1.0.1  </td>
  </tr>
</table>

# Abstract

The Knative serving platform provides common abstractions for managing
request-driven, short-lived, stateless compute resources in the style of common
FaaS and PaaS offerings. This document describes the structure, lifecycle and
management of Knative resources in the context of the
[Kubernetes Resource Model](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/resource-management.md).
An understanding of the Kubernetes API interface and the capabilities of
[Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
is assumed. The Knative Serving API surface aims to support the following
additional constraints beyond the general Kubernetes model:

- Client-side orchestration should not be required for common operations such as
  deployment, rollback, or simple imperative updates ("change environment
  variable X").
- Both declarative (aka GitOps) and imperative (command-driven) management of
  resources should be usable, though not on the same resources at the same time.
  (I.e. one application may use a checked-in configuration which is
  automatically pushed, while a different application may be pushed and updated
  by hand with the authoritative state living on the server.)
- Developers can effectively use the Knative Serving stack without needing to
  engage beyond the core Knative resource model. Conversely, platform operators
  may restrict developers (e.g. via RBAC) to only be able to operate on the core
  Knative Serving resources, and may provide additional abstractions to manage
  platform-specific settings.
- The Knative Serving API may be deployed in a single-tenant or multi-tenant
  environment; it is assumed that developers may not have access to multiple
  namespaces or any cluster-level resources.

This document does not define the
[runtime contract (see this document)](https://github.com/knative/serving/blob/master/docs/runtime-contract.md)
nor prescribe specific implementations of supporting services such as access
control, observability, or resource management.

This document makes reference in a few places to different profiles for Knative
Serving installations. A profile in this context is a set of operations,
resources, and fields that are accessible to a developer interacting with a
Knative installation. Currently, only a single (minimal) profile for Knative
Serving is defined, but additional profiles may be defined in the future to
standardize advanced functionality. A minimal profile is one that implements all
of the "MUST", "MUST NOT", and "REQUIRED" conditions of this document.

# Background

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" are to be
interpreted as described in [RFC 2119](https://tools.ietf.org/html/rfc2119).

There is no formal specification of the Kubernetes API and Resource Model. This
document assumes Kubernetes 1.13 behavior; this behavior will typically be
supported by many future Kubernetes versions. Additionally, this document may
reference specific core Kubernetes resources; these references may be
illustrative (i.e. _an implementation on Kubernetes_) or descriptive (i.e. _this
Kubernetes resource MUST be exposed_). References to these core Kubernetes
resources will be annotated as either illustrative or descriptive.

This document considers two users of a given Knative Serving environment, and is
particularly concerned with the expectations of developers (and language and
tooling developers, by extension) deploying applications to the environment.

- **Developers** write code which is packaged into a container which is run on
  the Knative Serving cluster.
  - **Language and tooling developers** typically write tools used by developers
    to package code into containers. As such, they are concerned that tooling
    which wraps developer code to produce resources which match the Knative API
    contract.
- **Operators** (also known as **platform providers**) provision the compute
  resources and manage the software configuration of Knative Serving and the
  underlying abstractions (for example: Linux, Kubernetes, Istio, etc).

# RBAC Profile

In order to validate the controls described in
[Resource Overview](#resource-overview), the following Kubernetes RBAC profile
may be applied in a Kubernetes cluster. This Kubernetes RBAC is an illustrative
example of the minimal profile rather than a requirement. This Role should be
sufficient to develop, deploy, and manage a set of serving applications within a
single namespace. Knative Conformance tests against "MUST", "MUST NOT", and
"REQUIRED" conditions are expected to pass when using this profile:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: knative-developer
rules:
  - apiGroups: ["serving.knative.dev"]
    resources: ["services"]
    verbs: ["get", "list", "create", "update", "delete"]
  - apiGroups: ["serving.knative.dev"]
    resources: ["configurations", "routes", "revisions"]
    verbs: ["get", "list"]
```

# Resource Overview

The Knative Serving API provides a set of
[Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
to manage stateless request-triggered (i.e. on-demand) autoscaled containers.
Knative Serving assumes the use of HTTP (including HTTP/2 and layered protocols
such as [gRPC](https://grpc.io/)) as a request transport. In addition to
low-level scaling and routing objects, Knative Serving provides a high-level
Service object to reduce the cognitive overhead for application developers – the
Service object should provide sufficient controls to cover most of application
deployment scenarios (by frequency).

## Service

The Knative Service represents an instantiation of a single serverless container
environment (e.g. a microservice) over time. As such, a Service includes both a
network address by which the Service may be reached as well as the application
code and configuration needed to run the Service. The following table details
which operations must be made available to a developer accessing a Knative
Service using a minimal profile:

<table>
  <tr>
   <td><strong>API Operation</strong>
   </td>
   <td><strong>Developer Access Requirements</strong>
   </td>
  </tr>
  <tr>
   <td>Create (POST)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>Patch (<a href="https://github.com/kubernetes/kubernetes/blob/release-1.1/docs/devel/api-conventions.md#patch-operations">PATCH</a>)^
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td>Replace (PUT)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>Delete (DELETE)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>Read (GET)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>List (GET)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>Watch (GET)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>DeleteCollection (DELETE)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
</table>

^ Kubernetes only allows JSON merge patch for CRD types. It is recommended that
if allowed, at least JSON Merge patch be made available.
[JSON Merge Patch Spec (RFC 7386)](https://tools.ietf.org/html/rfc7386)

## Revision

The Knative Revision represents a stateless, autoscaling snapshot-in-time of
application code and configuration. Revisions enable progressive rollout and
rollback of application changes by changing the HTTP routing between Service
names and Revision instances. As such, Revisions are generally immutable, except
where they may reference mutable core Kubernetes resources such as ConfigMaps
and Secrets. Revisions can also be mutated by changes in Revision defaults.
Changes to defaults that mutate Revisions are generally syntactic and not
semantic.

Developers MUST NOT be able to create Revisions or update Revision `spec`
directly; Revisions MUST be created in response to updates to a Configuration
`spec`. It is RECOMMENDED that developers are able to force the deletion of
Revisions to both handle the possibility of leaked resources as well as for
removal of known-bad Revisions to avoid future errors in managing the service.

The following table details which operations must be made available to a
developer accessing a Knative Revision using a minimal profile:

<table>
  <tr>
   <td><strong>API Operation</strong>
   </td>
   <td><strong>Developer Access Requirements</strong>
   </td>
  </tr>
  <tr>
   <td>Create (POST)
   </td>
   <td>FORBIDDEN
   </td>
  </tr>
  <tr>
   <td>Patch (<a href="https://github.com/kubernetes/kubernetes/blob/release-1.1/docs/devel/api-conventions.md#patch-operations">PATCH</a>)^
   </td>
   <td>OPTIONAL (<code>spec</code> disallowed)
   </td>
  </tr>
  <tr>
   <td>Replace (PUT)
   </td>
   <td>OPTIONAL (<code>spec</code> changes disallowed)
   </td>
  </tr>
  <tr>
   <td>Delete (DELETE)
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td>Read (GET)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>List (GET)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>Watch (GET)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>DeleteCollection (DELETE)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
</table>

^ Kubernetes only allows JSON merge patch for CRD types. It is recommended that
if allowed, at least JSON Merge patch be made available.
[JSON Merge Patch Spec (RFC 7386)](https://tools.ietf.org/html/rfc7386)

## Route

The Knative Route represents the current HTTP request routing state against a
set of Revisions. To enable progressive rollout of serverless applications, a
Route supports percentage-based request distribution across multiple application
code and configuration states (Revisions).

Routes which are owned (controlled) by a Service SHOULD NOT be updated by
developers; any changes will be reset by the Service controller.

The table below details which operations must be made available to a developer
accessing a Knative Route using a minimal profile. For any non-minimal profile,
the POST, PUT, or DELETE operations MUST be enabled as a group. This ensures
that the developer has the ability to control the complete lifecycle of the
object from create through deletion.

<table>
  <tr>
   <td><strong>API Operation</strong>
   </td>
   <td><strong>Developer Access Requirements</strong>
   </td>
  </tr>
  <tr>
   <td>Create (POST)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>Patch (<a href="https://github.com/kubernetes/kubernetes/blob/release-1.1/docs/devel/api-conventions.md#patch-operations">PATCH</a>)^
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>Replace (PUT)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>Delete (DELETE)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>Read (GET)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>List (GET)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>Watch (GET)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>DeleteCollection (DELETE)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
</table>

^ Kubernetes only allows JSON merge patch for CRD types. It is recommended that
if allowed, at least JSON Merge patch be made available.
[JSON Merge Patch Spec (RFC 7386)](https://tools.ietf.org/html/rfc7386)

## Configuration

The Knative Configuration represents the desired future state (after deployments
complete) of a single autoscaled container application and configuration. The
Configuration provides a template for creating Revisions as the desired state of
the application changes.

Configurations which are owned (controlled) by a Service SHOULD NOT be updated
by developers; any changes will be reset by the Service controller. These
changes MAY still generate side effects such as the creation of additional
Revisions.

The table below details which operations must be made available to a developer
accessing a Knative Configuration using a minimal profile. For any advanced
profile, the POST, PUT, or DELETE operations MUST be enabled as a group. This
ensures that the developer has the ability to control the complete lifecycle of
the object from create through deletion.

<table>
  <tr>
   <td><strong>API Operation</strong>
   </td>
   <td><strong>Developer Access Requirements</strong>
   </td>
  </tr>
  <tr>
   <td>Create (POST)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>Patch (<a href="https://github.com/kubernetes/kubernetes/blob/release-1.1/docs/devel/api-conventions.md#patch-operations">PATCH</a>)^
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>Replace (PUT)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>Delete (DELETE)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>Read (GET)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>List (GET)
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td>Watch (GET)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
  <tr>
   <td>DeleteCollection (DELETE)
   </td>
   <td>OPTIONAL
   </td>
  </tr>
</table>

^ Kubernetes only allows JSON merge patch for CRD types. It is recommended that
if allowed, at least JSON Merge patch be made available.
[JSON Merge Patch Spec (RFC 7386)](https://tools.ietf.org/html/rfc7386)

# Error Signalling

The Knative API uses the
[Kubernetes Conditions convention](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#typical-status-properties)
to communicate errors and problems to the user. Each user-visible resource
described in Resource Overview MUST have a `conditions` field in `status`, which
must be a list of `Condition` objects of the following form (note that the
actual API object types may be named `FooCondition` to allow better code
generation and disambiguation between similar fields in the same `apiGroup`):

<table>
  <tr>
   <td><strong>Field</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Default Value</strong>
   </td>
  </tr>
  <tr>
   <td><code>type</code>
   </td>
   <td><code>string</code>
   </td>
   <td>The category of the condition, as a short, CamelCase word or phrase.
<p>
This is the primary key of the Conditions list when viewed as a map.
   </td>
   <td>REQUIRED – No default
   </td>
  </tr>
  <tr>
   <td><code>status</code>
   </td>
   <td>Enum:<ul>

<li>"True"
<li>"False"
<li>"Unknown"</li></ul>

   </td>
   <td>The last measured status of this condition.
   </td>
   <td>"Unknown"
   </td>
  </tr>
  <tr>
   <td><code>reason</code>
   </td>
   <td>string
   </td>
   <td>One-word CamelCase reason for the condition's last transition.
   </td>
   <td>""
   </td>
  </tr>
  <tr>
   <td><code>message</code>
   </td>
   <td>string
   </td>
   <td>Human-readable sentence describing the last transition.
   </td>
   <td>""
   </td>
  </tr>
  <tr>
   <td><code>severity</code>
   </td>
   <td>Enum:<ul>

<li>""
<li>"Warning"
<li>"Info"</li></ul>

   </td>
   <td>If present, represents the severity of the condition. An empty severity represents a severity level of "Error". 
   </td>
   <td>""
   </td>
  </tr>
  <tr>
   <td><code>lastTransitionTime</code>
   </td>
   <td>Timestamp
   </td>
   <td>Last update time for this condition.
   </td>
   <td>"" – may be unset
   </td>
  </tr>
</table>

Additionally, the resource's `status.conditions` field MUST be managed as
follows to enable clients (particularly user interfaces) to present useful
diagnostic and error message to the user. In the following section, conditions
are referred to by their `type` (aka the string value of the `type` field on the
Condition).

1.  Each resource MUST have either a `Ready` condition (for ongoing systems) or
    `Succeeded` condition (for resources that run to completion) with
    `severity=""`, which MUST use the `True`, `False`, and `Unknown` status
    values as follows:

    1.  `False` MUST indicate a failure condition.
    1.  `Unknown` SHOULD indicate that reconciliation is not yet complete and
        success or failure is not yet determined.
    1.  `True` SHOULD indicate that the application is fully reconciled and
        operating correctly.

    `Unknown` and `True` are specified as SHOULD rather than MUST requirements
    because there may be errors which prevent serving which cannot be determined
    by the API stack (e.g. DNS record configuration in certain environments).
    Implementations are expected to treat these as "MUST" for factors within the
    control of the implementation.

1.  For non-`Ready` conditions, any conditions with `severity=""` (aka "Error
    conditions") must be aggregated into the "Ready" condition as follows:

    1.  If the condition is `False`, `Ready` MUST be `False`.
    1.  If the condition is `Unknown`, `Ready` MUST be `False` or `Unknown`.
    1.  If the condition is `True`, `Ready` may be any of `True`, `False`, or
        `Unknown`.

    Implementations MAY choose to report that `Ready` is `False` or `Unknown`
    even if all Error conditions report a status of `True` (i.e. there may be
    additional hidden implementation conditions which feed into the `Ready`
    condition which are not reported.)

1.  Non-`Ready` conditions with non-error severity MAY be surfaced by the
    implementation. Examples of `Warning` or `Info` conditions could include:
    missing health check definitions, scale-to-zero status, or non-fatal
    capacity limits.

Conditions type names should be chosen to describe positive conditions where
`True` means that the condition has been satisfied. Some conditions may be
transient (for example, `ResourcesAllocated` might change between `True` and
`False` as an application scales to and from zero). It is RECOMMENDED that
transient conditions be indicated with a `severity="Info"`.

# Resource Lifecycle

Revisions are created by updates to the `spec` of Configuration resources, which
own the Revision lifecycle. Similarly, Service resources create and own
(control) Routes and Configurations. In some profiles, Route and Configuration
may be directly created without creating an owning Service; this is considered
an advanced environment, as it exposes more concepts and higher-cardinality
relationships to the developer.

This section describes the rules by which the different resources interact. The
general Kubernetes model is that of
[continuous reconciliation across eventually-consistent resources](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/principles.md#control-logic).

### Ownership

In several of the following sections, resources are said to "own" another
resource. Ownership indicates that the owned resource is being managed by the
owning resource and MUST be recorded using an
[OwnerReference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#ownerreference-v1-meta)
in `metadata.ownerReferences` on the owned resource with `controller` set to
`True` and `uid` set to the UID of the owning resource.

If the owning resource determines an ownership conflict and does not hold an
OwnerReference, the owning resource SHOULD NOT modify the resource, and SHOULD
signal the conflict with an error Condition.

Deleting an owning resource MUST trigger deletion of all owned resources; this
deletion MAY be immediate or eventually consistent. This process can be
implemented using
[Kubernetes cascading deletion](https://kubernetes.io/docs/concepts/workloads/controllers/garbage-collection/#controlling-how-the-garbage-collector-deletes-dependents).

## Service

When a Service is created, it MUST create and own a Configuration and Route with
the same name as the Service. Updates to `spec`, `metadata.labels`, and
`metadata.annotations` of the Service MUST be copied to the appropriate
Configuration or Route, as follows:

- `metadata` changes MUST be copied to both Configuration and Route.
- In addition, the `serving.knative.dev/service` label on the Route and
  Configuration MUST be set to the name of the Service.
- Additional `labels` and `annotations` on the Configuration and Route not
  specified above MUST be removed.
- See the documentation of `spec` in the
  [detailed resource fields section](#detailed-resources--v1beta1) for the
  mapping of specific `spec` fields to the corresponding fields in Configuration
  and Route.

Similarly, the Service MUST update its `status` fields based on the
corresponding `status` of its owned Route and Configuration. The Service MUST
include conditions of `ConfigurationsReady` and `RoutesReady` in addition to the
generic `Ready` condition; other conditions MAY also be present.

## Configuration

When a Configuration is created or its `spec` updated, the following steps MUST
be taken to create a new Revision (on creation, the previous state for all
fields is an empty value):

- If the `spec.template` field has changed from the previous state, a new owned
  Revision MUST be created. If the Revision name is not provided by the user
  through the `spec.template.metadata.name` field, it MUST be system generated.
  The system generated name should be treated opaquely as no semantics are
  defined. The values of `spec.template.metadata` and `spec.template.spec` MUST
  be copied to the newly created Revision. If the Revision cannot be created,
  the Configuration MUST signal that the Configuration is not `Ready`.
- `metadata.labels` and `metadata.annotations` from the Configuration MUST NOT
  be copied to the newly-created Revision.

Configuration MUST track the status of owned Revisions in order of creation, and
report the name of the most recently created Revision in
`status.latestCreatedRevisionName` and the name of the most recently created
Revision where the `Ready` Condition is `True` in
`status.latestReadyRevisionName`. These fields MAY be used by client software
and Route objects to determine the status of the Configuration and the best
target Revision for requests.

## Revision

A Revision is automatically scaled by the underlying infrastructure; a Revision
with no referencing Routes MAY be automatically scaled to zero instances and
backing resources collected. Additionally, Revisions which are older than the
oldest live Revision (referenced by at least one Route or latest for the
Configuration) MAY be automatically deleted by the system.

## Route

Route does not directly own any Knative resources, but may refer to multiple
Revisions which will receive incoming requests either directly or through a
reference to a Configuration's `status.latestReadyRevisionName` field. In these
cases, the Route MAY use a `serving.knative.dev/route` label to indicate that a
Configuration or Revision is currently referenced by the Route. This label or
other mechanisms MAY be used to prevent user deletion of Revisions referenced by
a Route.

# Request Routing

Knative uses fractional host-based HTTP routing to deliver requests to
autoscaled instances. Knative Routes specify request routing from HTTP virtual
hosts ([Host-header](https://tools.ietf.org/html/rfc7230#section-5.4) based
routing) to fractional assignments to Revisions. The following semantics apply
to Knative request routing:

- Each [HTTP/1.1 request](https://tools.ietf.org/html/rfc7230#section-6.3) MUST
  be treated as a separate "request" using the following semantics.
- If supported by the Knative installation, each
  [HTTP/2 stream](https://tools.ietf.org/html/rfc7540#section-5) MUST be treated
  as a separate "request" using the following semantics. Note that this maps
  naturally for
  [HTTP requests over HTTP/2](https://tools.ietf.org/html/rfc7540#section-8.1),
  but is also well-defined for other applications like [gRPC](https://grpc.io/).
- DNS Hostnames allocated to Routes MUST be unique.
- DNS Hostnames allocated to Routes SHOULD resolve.
  [Wildcard DNS records](https://tools.ietf.org/html/rfc4592) associated with a
  domain assigned to the namespace are the RECOMMENDED implementation.
- Requests to a specific Host MUST be dispatched to Revision instances in
  accordance with the weights specified in the Route, even if the number of
  container instances per Revision does not match the weights specified in the
  Route.
- When a selected Revision does not have available instances, the routing
  infrastructure MUST hold (delay) requests until an available instance is
  ready, scheduling a new container instance if needed. This is sometimes
  referred to as a "cold start".
- Requests which cause a new container instance to be created ("cold start")
  SHOULD be sent to the initially selected Revision, rather than to a different
  Revision.
- Multiple simultaneous or subsequent requests from a single client (even over
  the same TCP connection) MAY be dispatched to different instances or different
  Revisions (traffic routing MUST NOT be "sticky" in a way which violates the
  weight distributions). Developers SHOULD NOT assume that subsequent requests
  from the same client will reach the same application instance.

# Detailed Resources – v1beta1

The following schema defines a set of REQUIRED or RECOMMENDED resource fields on
the Knative resource types. Whether a field is REQUIRED or RECOMMENDED is
denoted in the "Schema Requirement" column. Additional `spec` and `status`
fields MAY be provided by particular implementations, however it is expected
that most extension will be accomplished via the `metadata.labels` and
`metadata.annotations` fields, as Knative implementations MAY validate supplied
resources against these fields and refuse resources which specify unknown
fields. Knative implementations MUST NOT require `spec` fields outside this
implementation; to do so would break interoperability between such
implementations and implementations which implement validation of field names.

## Service

### Metadata:

Standard Kubernetes
[meta.v1/ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta)
resource.

Service `labels` and `annotations` MUST be copied to the `labels` and
`annotations` on the owned Configuration and Route. Additionally, the owned
Configuration and Route MUST have the `serving.knative.dev/service` label set to
the name of the Service.

### Spec:

<table>
  <tr>
   <td><strong>Field Name</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>template</code>
   </td>
   <td>
<a href="#revisiontemplatespec">RevisionTemplateSpec</a>
<br>
(Required)
   </td>
   <td>A template for the current desired application state. Changes to <code>template</code> will cause a new Revision to be created
<a href="#resource-lifecycle">as defined in the lifecycle section</a>. The contents of the Service's RevisionTemplateSpec is used to create a corresponding Configuration.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>traffic</code>
   </td>
   <td>[]<a href="#traffictarget">TrafficTarget</a>
<br>
(Optional)
   </td>
   <td>Traffic specifies how to distribute traffic over a collection of Revisions belonging to the Service. If traffic is empty or not provided, defaults to 100% traffic to the latest <code>Ready</code> Revision. The contents of the Service's TrafficTarget is used to create a corresponding Route.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

### Status:

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>conditions</code>
   </td>
   <td>
<a href="#error-signalling">See Error Signalling</a>
   </td>
   <td>Used for signalling errors, see link. Conditions of type Ready MUST be present. Conditions of type ConfigurationsReady and RoutesReady MAY be present.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>observedGeneration</code>
   </td>
   <td>int
   </td>
   <td>The latest <code>metadata.generation</code> that the reconciler has observed. If <code>observedGeneration</code> is updated, <code>conditions</code> MUST be updated with current status in the same transaction.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>url</code>
   </td>
   <td>string (url)
   </td>
   <td>A URL which may be used to reach the application, copied from the owned Route. The URL MUST contain the scheme (i.e. "http://", etc.).
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>address</code>
   </td>
   <td>An implementation of the

<a href="#addressable-interface">Addressable</a> contract (an object with a
<code>url</code> string).

   </td>
   <td>A duck-typed interface for loading the delivery address of the destination, copied from the owned Route. The URL provided in address MAY only be internally-routable.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>traffic</code>
   </td>
   <td>[]<a href="#traffictarget">TrafficTarget</a>
   </td>
   <td>Detailed current traffic split routing information.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>latestReadyRevisionName</code>
   </td>
   <td>string
   </td>
   <td>The most recently created Revision with where the <code>Ready</code> Condition is <code>True</code>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>latestCreatedRevisionName</code>
   </td>
   <td>string
   </td>
   <td>The most recently created Revision.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## Configuration

### Metadata:

Standard Kubernetes
[meta.v1/ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta)
resource.

Configuration `labels` and `annotations` MUST NOT be copied to the `labels` and
`annotations` on newly-created Revisions. Configuration metadata MUST NOT be
continuously copied to existing Revisions, which should remain immutable after
creation. Additionally, the newly-created Revision MUST have the
`serving.knative.dev/configuration` label set to the name of the Configuration.
The Revision MUST also have the `serving.knative.dev/configurationGeneration`
label set to the Configuration's `metadata.generation` from which this Revision
was created.

### Spec:

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>template</code>
   </td>
   <td>

<a href="#revisiontemplatespec">RevisionTemplateSpec</a> <br> (Required)

   </td>
   <td>A template for the current desired application state. Changes to <code>template</code> will cause a new Revision to be created

<a href="#resource-lifecycle">as defined in the lifecycle section</a>.

   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

### Status:

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>conditions</code>
   </td>
   <td>

<a href="#error-signalling">See Error Signalling</a>

   </td>
   <td>Used for signalling errors, see link. Condition of type Ready MUST be present.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>observedGeneration</code>
   </td>
   <td>int
   </td>
   <td>The latest metadata.generation that the reconciler has attempted. If <code>observedGeneration</code> is updated, <code>conditions</code> MUST be updated with current status in the same transaction.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>latestReadyRevisionName</code>
   </td>
   <td>string
   </td>
   <td>The most recently created Revision with where the <code>Ready</code> Condition is <code>True</code>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>latestCreatedRevisionName</code>
   </td>
   <td>string
   </td>
   <td>The most recently created Revision.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## Route

### Metadata:

Standard Kubernetes
[meta.v1/ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta)
resource.

### Spec:

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>traffic</code>
   </td>
   <td>[]<a href="#traffictarget">TrafficTarget</a>
<br>
(Optional)
   </td>
   <td>Traffic specifies how to distribute traffic over a collection of Revisions belonging to the Service. If traffic is empty or not provided, defaults to 100% traffic to the latest Ready Revision.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

### Status:

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>conditions</code>
   </td>
   <td>

<a href="#error-signalling">See Error Signalling</a>

   </td>
   <td>Used for signalling errors, see link. Conditions of types Ready MUST be present. `AllTrafficAssigned`, `IngressReady`, and `CertificateProvisioned` MAY be present. 
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>observedGeneration</code>
   </td>
   <td>int
   </td>
   <td>The latest `metadata.generation` that the reconciler has observed. If <code>observedGeneration</code> is updated, <code>conditions</code> MUST be updated with current status in the same transaction.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>url</code>
   </td>
   <td>string (url)
   </td>
   <td>A URL which may be used to reach the application. The URL MUST contain the scheme (i.e. "http://", etc.).
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>address</code>
   </td>
   <td>An implementation of the <a href="#addressable-interface">Addressable</a> contract (an object with a <code>url</code> string).
   </td>
   <td>A duck-typed interface for loading the delivery address of the destination. The URL provided in address MAY only be internally-routable.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>traffic</code>
   </td>
   <td>[]<a href="#traffictarget">TrafficTarget</a>
   </td>
   <td>Detailed current traffic split routing information.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## Revision

### Metadata:

Standard Kubernetes
[meta.v1/ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta)
resource.

### Spec:

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>containers</code>
   </td>
   <td>[]<a href="#container">Container</a>
<br>
(Required)
<br>
Min: 1
<br>
Max: 1
   </td>
   <td>Specifies the parameters used to execute each container instance corresponding to this Revision.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>volumes</code>
   </td>
   <td>[]<a href="#volume">Volume</a>
<br>
(Optional)
   </td>
   <td>A list of Volumes to make available to <code>containers[0]</code>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>timeoutSeconds</code>
   </td>
   <td>int
<br>
(Optional)
   </td>
   <td>The maximum duration in seconds that the request routing layer will wait for a request delivered to a container to progress (send network traffic). If unspecified, a system default will be provided.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>containerConcurrency</code>
   </td>
   <td>int
<br>
(Optional)
<br>
Default: 0
   </td>
   <td>The maximum number of concurrent requests being handled by a single instance of <code>containers[0]</code>. The default value is 0, which means that the system decides.
<p>
See

<a href="#request-routing">Request Routing</a> for more details on what
constitutes a request.

   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>serviceAccountName</code>
   </td>
   <td>string
<br>
(Optional)
   </td>
   <td>The name of a Service Account which <code>containers[0]</code> should be run as. The Service Account should be used to provide access and authorization to the container.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
    <tr>
     <td><code>imagePullSecrets</code>
     </td>
     <td>[]<a href="#localobjectreference">LocalObjectReference</a>
  <br>
  (Optional)
     </td>
     <td>The list of secrets for pulling images from private repositories.
     </td>
     <td>RECOMMENDED
     </td>
    </tr>
</table>

### Status:

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>conditions</code>
   </td>
   <td>

<a href="#error-signalling">See Error Signalling</a>

   </td>
   <td>Used for signalling errors, see link. Conditions of type Ready MUST be present. Conditions of type Active, ContainerHealthy, ResourcesAvailable  MAY be present. 
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>logUrl</code>
   </td>
   <td>string (url)
   </td>
   <td>A URL which may be used to retrieve logs specific to this Revision. The destination MAY require authentication and/or use a format (such as a web UI) which requires additional configuration. There is no further standardization of this URL or the targeted endpoint.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>containerStatuses</code>
   </td>
   <td>[]<a href="#containerStatuses">ContainerStatuses</a>
   </td>
   <td>The ContainerStatuses holds the resolved image digest for both serving and non serving containers.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>imageDigest</code>
   </td>
   <td>string
   </td>
   <td>The resolved image digest for the requested Container. This MAY be omitted by the implementation.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
</table>

# Detailed Resource Types - v1beta1

Although `container,` `volumes,` and types that they reference are based upon
core Kubernetes objects, there are additional limitations applied to ensure that
created containers can statelessly autoscale. The set of fields that have been
determined to be compatible with statelessly scaling are detailed below.
Restrictions to the values of the field are noted in the Description column.

## ContainerStatuses

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
<p>
(Optional)
   </td>
   <td>Name represents the container name and name must be a DNS_LABEL.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>imageDigest</code>
   </td>
   <td>string
<p>
(Optional)
   </td>
   <td>ImageDigest is the digest value for the container's image.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## TrafficTarget

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>revisionName</code>
   </td>
   <td>string
<p>
(Optional)
   </td>
   <td>A specific revision to which to send this portion of traffic. This is mutually exclusive with configurationName.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>configurationName</code>
   </td>
   <td>string
<p>
(Optional)
   </td>
   <td>ConfigurationName of a configuration to whose latest Revision we will send this portion of traffic. Tracks latestReadyRevisionName for the Configuration. This field is never set in <code>status</code>, only in <code>spec</code>. This is mutually exclusive with revisionName. This field is disallowed when used in

<a href="#spec">ServiceSpec</a>.

   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>latestRevision</code>
   </td>
   <td>bool
<p>
(Optional)
   </td>
   <td>latestRevision may be optionally provided to indicate that the latest ready Revision of the Configuration should be used for this traffic target. When provided latestRevision MUST be true if revisionName is empty, and it MUST be false when revisionName is non-empty.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>tag</code>
   </td>
   <td>string
<p>
(Optional)
   </td>
   <td>Tag is optionally used to expose a dedicated URL for referencing this target exclusively. The dedicated URL MUST include in it the string provided by tag.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>percent</code>
   </td>
   <td>int
<br>
(Required)
<br>
Min: 0
<br>
Max: 100
   </td>
   <td>The

<a href="#request-routing">percentage of requests which should be allocated from
the main Route domain name</a> to the specified <code>revisionName</code> or
<code>configurationName</code>.

<p>
All <code>percent</code> values in <code>traffic</code> MUST sum to 100.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>url</code>
   </td>
   <td>string
   </td>
   <td>The URL at which the tag endpoint is reachable. It MUST not be taken as input, and is only provided on Status. 
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## RevisionTemplateSpec

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>metadata</code>
   </td>
   <td>

<a href="#metadata-3">RevisionMetadata</a>

   </td>
   <td>The requested metadata for the Revision.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>spec</code>
   </td>
   <td>

<a href="#spec-3">RevisionSpec</a>

   </td>
   <td>The requested spec for the Revision.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## Container

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>args</code>
   </td>
   <td>[]string
<p>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>command</code>
   </td>
   <td>[]string
<p>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>env</code>
   </td>
   <td>[]<a href="#envvar">EnvVar</a>
<p>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>envFrom</code>
   </td>
   <td>[]<a href="#envfromsource">EnvFromSource</a>
<p>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>image</code>
   </td>
   <td>string
<p>
(Required)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>imagePullPolicy</code>
   </td>
   <td>string
<p>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>. However, Knative resolves the image to a digest. The pull policy will be applied against the digest of the resolved image and not the image tag.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>livenessProbe</code>
   </td>
   <td>
<a href="#probe">Probe</a>
<p>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
<p>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>ports</code>
   </td>
   <td>[]<a href="#containerport">ContainerPort</a>
<br>
(Optional)
<br>
Min: 0
<br>
Max: 1
   </td>
   <td>Only a single <code>port</code> may be specified. The port must be named <a href="https://github.com/knative/serving/blob/master/docs/runtime-contract.md#protocols-and-ports">as described in the runtime contract</a>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>readinessProbe</code>
   </td>
   <td>
   <a href="#probe">Probe</a>
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>resources</code>
   </td>
   <td>
   <a href="#resourcerequirements">ResourceRequirements</a>
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>. 
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>securityContext</code>
   </td>
   <td>
   <a href="#securitycontext">SecurityContext</a>
<br>
(Optional)
   </td>
   <td>In <code>securityContext</code>, only <code>runAsUser</code> MAY be set.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>terminationMessagePath</code>
   </td>
   <td>string
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>. 
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>terminationMessagePolicy</code>
   </td>
   <td>string
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>. 
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>volumeMounts</code>
   </td>
   <td>[]<a href="#volumemount">VolumeMount</a>
<br>
(Optional)
   </td>
   <td><code>volumeMounts</code> MUST correspond to a volume and specify an absolute mount path which does not shadow <a href="https://github.com/knative/serving/blob/master/docs/runtime-contract.md#default-filesystems">the runtime contract directories</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>workingDir</code>
   </td>
   <td>string
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">core/v1.Container</a>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## EnvVar

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
<br>
(Required)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envvar-v1-core">core/v1.EnvVar</a>
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>value</code>
   </td>
   <td>string
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envvar-v1-core">core/v1.EnvVar</a>. Must have one of value or valueFrom.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>valueFrom</code>
   </td>
   <td>
<a href="#envvarsource">EnvVarSource</a>
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envvar-v1-core">core/v1.EnvVar</a>. Must have one of value or valueFrom.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
</table>

## EnvVarSource

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>configMapKeyRef</code>
   </td>
   <td>
<a href="#configmapkeyselector">ConfigMapKeySelector</a>
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envvarsource-v1-core">core/v1.EnvVarSource</a>. Must have one of configMapKeyRef or secretKeyRef.
   </td>
   <td>REQUIRED, if valueFrom is supported.
   </td>
  </tr>
  <tr>
   <td><code>secretKeyRef</code>
   </td>
   <td>
<a href="#secretkeyselector">SecretKeySelector</a>
<br>
(Optional)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envvarsource-v1-core">core/v1.EnvVarSource</a>. Must have one of configMapKeyRef or secretKeyRef.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
</table>

## ConfigMapKeySelector

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>key</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapkeyselector-v1-core">core/v1.ConfigMapKeySelector</a>.
   </td>
   <td>REQUIRED, if configMapKeyRef is supported
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapkeyselector-v1-core">core/v1.ConfigMapKeySelector</a>.
   </td>
   <td>REQUIRED, if configMapKeyRef is supported
   </td>
  </tr>
  <tr>
   <td><code>optional</code>
   </td>
   <td>boolean
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapkeyselector-v1-core">core/v1.ConfigMapKeySelector</a>.
   </td>
   <td>REQUIRED, if configMapKeyRef is supported
   </td>
  </tr>
</table>

## SecretKeySelector

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>key</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretkeyselector-v1-core">core/v1.SecretKeySelector</a>.
   </td>
   <td>REQUIRED, if secretKeyRef is supported
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretkeyselector-v1-core">core/v1.SecretKeySelector</a>.
   </td>
   <td>REQUIRED, if secretKeyRef is supported
   </td>
  </tr>
  <tr>
   <td><code>optional</code>
   </td>
   <td>boolean
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretkeyselector-v1-core">core/v1.SecretKeySelector</a>.
   </td>
   <td>REQUIRED, if secretKeyRef is supported
   </td>
  </tr>
</table>

## Probe

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>exec</code>
   </td>
   <td>

<a href="#execaction">ExecAction</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#probe-v1-core">core/v1.Probe</a>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>failureThreshold</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#probe-v1-core">core/v1.Probe</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>httpGet</code>
   </td>
   <td>

<a href="#httpgetaction">HTTPGetAction</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#probe-v1-core">core/v1.Probe</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>initialDelaySeconds</code>
   </td>
   <td>int
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#probe-v1-core">core/v1.Probe</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>successThreshold</code>
   </td>
   <td>int
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#probe-v1-core">core/v1.Probe</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>tcpSocket</code>
   </td>
   <td>

<a href="#tcpsocketaction">TCPSocketAction</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#probe-v1-core">core/v1.Probe</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>timeoutSeconds</code>
   </td>
   <td>int
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#probe-v1-core">core/v1.Probe</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
</table>

## EnvFromSource

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>configMapRef</code>
   </td>
   <td>

<a href="#configmapenvsource">ConfigMapEnvSource</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envfromsource-v1-core">core/v1.EnvFromSource</a>.
   </td>
   <td>REQUIRED, if envFrom is supported
   </td>
  </tr>
  <tr>
   <td><code>prefix</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envfromsource-v1-core">core/v1.EnvFromSource</a>.
   </td>
   <td>REQUIRED, if envFrom is supported
   </td>
  </tr>
  <tr>
   <td><code>secretRef</code>
   </td>
   <td>

<a href="#secretenvsource">SecretEnvSource</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envfromsource-v1-core">core/v1.EnvFromSource</a>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
</table>

## ExecAction

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>command</code>
   </td>
   <td>[]string
<br>
(Required)
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#execaction-v1-core">core/v1.ExecAction</a>.
   </td>
   <td>REQUIRED, if exec is supported
   </td>
  </tr>
</table>

## HTTPGetAction

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>host</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#httpgetaction-v1-core">core/v1.HTTPGetAction</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>httpHeaders</code>
   </td>
   <td>

<a href="#httpheader">HTTPHeader</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#httpgetaction-v1-core">core/v1.HTTPGetAction</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>path</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#httpgetaction-v1-core">core/v1.HTTPGetAction</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>scheme</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#httpgetaction-v1-core">core/v1.HTTPGetAction</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
</table>

## TCPSocketAction

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>host</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#tcpsocketaction-v1-core">core/v1.TCPSocketAction</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
</table>

## HTTPHeader

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#httpheader-v1-core">core/v1.HTTPHeader</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
  <tr>
   <td><code>value</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#httpheader-v1-core">core/v1.HTTPHeader</a>.
   </td>
   <td>REQUIRED, if livenessProbe or readinessProbe is supported
   </td>
  </tr>
</table>

## ContainerPort

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
<br>
(Optional)
   </td>
   <td>Must be one of "http1" or "h2c" (if supported). Defaults to "http1".
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>containerPort</code>
   </td>
   <td>int
   </td>
   <td>The selected port for which Knative will direct traffic to the user container.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>protocol</code>
   </td>
   <td>string
<br>
(Optional)
   </td>
   <td>If specified must be TCP. Defaults to TCP.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## ConfigMapEnvSource

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapenvsource-v1-core">core/v1.ConfigMapEnvSource</a>.
   </td>
   <td>REQUIRED, if envFrom is supported
   </td>
  </tr>
  <tr>
   <td><code>optional</code>
   </td>
   <td>boolean
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapenvsource-v1-core">core/v1.ConfigMapEnvSource</a>.
   </td>
   <td>REQUIRED, if envFrom is supported
   </td>
  </tr>
</table>

## SecretEnvSource

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretenvsource-v1-core">core/v1.SecretEnvSource</a>.
   </td>
   <td>REQUIRED, if secretRef is supported
   </td>
  </tr>
  <tr>
   <td><code>optional</code>
   </td>
   <td>boolean
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretenvsource-v1-core">core/v1.SecretEnvSource</a>.
   </td>
   <td>REQUIRED, if secretRef is supported
   </td>
  </tr>
</table>

## ResourceRequirements

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>limits</code>
   </td>
   <td>object
   </td>
   <td>Must support at least cpu and memory. See <a href="https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/">Kubernetes</a>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
  <tr>
   <td><code>requests</code>
   </td>
   <td>object
   </td>
   <td>Must support at least cpu and memory. See <a href="https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/">Kubernetes</a>.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## SecurityContext

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>runAsUser</code>
   </td>
   <td>int
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#securitycontext-v1-core">core/v1.SecurityContext</a>
   </td>
   <td>REQUIRED, if securityContext is supported.
   </td>
  </tr>
</table>

## VolumeMount

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>mountPath</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volumemount-v1-core">core/v1.VolumeMount</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volumemount-v1-core">core/v1.VolumeMount</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>subPath</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volumemount-v1-core">core/v1.VolumeMount</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>readOnly</code>
   </td>
   <td>bool
   </td>
   <td>Must be true. Defaults to true.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
</table>

## Volume

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>configMap</code>
   </td>
   <td>

<a href="#configmapvolumesource">ConfigMapVolumeSource</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volume-v1-core">core/v1.Volume</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>secret</code>
   </td>
   <td>

<a href="#secretvolumesource">SecretVolumeSource</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volume-v1-core">core/v1.Volume</a>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
  <tr>
   <td><code>projected</code>
   </td>
   <td>

<a href="#projectedvolumesource">ProjectedVolumeSource</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volume-v1-core">core/v1.Volume</a>.
   </td>
   <td>RECOMMENDED
   </td>
  </tr>
</table>

## ConfigMapVolumeSource

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>defaultMode</code>
   </td>
   <td>int
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapvolumesource-v1-core">core/v1.ConfigMapVolumeSource</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>items</code>
   </td>
   <td>[]<a href="#keytopath">KeyToPath</a>
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapvolumesource-v1-core">core/v1.ConfigMapVolumeSource</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapvolumesource-v1-core">core/v1.ConfigMapVolumeSource</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>optional</code>
   </td>
   <td>bool
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapvolumesource-v1-core">core/v1.ConfigMapVolumeSource</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
</table>

## SecretVolumeSource

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>defaultMode</code>
   </td>
   <td>int
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretvolumesource-v1-core">core/v1.SecretVolumeSource</a>.
   </td>
   <td>REQUIRED, if secret is supported.
   </td>
  </tr>
  <tr>
   <td><code>items</code>
   </td>
   <td>[]<a href="#keytopath">KeyToPath</a>
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretvolumesource-v1-core">core/v1.SecretVolumeSource</a>.
   </td>
   <td>REQUIRED, if secret is supported.
   </td>
  </tr>
  <tr>
   <td><code>secretName</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretvolumesource-v1-core">core/v1.SecretVolumeSource</a>.
   </td>
   <td>REQUIRED, if secret is supported.
   </td>
  </tr>
  <tr>
   <td><code>optional</code>
   </td>
   <td>bool
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretvolumesource-v1-core">core/v1.SecretVolumeSource</a>.
   </td>
   <td>REQUIRED, if secret is supported.
   </td>
  </tr>
</table>

## ProjectedVolumeSource

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>defaultMode</code>
   </td>
   <td>int
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#projectedvolumesource-v1-core">core/v1.ProjectedVolumeSource</a>.
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
  <tr>
   <td><code>sources</code>
   </td>
   <td>[]<a href="#volumeprojection">VolumeProjection</a>
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#projectedvolumesource-v1-core">core/v1.ProjectedVolumeSource</a>.
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
</table>

## KeyToPath

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>key</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#keytopath-v1-core">core/v1.KeyToPath</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>mode</code>
   </td>
   <td>int
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#keytopath-v1-core">core/v1.KeyToPath</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
  <tr>
   <td><code>path</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#keytopath-v1-core">core/v1.KeyToPath</a>.
   </td>
   <td>REQUIRED, if volumes is supported.
   </td>
  </tr>
</table>

## VolumeProjection

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>configMap</code>
   </td>
   <td>

<a href="#configmapprojection">ConfigMapProjection</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volumeprojection-v1-core">core/v1.VolumeProjection.</a>
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
  <tr>
   <td><code>secret</code>
   </td>
   <td>

<a href="#secretprojection">SecretProjection</a>

   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volumeprojection-v1-core">core/v1.VolumeProjection.</a>
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
</table>

## ConfigMapProjection

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>items</code>
   </td>
   <td>[]<a href="#keytopath">KeyToPath</a>
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapprojection-v1-core">core/v1.ConfigMapProjection.</a>
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
  <tr>
   <td><code>secret</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapprojection-v1-core">core/v1.ConfigMapProjection.</a>
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
  <tr>
   <td><code>optional</code>
   </td>
   <td>boolean
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#configmapprojection-v1-core">core/v1.ConfigMapProjection.</a>
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
</table>

## SecretProjection

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>items</code>
   </td>
   <td>[]<a href="#keytopath">KeyToPath</a>
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretprojection-v1-core">core/v1.SecretProjection.</a>
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretprojection-v1-core">core/v1.SecretProjection.</a>
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
  <tr>
   <td><code>optional</code>
   </td>
   <td>boolean
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretprojection-v1-core">core/v1.SecretProjection.</a>
   </td>
   <td>REQUIRED, if projected is supported.
   </td>
  </tr>
</table>

## [Addressable](https://github.com/knative/pkg/blob/master/apis/duck/v1beta1/addressable_types.go) (Interface)

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>url</code>
   </td>
   <td>string (<a href="https://github.com/knative/pkg/blob/master/apis/url.go">apis.URL</a>)
   </td>
   <td>A generic mechanism for a custom resource definition to indicate a destination for message delivery.
   </td>
   <td>REQUIRED
   </td>
  </tr>
</table>

## LocalObjectReference

<table>
  <tr>
   <td><strong>FieldName</strong>
   </td>
   <td><strong>Field Type</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Schema Requirement</strong>
   </td>
  </tr>
  <tr>
   <td><code>name</code>
   </td>
   <td>string
   </td>
   <td>As specified in Kubernetes <a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#localobjectreference-v1-core">core/v1.LocalObjectReference</a>.
   </td>
   <td>REQUIRED, if imagePullSecrets is supported.
   </td>
  </tr>

</table>
