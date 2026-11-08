---
audience: administrator
components:
  - serving
  - eventing
function: how-to
---

# Configuring Knative by using the Operator

Use this guide to change an Operator-managed ConfigMap through the component custom resource and confirm that reconciliation propagated the value. Choose the [domain configuration example](#change-the-custom-resource) or the [cluster-default concurrency task](#set-the-cluster-default-concurrency-target); they are independent routes, not steps to perform together. For other fields, choose a goal in the [Serving configuration collection](configuring-serving-cr.md) or [Eventing configuration collection](configuring-eventing-cr.md).

Do not edit the managed ConfigMap directly: the Operator overwrites manual changes. The [configuration field map](configuration-reference.md) describes how `spec.config` maps to ConfigMaps.

## Prerequisites

- A local-cluster Knative installation managed by the Operator, with the relevant `KnativeServing` or `KnativeEventing` resource already present.
- `kubectl` access to read that resource and its ConfigMaps, and permission to update the resource.
- Your existing custom resource manifest and a recoverable copy of its previous configuration. If GitOps manages it, update the source in Git through your normal workflow rather than creating competing changes in the cluster.
- The valid keys and values for the intended change. For the domain example, review [domain verification](../../serving/using-a-custom-domain.md#verification-steps) and [DNS publication](../../serving/using-a-custom-domain.md#publish-your-domain). Configuring domain values does not create DNS records. Skip the linked page's direct ConfigMap-edit procedure: Operator users change the custom resource using this guide instead.

This guide uses the resource name and namespace `knative-serving`. Substitute your actual values. For remote targets, follow [multi-cluster deployment](multi-cluster-deployment.md) instead; configuration resources are not all on the hub cluster.

## Examples

- **Configure Serving domains:** follow [Change the custom resource](#change-the-custom-resource), [Verify the change](#verify-the-change), and [Recover a previous configuration](#recover-a-previous-configuration).
- **Set a soft concurrency default:** follow [Set the cluster-default concurrency target](#set-the-cluster-default-concurrency-target), which supplies its own application and verification steps.
- **Look up a combined example:** see the [multi-ConfigMap example](configuration-reference.md#configmap-mapping) for the domain/autoscaler mapping.

## Change the custom resource

1. Confirm the resource you will change:

    ```bash
    kubectl get knativeserving knative-serving -n knative-serving -o yaml
    ```

1. In your existing manifest, add or update `spec.config.domain`. Preserve other fields and existing domain entries you still need. The following example assigns `example.org` to resources matching `app: prod` and uses `example.com` as the other domain:

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
    ```

    This is an illustrative resource, not a complete replacement for your current manifest. Use domains you control and follow the [DNS publication steps](../../serving/using-a-custom-domain.md#publish-your-domain). Do not perform the domain guide's direct ConfigMap edits on this Operator-managed installation.

1. Check and apply your updated manifest, replacing `<filename>` with its path:

    ```bash
    kubectl apply --dry-run=server -f <filename>.yaml
    kubectl apply -f <filename>.yaml
    ```

    Server-side validation checks the resource against the installed API. It does not prove that every component-specific ConfigMap value is valid for your workload.

## Verify the change

1. Check component status after reconciliation:

    ```bash
    kubectl get knativeserving knative-serving -n knative-serving
    ```

    Confirm `READY` is `True`. If it is not, inspect the resource's status conditions with `kubectl get ... -o yaml` and use [installation troubleshooting](../troubleshooting.md) before making additional changes.

1. Inspect the generated ConfigMap:

    ```bash
    kubectl get configmap config-domain -n knative-serving -o yaml
    ```

    Confirm that `data` contains your intended domain entries. Values in `_example` are documentation, not active configuration; see [Working with ConfigMaps](../../admin/editing-configmaps.md#the-_example-key).

1. Follow [domain verification](../../serving/using-a-custom-domain.md#verification-steps) to check the affected Route's URL, then [publish the domain in DNS and check access](../../serving/using-a-custom-domain.md#publish-your-domain). Skip the direct ConfigMap-edit procedure on that page. A Ready custom resource and matching ConfigMap show reconciliation, not end-to-end application reachability.

## Recover a previous configuration

Restore the changed values in the authoritative custom resource manifest and apply it through the same workflow. Repeat the status, ConfigMap, and application checks. Do not attempt recovery by editing the generated ConfigMap.

## Set the cluster-default concurrency target

This task sets the soft concurrency default for an Operator-managed Serving installation on the same cluster. It applies to KPA Revisions using the concurrency metric, with no explicit target annotation and `containerConcurrency` equal to `0`. It does not set a hard concurrency limit or change target utilization. Read the [concurrency setting and precedence reference](../../serving/autoscaling/concurrency.md#soft-limit) and [concurrency behavior explanation](../../serving/autoscaling/concurrency-behavior.md) before choosing a value.

!!! warning
    This is a cluster-wide setting, not a per-Service change. Review affected workloads and test the intended policy in a non-production environment first. The example value `50` is not a recommendation for every cluster. Use the [per-Service concurrency guide](../../serving/autoscaling/configure-concurrency.md) if you want to change only one Service.

The prerequisites above apply; you do not need to change domains or configure DNS for this task. In particular, retain a recoverable copy of the current custom resource manifest and the prior value of the key (including whether it was absent).

1. Save the current resource for inspection and read the active ConfigMap value:

    ```bash
    kubectl get knativeserving knative-serving -n knative-serving -o yaml > knative-serving-before-concurrency.yaml
    kubectl get configmap config-autoscaler -n knative-serving -o jsonpath='{.data.container-concurrency-target-default}{"\n"}'
    ```

    Inspect `spec.config` in both the saved YAML and your authoritative manifest before proceeding. **If either contains a `config-autoscaler` entry, stop before editing or applying the shortened-key fragment below.** The full-name entry wins even if it is empty (`config-autoscaler: {}`) or lacks `container-concurrency-target-default`; the Operator does not merge it with `autoscaler`. Do not add a shadow `autoscaler` entry or delete the full-name entry to bypass this check. Use the [ConfigMap mapping reference](configuration-reference.md#configmap-mapping) to plan a change to the winning full-name entry through your authoritative workflow; that route is outside this shortened-key procedure.

    Proceed only when `config-autoscaler` is absent from both sources. A blank ConfigMap result means the target key is absent, not that its effective value is zero. Consult the concurrency reference for the default. Record the prior authoritative `spec.config.autoscaler` structure and target value, including whether the entry or key was absent. The saved live YAML is an inspection record; do not apply it wholesale as a recovery manifest.

1. After the preflight confirms that no full-name `config-autoscaler` entry is present, merge the following fields into your existing `KnativeServing` manifest, preserving unrelated settings:

    ```yaml
    spec:
      config:
        autoscaler:
          container-concurrency-target-default: "50"
    ```

    This is a partial fragment. Keep the existing API version, resource name, and namespace, and supply the value chosen for your cluster.

1. Validate and apply the updated manifest through its authoritative workflow:

    ```bash
    kubectl apply --dry-run=server -f <filename>.yaml
    kubectl apply -f <filename>.yaml
    ```

    If GitOps manages the resource, update and synchronize that source instead of competing with it. Server-side validation does not test the resulting autoscaling behavior.

1. After reconciliation, inspect readiness and the generated value:

    ```bash
    kubectl get knativeserving knative-serving -n knative-serving
    kubectl get configmap config-autoscaler -n knative-serving -o jsonpath='{.data.container-concurrency-target-default}{"\n"}'
    ```

    Confirm `READY` is `True` and the second command prints `50` for this example. If either check fails, inspect resource status conditions and use [installation troubleshooting](../troubleshooting.md).

    These checks verify propagation of configuration, not a replica count or latency. To assess a particular Revision, inspect its autoscaling class, metric, target annotation, and `spec.containerConcurrency` against the reference's resolution rules. Explicit targets and nonzero hard limits can cause a Revision not to use this cluster default. Evaluate scaling behavior separately with controlled traffic against a non-production Revision that meets those eligibility conditions; do not infer it from readiness. The [Go autoscaling sample](../../serving/autoscaling/autoscale-go/README.md) demonstrates load generation, but its manifest sets an explicit target of `10`, so running it unchanged does not exercise this cluster default.

To recover, repeat the `spec.config` inspection against the current resource and authoritative manifest before making a change. If a full-name `config-autoscaler` entry has appeared, stop: restoring a shortened-key value would be shadowed. Resolve the winning-entry configuration through your authoritative workflow instead. Otherwise, restore the recorded `spec.config.autoscaler` structure and target value, preserving whether the entry or key was originally absent, and apply through the same workflow. Repeat the readiness and active ConfigMap checks, then recheck affected workloads. Do not apply the saved live resource wholesale or restore the value by directly editing the generated `config-autoscaler` ConfigMap.

## Other configuration goals

- [Serving: release, images, networking, and system workloads](configuring-serving-cr.md).
- [Eventing: Channel and Broker defaults, images, and system workloads](configuring-eventing-cr.md).
- [Operator configuration field map and multi-ConfigMap example](configuration-reference.md).
