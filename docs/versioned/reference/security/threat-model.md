# Knative Threat Model

Knative extends Kubernetes by offering developer-focused serverless abstractions
to users. As such, the Knative threat model require protecting Knative specific
services as well as the underlying Kubernetes infrastructure.

Knative aims to support application teams from a single organization working in
resources within a common cluster.  These teams share control plane, cluster,
and node resources managed by Knative as well as the control plane, cluster, and
node resources managed by Kubernetes.  This is described as the
[Namespace-as-a-Service multi-tenancy model](https://kubernetes.io/blog/2021/04/15/three-tenancy-models-for-kubernetes/).
Each team (users in a namespace) should be isolated and protected from
intentional or unintentional misconduct by other teams operating in a different
namespace, as well as protected from any third-party operating outside the
cluster.  Knative users and users of other Kubernetes resources in same cluster
should not be able to affect the configuration, availability, or integrity of
applications in namespaces outside their control, including obtaining or
deleting private information from another namespace.

Knative builds on the capabilities of the Kubernetes cluster, and exposes both
Kubernetes control-plane resources (CRDs managed by Kubernetes RBAC) as well as
data-plane network and compute resources on the cluster itself. In many cases,
Knative relies on built-in Kubernetes capabilities to mitigate these threats; as
such, following
[Kubernetes Security Practices](https://kubernetes.io/docs/concepts/security/)
is assumed as a baseline. Additionally, Knative has a pluggable underlying
architecture for core routing components such as HTTP proxies (e.g. Istio,
Contour, and Gateway API implementations) or event transports (e.g. Kafka,
RabbitMQ, NATS); best practices must also be used to secure the selected routing
component, and routing-level protections **may** be used to protect Knative user
workloads. Cases where additional care is required in security workloads (for
example, Knative Serving routes and Kubernetes NetworkPolicy) will be called
out.

## Terminology

- _Application_: a set of Knative resources (Serving and Eventing resource
  definitions) deployed in a namespace to implement user-desired functionality.
  An Application may consist of a mix of Knative and non-Knative resources (e.g.
  a Knative Service and a database deployed as a StatefulSet by a separate
  operator, or an Eventing Broker delivering events to a non-Knative
  Deployment).
- _User_: an individual or process managing configuration and deployment of an
  application in a Kubernetes namespace.
- _Administrator_: an individual or team responsible for the configuration of a
  platform-level service, such as Knative, Kubernetes, or external services
  (such as GitHub).

## Threat Actors

| Actor                                              | Description                                                                                                                                                     |
| -------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| External Attackers                                 | Unauthenticated attackers with no access to the Kubernetes control plane, and access only to **public** network resources on the cluster.                       |
| Malicious or Compromised Developer (internal user) | Authenticated users with the ability to create pods and other resources in a specific namespace (roughly, Kubernetes `edit`), but without cluster-level access.  Note that "malicious or compromised developer" could also include accidental effects, such as running a delete command against a namespace the user does not have access to. |
| External Event Source Admins                       | Users with the ability to configure and manage an external resource which is used as an event source, but without direct authenticated access to the cluster.   |
| Malicious Container / Supply Chain Attack          | Users with the ability to tamper with a container image which is run by an internal user, but without authenticated access to the cluster.                      |

## Component Architecture

### Common

#### Control Plane

Knative runs a number of [controllers](https://kubernetes.io/docs/concepts/architecture/controller/)
which implement the management of Knative custom resources.  Some of these
controllers provide operating instructions for other software (such as
provisioning a message queue), while others directly create resources in
system or user namespaces, such as Kubernetes deployments, pods, or services.
Controllers whose intended purpose is to deploy user-controlled or configured
pods to system- or user-selected namespaces within the cluster (for example,
Knative Revisions, or job event sinks) will necessarily have permissions which
would allow an attacker to cross namespace boundaries and potentially
compromise system components.  These controllers must be designed to avoid
operations which would allow a user to create user-controlled pods outside the
user's namespace.

#### Webhooks

For several custom resources, Knative implements
[validating and mutating admission control webhooks](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/).
These webhooks allow Knative to prevent the creation of invalid resources, and
provide immediate feedback to users about the nature of the invalid resource.
While validating and mutating webhooks provide better user experience than
delayed reporting of user errors, their ability to block or change requests to
the Kubernetes apiserver potentially allows them to affect resources in all
namespaces.  An attacker with control of admission webhooks for a configmap
could add or remove configuration clauses each time the webhook is stored, for
example.

### Eventing

#### Event Source

Event sources generally consist of a controller and one or more data-plane pods
which collect events from outside the cluster (via push or poll models).
Data-plane pods may implement event delivery for multiple namespaces, at which
point they are deployed in a system namespace for the event source, or the
data-plane pods may be deployed per-namespace, at a higher resource cost but
with lower isolation requirements (as they can be treated as a user-controlled
container).

#### Router Sinks

Knative event routing constructs (Brokers and Channels) generally consist of two
components: a _sink_ which receives events which should be stored as messages in
the underlying transport before being routed to destinations, and a _sender_
which consumes messages from the underlying transport and sends them to the
configured destinations. Roughly, the Broker and Channel objects represent the
sink implementation, while Triggers and Subscriptions represent the sender
implementation.

Like Event Sources, the routing components may be implemented as either
multi-tenant (shared) data plane or exclusive (per-namespace) processes; most
existing Knative routing implementations implement the shared data plane model
for efficiency reasons. In either case, the Kubernetes controller provisioning
and configuring the data plane resources is a shared multi-tenant component.

#### Router Triggers

See [router sinks](#router-sinks) for a description of the allocation of
responsibilities between senders and sinks in Knative. Triggers (and
Subscriptions) represent the sending side of Knative event routing -- they
deliver a series of CloudEvents to an HTTP destination with at-least-once
delivery semantics. Note that the at-least-once semantics of eventing means that
duplicate delivery (replay) is an expected behavior in some cases, and is not
necessarily a security issue.

### Serving

#### Ingress Gateway

Knative Serving requires an ingress gateway to perform HTTP routing and other
features like TLS termination and traffic splitting, but delegates the
implementation of the ingress gateway to external software such as Istio,
Contour, or Gateway API implementations. As such, the specific security
behaviors of the ingress gateway are a combination of the underlying gateway
implementation and the configuration provided by the Knative controller to the
underlying software. The ingress gateway implementation is generally
multi-tenant in nature and shared across the cluster, though the Knative
architecture does not require this.

#### Activator

The activator component is a shared (multi-tenant) data-plane component used by
Knative to handle HTTP requests when there is no current user pod available to
handle the request. The activator works in concert with the autoscaler to manage
the number of Pods for a particular Revision based on traffic routing decisions
made by the ingress gateway. Not all incoming requests are handled by the
activator -- when a particular revision has sufficient replicas to handle bursty
traffic, the ingress gateway is programmed with the direct backend addresses of
the application pods.

#### Autoscaler

The autoscaler is a control-plane component which tracks the current number of
requests and requests / second for each Knative revision, and adjusts the
necessary number of pods based on the observed traffic. Like the activator, the
autoscaler is a shared (multi-tenant) service. The autoscaler collects traffic
measurements from the activator and queue proxies, computes desired number of
pods for each revision, and then updates the desired number of deployment
replicas on the Kubernetes apiserver.

#### Queue-Proxy

The queue-proxy runs as a sidecar alongside each user container (in the same
Pod). The queue-proxy is responsible for measuring request load on the specific
pod, enforcing request timeouts and graceful pod shutdown, and managing request
concurrency to the application (if requested). The queue-proxy should only
receive requests from the ingress gateway or the queue proxy, and runs in the
same security domain (namespace) as the user container.

## Attack Goals

Generally, attacker goals are to disrupt the availability, integrity, or
confidentiality of data managed by an application which they do not have control
of. (Disrupting these guarantees for an application which the attacker has
control of is substantially easier, as the attacker has direct access to the
configuration of the application, and can presumably run arbitrary code and
access all the resources which the application can.)

Because not all components are involved in processing a request, we declare in
each situation which Knative components may be targeted by an attacker to achieve
these goals. See [migitations](#threat-mitigations) for implemented defenses and
additional cluster-specific configuration which may be considered.

### Intercept or block a requests to an application

In this scenario, attackers are able to prevent or alter request payloads
destined for the application, either before they are received by cluster, or
in-flight during processing by Knative before reaching the application.
Components targeted:

**Components**: sources, broker sinks, triggers, gateways, activator,
queue-proxy

**Attackers**: external, developer, event source

### Bypass access control to spoof requests to an application

In this scenario, attackers are able to deliver a request payload to an
application which causes it to perform undesired behavior. Examples might
include a request to delete application data, or an event (such as a financial
transaction) to be recorded which was not authorized.

**Components**: controllers, webhooks, sources, broker sinks, triggers, gateways, activator

**Attackers**: external, developer, event source

### Prevent execution of an application

In this scenario, attackers prevent _all_ execution of the application -- unlike
the "block requests" scenario where attackers may be able to selectively block
requests, this attack prevents all execution of the application.  This includes
both volume-based resource exhaustion or denial of service attacks as well as
logical attacks such as blocking access to the container registry.

**Components**: controllers, webhooks, broker sinks, triggers, gateways, activator, autoscaler

**Attackers**: external, developer, event source

### Achieve code execution in a different user namespace

The ability to execute application code in a namespace for which the attacker is
not authorized has the potential to compromise both the confidentiality and
integrity of the application (e.g. running code in the "coke" namespace when
unauthenticated or authenticated as the "pepsi" user). This attack goal does not
cover application-level vulnerabilities such as SQL injection or application
misbehavior when presented with invalid input requests, which are the
responsibility of the application author. An example of a valid attack through
the Knative surface area would be using shared node networking to trigger code
execution in the queue-proxy container.

**Components**: controllers, webhooks, event sources, broker sinks, triggers, queue-proxy

**Attackers**: external, developer, event source, supply chain

### Achieve code execution in a system namespace

System namespaces are those which implement underlying multi-tenant services for
the cluster. This includes both controllers interacting with the Kubernetes
apiserver as well as data-plane routing elements like the activator or broker
sinks which are run in a shared namespace. Achieving code execution in these
namespaces will likely grant the attacker the ability to perform many of the
previous attacks, as the system namespaces are generally considered trusted in
their implementation of security features.

**Components**: controllers, webhooks, event sources, broker sinks, triggers, gateways, activator,
autoscaler

**Attackers**: external, developer, event source, supply chain

## Security Boundaries

Knative relies on underlying cluster security (control plane, container, and
network isolation) for many application security functions. In particular, it is
assumed that user namespaces are configured to prevent escalation from the
application container to the node-level software (kubelet, linux host, etc)
using Kubernetes security mechanisms. Similarly, network isolation between
Kubernetes namespaces should generally use NetworkPolicy where possible to limit
the ability of one application to talk to backing services belonging to another
application. Additionally, it is assumed that Kubernetes authentication and RBAC
is properly configured to block cross-namespace or clusterwide resource requests
from ordinary users or service accounts.

### Network Isolation and Layer 7 Routing

A number of Knative services are implemented using HTTP routing on shared
infrastructure. In some cases (for example, internal service address in ingress
gateways, or some broker sinks) the use of HTTP hostname routing makes it
difficult to apply Kubernetes NetworkPolicy (TCP/layer 4) primitives to limit
traffic between application namespaces. Knative recommends one or more of the
following technologies which can limit cross-namespace access:

- [Knative Eventing EventPolicy](https://knative.dev/docs/eventing/features/authorization/#defining-an-eventpolicy)
  in conjunction with
  [Sender Identity](https://knative.dev/docs/eventing/features/sender-identity/).
- Use of a service mesh, like Istio. This may require
  [specific configuration](https://knative.dev/docs/serving/istio-authorization/#before-you-begin)
  to authorize the necessary paths.
- Use separate service ports or IP addresses for each namespace this is
  supported by a few Knative components, but is not well documented.

### Trustflow analysis

#### Knative Eventing

| From component         | To component   | Level of trust flow |
| ---------------------- | -------------- | ------------------- |
| event producers        | event sources  | low to high         |
| event sources          | broker sink    | low to high         |
| direct event producers | broker sink    | low to high         |
| broker sink            | broker trigger | no change           |
| broker trigger         | consumer       | high to low         |

#### Knative Serving

| From component  | To component    | Level of trust flow |
| --------------- | --------------- | ------------------- |
| internet        | ingress gateway | low to high         |
| cluster network | ingress gateway | low to high         |
| ingress gateway | activator       | low to low          |
| ingress gateway | queue-proxy     | low to high         |
| queue-proxy     | user container  | high to high        |

## Threat Mitigations

This threat model does not specifically address availability, confidentiality,
or integrity attacks which impact both Knative and non-Knative workloads in the
cluster equally; for example, an attack which prevents launching Pods on the
cluster impacts both Knative and non-Knative applications. An attack which
specifically prevents Knative autoscaling but does not impact the Kubernetes
Horizontal Pod Autoscaler would be within scope.

### Hardened (fuzzed) input handling

Knative undertook
[an external security audit in 2023](https://ostif.org/wp-content/uploads/2023/11/ADA-knative-security-audit-2023.pdf).
One of the areas of focus was the hardening of parsers for external inputs,
which included hardening upstream libraries used by Knative for parsing inputs.
Additionally, fuzz tests were implemented for key parsing paths. Knative is also
written in a memory-safe language (Go), which reduces the risk of certain types
of parsing attacks like buffer overflows and use-after-free errors.

**Mitigates**: intercept or block requests, system code execution

### TLS configuration for external (optionally internal) network interfaces

Knative supports
[automatically provisioning TLS certificates](https://knative.dev/docs/serving/encryption/encryption-overview/)
for Knative Services as well as
[provisioning certificates for broker sinks](https://knative.dev/docs/eventing/features/transport-encryption/).
Because traffic from outside the Kubernetes cluster probably transits the
internet, external TLS configuration using Cert-Manager should be enabled by
cluster administrators so that is the default for each application application.
While the cluster CNI may provide transport security guarantees for in-cluster
traffic, it is not visible to applications which traffic and addresses are
protected within the cluster, so support for cluster-internal TLS is also
provided.

_**Note**_: Cert-Manager must be installed on the cluster and
[correctly configured in Knative](https://knative.dev/docs/serving/encryption/configure-certmanager-integration/).

**Mitigates**: intercept or block requests, bypass access control

### Validate event source identities within the cluster

Knative supports using Kubernetes service account identities to authenticate
events delivered to the broker sink, as well as
[enforcement of EventPolicy](https://knative.dev/docs/eventing/features/authorization/#defining-an-eventpolicy)
to limit the types of messages accepted from authenticated senders. Knative
serving supports external configuration of authentication and access policy in
the internet gateway, though capabilities vary across gateway implementations.

**Mitigates**: bypass access control

### Validate load reports

The autoscaler connects to activators and queue-proxies to collect load reports.
Dialing outbound to these instances allows the autoscaler to have confidence
(assuming a trustworthy CNI) in the namespace issuing these reports. When
processing a load report, the autoscaler validates that

**Mitigates**: prevent execution

### Support TLS connections to event transports

Knative Eventing routing layers (Brokers, Channels) connect to transport layers
such as
[Kafka](https://knative.dev/docs/eventing/brokers/broker-types/kafka-broker/) or
[RabbitMQ](https://knative.dev/docs/eventing/brokers/broker-types/rabbitmq-broker/).
Broker and Channel implementations support using TLS connections and
per-application (namespace) credentials stored in secrets to authenticate to the
underlying message transport.

_**Note**_: Administrators for the message transport must _also_ set up
appropriate users and access control rules on the underlying message transport
to support this separation.

**Mitigates**: intercept or block requests, bypass access control

### Support and encouragement of `restricted` Pod Security Standard

Knative Serving supports running application pods under
[the `restricted` profile](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
if they apply, and will provide a warning if submitted pods use default (empty)
values which would be incompatible with the `restricted` profile.

**Mitigates**: user code execution, system code execution

### SLSA builds and provenance

Knative signs both the [container images](verifying-images.md) and the
[command-line binaries](verifying-cli.md) produced the project, along with an
SBOM and a SLSA provenance statement describing how the contents were built.
This reduces the risk of supply chain attacks by allowing administrators and
users to validate that their artifacts are the same ones built by Knative, and
validating the SLSA security guarantees with respect to ephemeral and
reproducible builds.

**Mitigates**: system code execution

## Usage of this document

When vulnerabilities are reported to the project, we consult this document to
determine whether the report describes a potential exploit, and if so to
determine the severity of the exploit. As we develop new features, we consult
this document to consider their impact on the threat model. Note that this
threat model covers Serving andEventing; some sections and threats may only
apply to certain components of the project. As Knative Functions largely
executes at build time on the application developer's infrastructure, it
needs a different threat model more focused on supply chain security threats
(which it largely inherits from [CNCF Buildpacks](https://buildpacks.io/)).

## Multi-Cluster usage

Knative is not specifically designed for use in a multi-cluster or cross-cluster
scenario; there may be additional risks when attempting to span a _single_
Knative installation across multiple clusters, but this threat model should be
sufficient if each cluster in such a scenario is running an _independent_
installation of Knative components (either some or all components).
