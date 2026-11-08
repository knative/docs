---
audience:
  - developer
  - administrator
components:
  - functions
  - serving
  - eventing
---

# Look up details

Find resource schemas, configuration identifiers, metrics, and implementation
constraints. This index points to the existing sources of technical detail rather
than repeating their values. Some settings pages also include configuration
procedures; use the linked page for its exact scope and requirements.

## Serving

- [Serving API](../serving/reference/serving-api.md): resource fields and types.
- [Deployment-to-Service mapping](../serving/convert-deployment-to-knative-service.md):
  illustrative manifest correspondence and workload-fit constraints, not a
  migration or endpoint-cutover procedure.
- [Concurrency settings](../serving/autoscaling/concurrency.md) and
  [scale bounds](../serving/autoscaling/scale-bounds.md): autoscaling annotations
  and cluster-level settings.
- [Default configuration](../serving/configuration/config-defaults.md) and
  [deployment resources](../serving/configuration/deployment.md): platform
  configuration keys.
- [Serving metrics](../serving/observability/metrics/serving-metrics.md) and
  [feature flags](../serving/configuration/feature-flags.md).

The [autoscaling overview](../serving/autoscaling/README.md) links to further
settings for metrics, targets, and scale-to-zero.

## Eventing

- [Eventing API](../eventing/reference/eventing-api.md): resource fields and types.
- [Trigger filtering and annotations reference](../eventing/triggers/reference.md):
  filter dialects, compatibility, field precedence, and annotations.
- [Event delivery reference](../eventing/reference/event-delivery.md): retry,
  backoff, dead-letter destinations, failure extensions, and implementation
  support. Consult its validation warnings before depending on unresolved
  implementation behavior.
- Source configuration: [ApiServerSource](../eventing/sources/apiserversource/reference.md),
  [PingSource](../eventing/sources/ping-source/reference.md),
  [ContainerSource](../eventing/custom-event-source/containersource/reference.md),
  and [SinkBinding](../eventing/custom-event-source/sinkbinding/reference.md).
- [Eventing metrics](../eventing/observability/metrics/eventing-metrics.md) and
  [feature configuration](../eventing/features/README.md).
- Security configuration details: [transport encryption modes](../eventing/features/transport-encryption.md#transport-encryption-configuration)
  and [authorization policies and modes](../eventing/features/authorization.md).
  These pages also contain procedures. Check their feature prerequisites and
  implementation compatibility; this index does not promise universal support.

For other integrations, start with the [source catalog](../eventing/sources/README.md)
or [sink catalog](../eventing/sinks/README.md), then consult the relevant
implementation's documentation. Support is not uniform across implementations.

## Functions and command-line tools

- [`kn` command reference]({{ clientdocs() }}): upstream CLI command documentation.
- [`func` command reference]({{ funcdocs() }}): upstream Functions command documentation.

These links use the documentation release branch when configured; otherwise they
fall back to upstream `main`. That fallback is not a guarantee that the reference
matches your installed binary. Use reference matching your installed `kn` or
`func` version when checking available commands and flags.

Use the [CLI overview](../client/README.md) for tool roles and connection options.
The upstream documentation is authoritative for command details; this index does
not maintain a second command catalog.

## Installation and cluster configuration

- [Installation requirements](../install/requirements.md): capacity recommendations,
  administrator prerequisites, and release-compatibility destinations.
- [Installation extensions catalog](../install/extensions.md): networking,
  messaging, and integration options with implementation-specific destinations.
- [Operator configuration field map](../install/operator/configuration-reference.md):
  ConfigMap mapping and destinations for documented custom resource fields.
  It is an entry reference, not a complete generated Operator API schema.
- [Operator-supported component versions](../install/operator/supported-versions.md):
  bundled Serving/Eventing releases, distinct from Kubernetes compatibility.
- Installation artifacts: [Serving files](../install/yaml-install/serving/serving-installation-files.md)
  and [Eventing files](../install/yaml-install/eventing/eventing-installation-files.md).
- [Administrator configuration overview](../admin/admin-overview.md): links to
  the ConfigMaps and settings for each component.

## Use the matching version

Use documentation that matches your installed Knative release. The Serving and
Eventing API pages are populated from generated reference during the release
build; their source placeholders are not the full published API documentation.
Command-documentation links above use the site's version-aware link macros.

To change a setting, find [a how-to guide](../how-to/README.md).
To understand the behavior behind it, read [explanation](../explanation/README.md).
