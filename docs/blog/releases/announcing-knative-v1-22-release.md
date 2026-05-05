---
title: "v1.22 release"
linkTitle: "v1.22 release"
author: "[dprotaso](https://www.linkedin.com/in/dprotasowski/)"
author handle: https://github.com/dprotaso
date: 2026-05-04
description: "Knative v1.22 Release Announcement"
type: "blog"
---

## Announcing Knative v1.22 Release

A new version of Knative is now available across multiple components.

Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

## Highlights

Minimal supported version of Kubernetes is now 1.34. See our [release schedule](https://github.com/knative/community/blob/main/mechanics/RELEASE-SCHEDULE.md) for details.

---

## Serving

**Release notes**: [Knative Serving 1.22](https://github.com/knative/serving/releases/tag/knative-v1.22.0)

## Knative Serving Release Highlights

This release brings meaningful improvements to scaling, networking, and security.

**Scale Subresource Switch (400-500ms Cold Start Improvement)**

The biggest change this release is the switch to using the [Kubernetes `/scale` subresource](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#scale-subresource) when updating replica counts ([#16540](https://github.com/knative/serving/pull/16540) by [@dprotaso](https://github.com/dprotaso)). This reduces cold start time by approximately 400-500ms and means the autoscaler now works correctly with any resource that supports the standard Kubernetes scale subresource, not just Deployments.

**Networking: EndpointSlices**

The autoscaler stat forwarder has been migrated to use EndpointSlices ([#16448](https://github.com/knative/serving/pull/16448) by [@dprotaso](https://github.com/dprotaso)), bringing it in line with modern Kubernetes networking and improving scalability for larger clusters.

**Observability: New Request Metrics**

Two new metrics have been added: `kn.revision.request.queued` and `kn.revision.request.active` ([#16367](https://github.com/knative/serving/pull/16367) by [@prashanthjos](https://github.com/prashanthjos)), giving better visibility into per-revision request pressure.

**Security and Reliability**

TLS configuration for the reconciler, activator, and queue-proxy has been consolidated under the `knative.dev/pkg/tls` package ([#16431](https://github.com/knative/serving/pull/16431), [#16424](https://github.com/knative/serving/pull/16424), [#16425](https://github.com/knative/serving/pull/16425) by [@Fedosin](https://github.com/Fedosin)). 

WebSocket connections in the queue-proxy now shut down gracefully ([#16362](https://github.com/knative/serving/pull/16362) by [@dprotaso](https://github.com/dprotaso)).

**Smarter Deployment Updates**

The serving reconciler will now only update a Deployment when labels, annotations, or the spec actually change ([#16554](https://github.com/knative/serving/pull/16554) by [@dprotaso](https://github.com/dprotaso)), reducing unnecessary resource churn.


---

## Eventing

**Release notes**: [Knative Eventing 1.22](https://github.com/knative/eventing/releases/tag/knative-v1.22.0)

This release focuses on security hardening, observability improvements, and expanded EventTransformer capabilities.

**EventTransformer Gets Auth and EventPolicy Support**

The EventTransformer now supports the auth-proxy sidecar and EventPolicy ([#8883](https://github.com/knative/eventing/pull/8883) by [@Arpit529Srivastava](https://github.com/Arpit529Srivastava)), bringing it in line with the rest of the eventing components. 

EventPolicies are also now queried dynamically by the auth-proxy ([#8870](https://github.com/knative/eventing/pull/8870) by [@creydr](https://github.com/creydr)).

**TLS Hardening**

TLS configuration has been centralized under `knative.dev/pkg/tls` ([#8901](https://github.com/knative/eventing/pull/8901) by [@Fedosin](https://github.com/Fedosin)), and the default minimum TLS version has been bumped to 1.3 ([#8916](https://github.com/knative/eventing/pull/8916) by [@Fedosin](https://github.com/Fedosin)). 

**Observability Fixes and Improvements**

Several metrics fixes landed this release: `http.response.status_code` is now included in mt-broker-ingress and imc-dispatcher metrics ([#8891](https://github.com/knative/eventing/pull/8891)), namespace labels have been added to source metrics ([#8892](https://github.com/knative/eventing/pull/8892)).

ApiServerSource metrics port has been corrected to 9092 ([#8895](https://github.com/knative/eventing/pull/8895)) — all by [@creydr](https://github.com/creydr). 

A duplicate OTEL setup in imc-dispatcher was also removed ([#8885](https://github.com/knative/eventing/pull/8885)).

**Source Reliability**

The source Ready condition now correctly waits for zero unavailable replicas before reporting ready ([#8896](https://github.com/knative/eventing/pull/8896) by [@creydr](https://github.com/creydr)).

Probes have been added to IntegrationSource and IntegrationSink deployments ([#8867](https://github.com/knative/eventing/pull/8867) by [@creydr](https://github.com/creydr)).


---

## Eventing Extensions

### NATS Broker

This is a significant release introducing alpha support for a native NATS broker, making NATS simpler to deploy and use with Knative Eventing.

**Alpha: Native NATS Broker**

You can now use NATS directly as a Knative broker without needing to set up a NatsChannel or NatsSource first. This release adds the custom broker ingress ([#719](https://github.com/knative-extensions/eventing-natss/pull/719)), filter ([#720](https://github.com/knative-extensions/eventing-natss/pull/720)), Kubernetes configurations ([#731](https://github.com/knative-extensions/eventing-natss/pull/731)), and shared ingress with e2e tests ([#733](https://github.com/knative-extensions/eventing-natss/pull/733)) — all by [@astelmashenko](https://github.com/astelmashenko). The result is a much simpler path to using NATS as an eventing backend: deploy the broker, point it at your NATS cluster, and start routing events.

Note this feature is alpha and the API may change in future releases.

**Nil Pointer Fix for Missing Retry Config**

A panic caused by a nil pointer dereference when no retry config was defined has been fixed ([#734](https://github.com/knative-extensions/eventing-natss/pull/734) by [@lepeli](https://github.com/lepeli)).


### Apache Kafka Broker

**Release notes**: [Kafka Broker 1.22](https://github.com/knative-extensions/eventing-kafka-broker/releases/tag/knative-v1.22.0)

This release brings observability improvements, a deprecation removal, and an important data-plane fix.

**Kubernetes Secret Fetching Fix**

K8s secrets are now fetched on a separate thread from the main Vert.x instance ([#4703](https://github.com/knative-extensions/eventing-kafka-broker/pull/4703) by [@Cali0707](https://github.com/Cali0707)), preventing thread contention that could impact data-plane performance.

**Metrics Improvements**

Tag names for resource name and namespace are now aligned with eventing-core ([#4656](https://github.com/knative-extensions/eventing-kafka-broker/pull/4656)), metric tag names are now lowercase ([#4661](https://github.com/knative-extensions/eventing-kafka-broker/pull/4661)), and a new `METRICS_DISABLE_EVENT_TYPE_TAG` option has been added ([#4673](https://github.com/knative-extensions/eventing-kafka-broker/pull/4673)) for cases where high event type cardinality causes metric bloat — all by [@creydr](https://github.com/creydr).

**Deprecated DefaultPartition Configuration Removed**

The deprecated `DefaultPartition` configuration option has been removed ([#4327](https://github.com/knative-extensions/eventing-kafka-broker/pull/4327) by [@matzew](https://github.com/matzew)). If you still have this set, it will need to be cleaned up before upgrading.

**Better Kafka Topic Validation Errors**

Error reporting for Kafka topic validation failures has been improved ([#4641](https://github.com/knative-extensions/eventing-kafka-broker/pull/4641) by [@creydr](https://github.com/creydr)), making it easier to diagnose misconfigured topics.

### Other Integrations 

These releases contains dependency updates:

- [eventing-ceph](https://github.com/knative-extensions/eventing-ceph/releases/tag/knative-v1.22.0)
- [eventing-rabbitmq](https://github.com/knative-extensions/eventing-rabbitmq/releases/tag/knative-v1.22.0)
- [eventing-redis](https://github.com/knative-extensions/eventing-redis/releases/tag/knative-v1.22.0)
- [eventing-github](https://github.com/knative-extensions/eventing-github/releases/tag/knative-v1.22.0)
- [eventing-gitlab](https://github.com/knative-extensions/eventing-gitlab/releases/tag/knative-v1.22.0)
- [eventing-istio](https://github.com/knative-extensions/eventing-istio/releases/tag/knative-v1.22.0)
- [eventing-autoscaler-keda](https://github.com/knative-extensions/eventing-autoscaler-keda/releases/tag/knative-v1.22.0)

---

## Networking

### net-contour

**Release notes**: [net-contour 1.22](https://github.com/knative-extensions/net-contour/releases/tag/knative-v1.22.0)

A focused release with a notable networking improvement and a Contour version bump.

**KIngress Annotation Propagation**

KIngress annotations are now propagated to generated HTTPProxy resources ([#1265](https://github.com/knative-extensions/net-contour/pull/1265) by [@Legion2](https://github.com/Legion2)), giving you more control over Contour-level configuration from your Knative ingress resources.

**Contour Updated to v1.33.3**

Contour has been bumped to v1.33.3 ([#1267](https://github.com/knative-extensions/net-contour/pull/1267) by [@dprotaso](https://github.com/dprotaso)), picking up the latest bug fixes and patches.


### net-gateway-api

**Release notes**: [net-gateway-api 1.22](https://github.com/knative-extensions/net-gateway-api/releases/tag/knative-v1.22.0)

This release adds tag-to-host routing support and fixes several reliability issues. Tested against Gateway API v1.4.1 with Istio v1.28.2, Contour v1.33.1, and Envoy Gateway v1.6.2.

**Tag-to-Host Support**

Traffic tags can now be mapped to hostnames ([#944](https://github.com/knative-extensions/net-gateway-api/pull/944) by [@kahirokunn](https://github.com/kahirokunn)), bringing net-gateway-api in line with the tag-to-host behavior available in other Knative networking layers.

**Label and Annotation Propagation Fix**

A bug was fixed where labels and annotations were not being propagated from the ingress to HTTPRoute resources on updates ([#950](https://github.com/knative-extensions/net-gateway-api/pull/950) by [@kahirokunn](https://github.com/kahirokunn)).

**Controller Probes and Webhook Security**

The controller now has probes and the webhook has improved security settings ([#932](https://github.com/knative-extensions/net-gateway-api/pull/932) by [@kahirokunn](https://github.com/kahirokunn)).

**`ingress.class` Config Key Renamed**

The `ingress.class` config key has been superseded by `ingress-class` ([#917](https://github.com/knative-extensions/net-gateway-api/pull/917) by [@controlol](https://github.com/controlol)). If you have this set in your config, you will need to update it.


### net-istio

**Release notes**: [net-istio 1.22](https://github.com/knative-extensions/net-istio/releases/tag/knative-v1.22.0)

**Mesh-Only Mode**

Gateways can now be disabled via config, enabling a mesh-only deployment mode ([#1524](https://github.com/knative-extensions/net-istio/pull/1524) by [@prashanthjos](https://github.com/prashanthjos)). This is useful for clusters where traffic is handled entirely through the service mesh without needing dedicated ingress gateways.

**Istio Updated to v1.29.2**

Istio has been bumped to v1.29.2 ([#1540](https://github.com/knative-extensions/net-istio/pull/1540) by [@dprotaso](https://github.com/dprotaso)), picking up the latest patches across the v1.29 line.


### net-kourier

**Release notes**: [net-kourier 1.22](https://github.com/knative-extensions/net-kourier/releases/tag/knative-v1.22.0)

**Informer Cache for Initial Ingress Reconciliation**

The reconciler now uses the informer cache when processing the initial set of ready ingresses at startup ([#1441](https://github.com/knative-extensions/net-kourier/pull/1441) by [@dprotaso](https://github.com/dprotaso)), improving reliability and reducing unnecessary API server calls during startup.

**Envoy Updated to v1.37**

Envoy has been bumped to v1.37 ([#1444](https://github.com/knative-extensions/net-kourier/pull/1444) by [@dprotaso](https://github.com/dprotaso)).


---

## Functions

**Release notes**: [Functions 1.22](https://github.com/knative/func/releases/tag/knative-v1.22.0)

**KEDA Deployer Support**

Functions can now be deployed using KEDA ([#3386](https://github.com/knative/func/pull/3386) by [@creydr](https://github.com/creydr)), enabling event-driven autoscaling for your functions out of the box. See the updated RBAC docs ([#3427](https://github.com/knative/func/pull/3427)) for what permissions are required.

**Better Function Visibility in `describe`**

The `describe` command now shows function ready status ([#3627](https://github.com/knative/func/pull/3627)) and the current revision label ([#3629](https://github.com/knative/func/pull/3629)), both by [@creydr](https://github.com/creydr), making it easier to confirm what is actually running in your cluster.

**Registry Insecure Flag Now Persisted**

The `--registry-insecure` flag is now respected in remote builds ([#3484](https://github.com/knative/func/pull/3484)) and remembered across recurring runs ([#3490](https://github.com/knative/func/pull/3490)), both by [@creydr](https://github.com/creydr). Previously this had to be re-specified every time.

**Platform Support for pack Builder**

The pack builder now supports specifying a target platform ([#3603](https://github.com/knative/func/pull/3603) by [@matejvasek](https://github.com/matejvasek)), useful for building multi-arch images or targeting a specific OS/architecture.

**Middleware Version Tracking**

The middleware version is now added as an image label on both local and remote pack builds ([#3408](https://github.com/knative/func/pull/3408) by [@gauron99](https://github.com/gauron99), [#3609](https://github.com/knative/func/pull/3609) by [@creydr](https://github.com/creydr)), making it easier to track what runtime version a function image was built with.

**CI Workflow Generation Improvements**

Workflow files are now protected from accidental overwrites ([#3407](https://github.com/knative/func/pull/3407) by [@twoGiants](https://github.com/twoGiants)), and the generated CI config is now runtime-aware ([#3479](https://github.com/knative/func/pull/3479) by [@twoGiants](https://github.com/twoGiants)).

**Notable Bug Fixes**

Podman-docker detection in container engine resolution has been fixed ([#3620](https://github.com/knative/func/pull/3620) by [@cardil](https://github.com/cardil)), the registry is now preserved correctly when changing namespaces on OpenShift ([#3445](https://github.com/knative/func/pull/3445) by [@gauron99](https://github.com/gauron99)), and eventing errors are now ignored gracefully when eventing is not installed ([#3428](https://github.com/knative/func/pull/3428) by [@creydr](https://github.com/creydr)).

---

## Knative Operator

**Release notes**: [Operator 1.22](https://github.com/knative/operator/releases/tag/knative-v1.22.0)

A significant release adding multi-cluster deployment support and net-gateway-api ingress, alongside several Helm fixes.

**Multi-Cluster Deployment via Cluster Inventory API**

The operator now supports deploying Knative across multiple clusters using the [Kubernetes Cluster Inventory API](https://kubernetes.io/docs/concepts/cluster-administration/cluster-inventory/) ([#2267](https://github.com/knative/operator/pull/2267) by [@kahirokunn](https://github.com/kahirokunn)). This means you can manage Knative installations on remote clusters from a single operator, without needing to run an operator instance on each cluster individually.

**net-gateway-api Ingress Support**

The operator now supports net-gateway-api as an ingress option ([#2251](https://github.com/knative/operator/pull/2251) by [@kahirokunn](https://github.com/kahirokunn)), giving you a declarative way to configure Gateway API-based ingress through the operator.

**Helm Reliability Fixes**

A conflict on aggregated ClusterRoles during Helm upgrades has been fixed ([#2286](https://github.com/knative/operator/pull/2286) by [@kahirokunn](https://github.com/kahirokunn)), Helm chart publishing has been fixed by skipping plugin verification ([#2243](https://github.com/knative/operator/pull/2243) by [@lepeli](https://github.com/lepeli)), and CRD generation has been migrated to controller-gen with automated Helm RBAC sync ([#2269](https://github.com/knative/operator/pull/2269) by [@kahirokunn](https://github.com/kahirokunn)).

**KUBERNETES_MIN_VERSION Propagation Fix**

`KUBERNETES_MIN_VERSION` is now correctly propagated to operand workloads ([#2245](https://github.com/knative/operator/pull/2245) by [@eXist-FraGGer](https://github.com/eXist-FraGGer)).

---

## Client

**Release notes**: [Client 1.22](https://github.com/knative/client/releases/tag/knative-v1.22.0)

**Istio Inject Set as Label**

`sidecar.istio.io/inject` is now correctly set as a label instead of an annotation ([#2142](https://github.com/knative/client/pull/2142) by [@folliehiyuki](https://github.com/folliehiyuki)), which is required for Istio to honour the setting.


### kn-plugin-quickstart

**Release notes**: [Quickstart 1.22](https://github.com/knative-extensions/kn-plugin-quickstart/releases/tag/knative-v1.22.0)

**Custom Minikube Flags**

You can now pass custom flags through to minikube when using the quickstart plugin ([#636](https://github.com/knative-extensions/kn-plugin-quickstart/pull/636) by [@Alexander-Kita](https://github.com/Alexander-Kita)), making it easier to configure things like CPU, memory, or driver without forking the plugin.

**Kubernetes Version No Longer Hardcoded**

The Kubernetes version used in quickstart environments is no longer hardcoded ([#643](https://github.com/knative-extensions/kn-plugin-quickstart/pull/643) by [@dprotaso](https://github.com/dprotaso)), so it will pick up whatever version is current rather than lagging behind.


### Other Client Plugins

These releases contains dependency updates:

- [kn-plugin-admin](https://github.com/knative-extensions/kn-plugin-admin/releases/tag/knative-v1.22.0)
- [kn-plugin-event](https://github.com/knative-extensions/kn-plugin-event/releases/tag/knative-v1.22.0)
- [kn-plugin-source-kafka](https://github.com/knative-extensions/kn-plugin-source-kafka/releases/tag/knative-v1.22.0)

---

## Thank you, contributors

Release Leads:

- [@dprotaso](https://github.com/dprotaso)

New Contributors 🎉:

- [@Ankitsinghsisodya](https://github.com/Ankitsinghsisodya)
- [@Arpit529Srivastava](https://github.com/Arpit529Srivastava)
- [@Legion2](https://github.com/Legion2)
- [@controlol](https://github.com/controlol)
- [@eXist-FraGGer](https://github.com/eXist-FraGGer)
- [@folliehiyuki](https://github.com/folliehiyuki)
- [@gaganhr94](https://github.com/gaganhr94)
- [@khushiiagrawal](https://github.com/khushiiagrawal)
- [@lepeli](https://github.com/lepeli)
- [@lepeli](https://github.com/lepeli)
- [@prashanthjos](https://github.com/prashanthjos)
- [@sonikaarora](https://github.com/sonikaarora)
- [@theakshaypant](https://github.com/theakshaypant)

---

## Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/docs/community/) can use, improve, and enjoy. We'd love you to join us!

- [Knative docs](https://knative.dev/docs)
- [Quickstart tutorial](https://knative.dev/docs/getting-started)
- [Samples](https://knative.dev/docs/samples)
- [Knative working groups](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md)
- [Knative User Mailing List](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Development Mailing List](https://groups.google.com/forum/#!forum/knative-dev)
- Knative on Twitter [@KnativeProject](https://twitter.com/KnativeProject)
- Knative on [StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- Knative [Slack](https://slack.cncf.io)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
