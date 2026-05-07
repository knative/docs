---
title: "Deploying Knative to remote clusters with the Operator"
linkTitle: "Deploying Knative to remote clusters with the Operator"
author: "kahirokunn"
author handle: https://github.com/kahirokunn
date: 2026-05-07
description: "How to deploy Knative Serving and Eventing to remote clusters with Knative Operator v1.22"
type: "blog"
---

# Deploying Knative to remote clusters with the Operator

**Author: [kahirokunn](https://github.com/kahirokunn)**

_In this blog post you will learn how to use Knative Operator v1.22 to deploy Knative Serving and Eventing components to remote Kubernetes clusters from a hub cluster._

Platform teams often manage more than one Kubernetes cluster. Some clusters are split by region, some by environment, and some by tenant or business unit. Until now, installing Knative across those clusters usually meant running a separate Operator in every cluster, or building extra automation around the installation manifests.

Starting with Knative Operator v1.22, a single Operator can deploy Knative components to a different Kubernetes cluster. The cluster that runs the Operator acts as the **hub cluster**. The cluster that receives Knative Serving or Knative Eventing acts as a **spoke cluster**. You select the spoke by setting `spec.clusterProfileRef` on the `KnativeServing` or `KnativeEventing` custom resource.

This feature uses the SIG-Multicluster Cluster Inventory API, introduced through [KEP-5339](https://github.com/kubernetes/enhancements/issues/5339). The Operator reads a `ClusterProfile` resource to discover the remote cluster endpoint and access provider, then runs the normal Knative installation pipeline against that remote cluster.

If `spec.clusterProfileRef` is not set, nothing changes. The Operator keeps deploying Knative to the local cluster exactly as it did before.

## Why this matters

Multi-cluster support makes the Knative Operator a better fit for fleet-oriented platforms. You can keep the Knative installation API on the hub while still placing Serving and Eventing components close to the workloads that need them.

This is useful when you want to:

- manage Knative installations for many spoke clusters from one control point;
- integrate with a fleet manager that publishes `ClusterProfile` resources;
- keep using the same `KnativeServing` and `KnativeEventing` APIs for local and remote installs;
- apply consistent configuration across regions or environments; and
- delete a hub-side CR and let the Operator clean up the remote installation.

The feature is intentionally based on the Cluster Inventory API instead of a specific fleet manager. A fleet system such as Open Cluster Management can publish the `ClusterProfile` resources, and proof-of-concept environments can register them manually.

!!! important
    Multi-cluster deployment is a beta feature in Knative Operator v1.22 and later. It depends on the SIG-Multicluster Cluster Inventory API, which is still in alpha. The API schema and recommended access provider plugins might change between releases.

## How the Operator targets a remote cluster

The Operator resolves the target cluster at the start of reconciliation. When `spec.clusterProfileRef` is present, it reads the referenced `ClusterProfile`, invokes the configured access provider plugin, and builds a Kubernetes client for the spoke cluster.

After that, the existing install stages continue to run as usual, but they use the spoke client. This means the Operator still applies the standard Knative manifests, CRDs, ConfigMaps, Deployments, Services, and RBAC resources. The difference is where those resources land.

For cleanup, the Operator uses a helper resource on the spoke cluster to anchor ownership of namespace-scoped Knative resources. Namespace-scoped resources are garbage collected through Kubernetes owner references. Cluster-scoped resources, such as ClusterRoles and CRDs, are removed explicitly by the hub-side finalizer.

Always uninstall a remote Knative deployment by deleting the `KnativeServing` or `KnativeEventing` CR on the hub. If the spoke cluster is temporarily unreachable, the finalizer retries until the spoke can be reached again.

## What you need before enabling it

Before deploying Knative to a remote cluster, prepare the following pieces:

- Knative Operator v1.22 or later.
- A hub cluster running Kubernetes v1.35 or later. Knative v1.22 supports Kubernetes v1.34 for standard installations, but remote deployment uses Kubernetes image volumes on the hub to mount credential plugin binaries. That volume type is enabled by default starting in Kubernetes v1.35.
- The Cluster Inventory API `ClusterProfile` CRD installed on the hub.
- Network connectivity from the hub cluster to the spoke cluster API server.
- A credential plugin that implements the Cluster Inventory API access provider interface.
- Spoke-cluster RBAC permissions that let the returned credential manage Knative resources.

The upstream Cluster Inventory API project publishes credential plugins such as `secretreader` and `kubeconfig-secretreader`. Use the plugin that matches how you want to store spoke credentials.

For full prerequisites and setup steps, see [Deploy Knative to a remote cluster](https://knative.dev/docs/install/operator/multi-cluster-deployment/).

## Enable multi-cluster support

Multi-cluster support is disabled by default. If you install or upgrade the Operator with Helm, enable it through the `knative_operator.multicluster.*` values:

```yaml
knative_operator:
  multicluster:
    enabled: true
    accessProvidersConfig:
      providers:
        - name: secretreader
          execConfig:
            apiVersion: client.authentication.k8s.io/v1
            command: /credential-plugin/secretreader-plugin
            provideClusterInfo: true
    plugins:
      - name: secretreader
        image: registry.k8s.io/cluster-inventory-api/secretreader:v0.1.1
        mountPath: /credential-plugin
    remoteDeploymentsPollInterval: 10s
```

The provider name in `accessProvidersConfig.providers[].name` must match the plugin name in `plugins[].name`. The Operator uses that name to connect the `ClusterProfile` access provider entry to the credential plugin configuration.

If you do not use Helm, you can patch an existing Operator Deployment. The important pieces are the same: mount the access provider configuration, mount the credential plugin binary, and start the Operator with `--clusterprofile-provider-file`.

## Register the spoke cluster

The hub discovers spoke clusters through `ClusterProfile` resources. In production, a fleet manager can publish and update those resources. For a local test or proof of concept, you can create the `ClusterProfile` yourself and patch its status.

A `ClusterProfile` includes the cluster manager identity in `spec`, and the remote access information in `status.accessProviders`. The Operator also checks that the `ControlPlaneHealthy` condition is `True`.

The important relationship is:

- `KnativeServing` or `KnativeEventing` points to a `ClusterProfile` by name and namespace.
- The `ClusterProfile` advertises an access provider by name.
- The Operator has a provider configuration with the same name.
- The credential plugin returns credentials for the spoke cluster.

After those pieces line up, the Operator can build a client for the spoke and reconcile Knative there.

## Deploy Knative Serving to a spoke

After enabling multi-cluster support and registering a `ClusterProfile`, set `spec.clusterProfileRef` on the `KnativeServing` CR:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  clusterProfileRef:
    name: spoke-cluster-1
    namespace: fleet-system
  ingress:
    kourier:
      enabled: true
  config:
    network:
      ingress-class: kourier.ingress.networking.knative.dev
```

Apply this CR on the hub cluster. The Operator runs on the hub, but the Serving resources are created on the spoke cluster described by `spoke-cluster-1`.

For ingress, choose the implementation that fits the spoke. Kourier is the simplest path because the Operator can deploy it as part of the Serving installation. If you use Istio or Gateway API ingress, prepare the ingress implementation and gateway resources on the spoke before applying the `KnativeServing` CR.

## Deploy Knative Eventing to a spoke

Knative Eventing uses the same targeting field:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  clusterProfileRef:
    name: spoke-cluster-1
    namespace: fleet-system
```

Apply this CR on the hub, then check the spoke cluster for the Eventing components.

## Operating at fleet scale

Each `KnativeServing` or `KnativeEventing` CR targets exactly one `ClusterProfile`. To deploy to several spokes, create one CR per spoke and use a naming convention that makes the target clear, such as `knative-serving-us-east` or `knative-eventing-prod-eu`.

The `spec.clusterProfileRef` field is immutable after the CR is created. To move an installation to a different spoke, delete the existing CR and create a new one with the new `clusterProfileRef`.

The Operator reports remote targeting through the `TargetClusterResolved` condition. If targeting fails, the condition reason points to the next action. For example, `ClusterProfileNotFound` means the referenced profile does not exist, `MulticlusterDisabled` means the Operator was not started with a provider file, and `AccessProviderFailed` means the credential plugin returned an error.

For larger fleets, tune the remote readiness polling interval. The default is `10s`, but you can increase it with `--remote-deployments-poll-interval` or the Helm value `knative_operator.multicluster.remoteDeploymentsPollInterval`.

## Conclusion

Knative Operator v1.22 adds a new way to run Knative across a fleet: keep the Operator and installation API on a hub cluster, and deploy Serving or Eventing components to remote spoke clusters through `spec.clusterProfileRef`.

This keeps the single-cluster path unchanged while giving platform teams a declarative API for remote installations, cleanup, and fleet integration through the Cluster Inventory API.

To try it end to end, follow the [multi-cluster deployment guide](https://knative.dev/docs/install/operator/multi-cluster-deployment/).
