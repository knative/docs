---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Operator configuration field map

This is an entry reference to the documented `KnativeServing` and `KnativeEventing` configuration fields, not a complete generated API schema. Examples in the linked collections use `operator.knative.dev/v1beta1`. Check the CRD installed by your Operator release for the complete schema, for example with `kubectl explain knativeserving.spec` or `kubectl explain knativeeventing.spec`.

## ConfigMap mapping

The Operator propagates `spec.config` values from the custom resource to system ConfigMaps. Manual updates to those managed ConfigMaps are overwritten by reconciliation.

For a ConfigMap named `config-<name>`, Operator v1.23 accepts either the full ConfigMap name (`config-<name>`) or the shortened name (`<name>`) under `spec.config`. It checks the full-name entry first, then the shortened entry only if the full entry is absent. If both are present, it selects the full entry; it does not merge their data. Prefer one naming form per ConfigMap to avoid conflicting configuration. The nested values become ConfigMap `data`. This lookup is implemented by the [v1.23 `ConfigMapTransform`](https://github.com/knative/operator/blob/knative-v1.23.0/pkg/reconciler/common/config_maps.go).

For example, `domain` and `config-domain` both address `config-domain`. Eventing's [Broker Channel example](configuring-eventing-cr.md#setting-the-default-channel-for-the-broker) uses the full name `config-br-default-channel`; `br-default-channel` is its shortened form. For names without a `config-` prefix, use the full name, such as Eventing's `default-ch-webhook`.

To change the Serving autoscaler's soft concurrency default, use the [bounded cluster-default concurrency procedure](configuring-with-operator.md#set-the-cluster-default-concurrency-target); the [Serving concurrency reference](../../serving/autoscaling/concurrency.md#soft-limit) defines the setting and its precedence. Consult the component's configuration documentation for the keys, valid values, defaults, and interactions; the Operator does not define those settings independently.

In a local-cluster installation, the ConfigMaps are in the custom resource's namespace. For example, a `KnativeServing` resource in `knative-serving` manages Serving ConfigMaps in that namespace. Remote-cluster deployment has additional prerequisites and scope; see [multi-cluster deployment](multi-cluster-deployment.md).

The following example supplies values for two ConfigMaps:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  config:
    domain:
      example.org: |
        selector:
          app: prod
      example.com: ""
    autoscaler:
      stable-window: "60s"
```

Here, `domain` maps to `config-domain`, and `autoscaler` maps to `config-autoscaler`. The values illustrate configuration, not a recommendation for every installation. To apply a change, use [Configure Knative by using the Operator](configuring-with-operator.md).

## Component field destinations

| Field or section | Scope and lookup destination |
| --- | --- |
| `spec.version` | Component release selection. See [Serving version configuration](configuring-serving-cr.md#configure-the-knative-serving-version), [Eventing version configuration](knative-with-operators.md#installing-a-specific-version-of-eventing), and [supported component versions](supported-versions.md). For an existing installation, follow [Operator upgrades](../upgrade/upgrade-installation-with-operator.md). |
| `spec.manifests`, `spec.additionalManifests` | Replacement or additional installation manifests. See [Serving custom manifests](configuring-serving-cr.md#install-customized-knative-serving) and [Eventing custom manifests](knative-with-operators.md#installing-customized-knative-eventing). |
| `spec.registry` | System image templates, overrides, and pull secrets. See [Serving registry settings](configuring-serving-cr.md#private-repository-and-private-secrets) and [Eventing container identifiers](configuring-eventing-cr.md#private-repository-and-private-secrets). These are not application image settings. |
| `spec.controller-custom-certs` | Serving controller registry certificate selection: `name` identifies the ConfigMap or Secret; `type` is `ConfigMap` or `Secret`. See [controller certificates](configuring-serving-cr.md#ssl-certificate-for-controller). |
| `spec.ingress` | Serving networking implementation settings. See [Serving networking configuration](configuring-serving-cr.md#networking-entry-points). |
| `spec.defaultBrokerClass` | Eventing default Broker class. See [default Broker class configuration](configuring-eventing-cr.md#configuring-the-default-broker-class). |
| `spec.high-availability` | Replica configuration for managed component workloads and related HPA interactions. See [Serving](configuring-serving-cr.md#high-availability) or [Eventing](configuring-eventing-cr.md#high-availability). |
| `spec.workloads` | Named system workload overrides, including resources and scheduling. See [Serving](configuring-serving-cr.md#override-system-deployments) or [Eventing](configuring-eventing-cr.md#override-system-deployments). |
| `spec.services` | Named system Service labels, annotations, and selectors. See [Serving](configuring-serving-cr.md#override-system-services) or [Eventing](configuring-eventing-cr.md#override-system-services). |
| `spec.podDisruptionBudgets` | Named PDB `minAvailable` override. See [Serving](configuring-serving-cr.md#override-system-poddisruptionbudgets) or [Eventing](configuring-eventing-cr.md#override-system-poddisruptionbudgets). |
| `spec.clusterProfileRef` | Remote-cluster target, available starting with Operator v1.22; immutable after creation. See [multi-cluster deployment](multi-cluster-deployment.md). |

The linked collections retain the detailed examples and constraints. Do not treat a partial example as a complete replacement for your existing custom resource.
