---
audience: administrator
components:
  - serving
  - eventing
function: how-to
---

# Deploy Knative to a remote cluster

Starting with Knative Operator v1.22, a single Operator can deploy Knative Serving or Knative Eventing to a different Kubernetes cluster. The cluster that runs the Operator is the **hub cluster**, and the cluster that receives the Knative components is a **spoke cluster**. You set the field `spec.clusterProfileRef` on the `KnativeServing` or `KnativeEventing` CR to point to a `ClusterProfile` resource that describes a spoke cluster.

The Operator resolves the referenced `ClusterProfile` through the SIG-Multicluster Cluster Inventory API ([KEP-5339](https://github.com/kubernetes/enhancements/issues/5339)), so the feature works with any fleet manager that publishes `ClusterProfile` resources, such as Open Cluster Management or MultiKueue. You can also register `ClusterProfile` resources manually for proof-of-concept work.

If `spec.clusterProfileRef` is not set on a CR, the Operator deploys components to the local cluster, exactly as in earlier releases.

!!! important
    Multi-cluster deployment is a beta feature in Knative Operator v1.22 and later. This feature depends on the SIG-Multicluster Cluster Inventory API, which is still in alpha; its schema and recommended access provider plugins might change between releases.

## Overview

A multi-cluster deployment runs the reconciliation loop on the hub and applies resources on a spoke. When you create or update a CR with `spec.clusterProfileRef`, the Operator performs the following steps:

1. Read the referenced `ClusterProfile` and confirm that the spoke is healthy and that an access provider is available.
2. Build a Kubernetes client for the spoke by invoking the configured access provider plugin.
3. Create a helper resource on the spoke that anchors ownership of namespace-scoped Knative resources for garbage collection.
4. Run the standard Knative install pipeline against the spoke client, so Deployments, Services, ConfigMaps, and component CRDs land on the spoke.

The Operator continues to manage the lifecycle of the CR from the hub. To delete the deployment, delete the CR on the hub; finalizers clean up the spoke.

## Before you begin

Before you deploy Knative to a remote cluster, you must have:

- Knative Operator v1.22 or later.
- A hub cluster running Kubernetes v1.35 or later. The Operator loads credential plugin binaries through an image volume, a Kubernetes feature that became generally available in v1.35. No other delivery method for credential plugins is supported.
- The Cluster Inventory API `ClusterProfile` CRD installed on the hub cluster. See the installation instructions in the [kubernetes-sigs/cluster-inventory-api](https://github.com/kubernetes-sigs/cluster-inventory-api) repository.
- Network connectivity from the hub cluster to each spoke cluster's API server. If the hub cannot reach a spoke directly, use a reverse tunnel such as the OCM cluster-proxy.
- A credential plugin that implements the Cluster Inventory API access provider interface. The upstream `kubernetes-sigs/cluster-inventory-api` project publishes two plugins:
    - `registry.k8s.io/cluster-inventory-api/secretreader:v0.1.0` reads a bearer token from a `Secret`'s `data.token` field.
    - `registry.k8s.io/cluster-inventory-api/kubeconfig-secretreader:v0.1.0` reads a complete kubeconfig from a `Secret`.

    Pick whichever matches the credential format you intend to use, or use a plugin from another source.
- RBAC permissions on each spoke cluster that let the credential returned by the plugin create and manage Knative resources. See [Spoke RBAC requirements](#spoke-rbac-requirements).

### Spoke RBAC requirements

The Operator applies the following kinds of resources on the spoke cluster:

- `Namespace`
- `Deployment`, `Service`, `ConfigMap`, `Secret`, `ServiceAccount`
- `Role`, `RoleBinding`, `ClusterRole`, `ClusterRoleBinding`
- `MutatingWebhookConfiguration`, `ValidatingWebhookConfiguration`
- `HorizontalPodAutoscaler`, `PodDisruptionBudget`
- `CustomResourceDefinition` plus the component CRDs that ship with Knative Serving or Eventing

The credential returned by the access provider plugin must grant permissions equivalent to the `cluster-admin` ClusterRole. Knative does not provide a minimal aggregated role at this time. If your organization restricts `cluster-admin`, define a `ClusterRole` that grants `*` on the resource kinds listed above and bind it to the ServiceAccount used by the plugin.

!!! important
    Do not reuse the spoke credential for workloads other than the Knative Operator reconciliation path.

## Enable multi-cluster on the Knative Operator

The Operator ships with multi-cluster support disabled by default. Enable it through Helm values for fresh installs or by patching the existing Operator Deployment.

### Enable multi-cluster by using Helm values

If you install or upgrade the Operator with Helm, set the `knative_operator.multicluster.*` values:

```yaml
knative_operator:
  multicluster:
    enabled: true
    accessProvidersConfig:
      providers:
        - name: secretreader
          execConfig:
            apiVersion: client.authentication.k8s.io/v1
            command: /credential-plugin/plugin-binary
            provideClusterInfo: true
    plugins:
      - name: secretreader
        image: registry.k8s.io/cluster-inventory-api/secretreader:v0.1.0
        mountPath: /credential-plugin
    remoteDeploymentsPollInterval: 10s
```

The value of `accessProvidersConfig.providers[].name` must match the value of `plugins[].name`; the Operator uses the name to bind a plugin binary to its exec configuration.

Apply the values with `helm upgrade --install`:

```bash
helm upgrade --install knative-operator \
  --namespace knative-operator \
  --create-namespace \
  -f values.yaml \
  knative-operator/knative-operator
```

Helm renders the access provider configuration into a ConfigMap named `clusterprofile-provider-file` in the Operator namespace and mounts it on the Operator Pod; the ConfigMap name and mount path are fixed.

### Enable multi-cluster on an existing Operator Deployment

If you do not use Helm, add multi-cluster support to an Operator that is already running.

1. Create the access provider configuration as a ConfigMap in the Operator namespace:

    ```bash
    kubectl create configmap clusterprofile-provider-file \
      --namespace knative-operator \
      --from-file=config.json=./access-providers.json
    ```

    The `access-providers.json` file holds the same structure that Helm renders, for example:

    ```json
    {
      "providers": [
        {
          "name": "secretreader",
          "execConfig": {
            "apiVersion": "client.authentication.k8s.io/v1",
            "command": "/credential-plugin/plugin-binary",
            "provideClusterInfo": true
          }
        }
      ]
    }
    ```

2. Patch the Operator Deployment to set the `--clusterprofile-provider-file` argument and to mount the credential plugin binary as an image volume:

    ```bash
    kubectl patch deployment knative-operator \
      --namespace knative-operator \
      --type=strategic \
      --patch-file=operator-patch.yaml
    ```

    Where `operator-patch.yaml` looks like:

    ```yaml
    spec:
      template:
        spec:
          containers:
            - name: knative-operator
              args:
                - --clusterprofile-provider-file=/etc/cluster-inventory/config.json
              volumeMounts:
                - name: credential-plugin
                  mountPath: /credential-plugin
          volumes:
            - name: credential-plugin
              image:
                reference: <your-registry>/<plugin-image>:<tag>
                pullPolicy: IfNotPresent
    ```

3. Wait for the rollout to finish:

    ```bash
    kubectl rollout status deployment/knative-operator --namespace knative-operator
    ```

!!! important
    If the Operator is started without `--clusterprofile-provider-file`, any CR with `spec.clusterProfileRef` stops reconciling with `TargetClusterResolved=False` and `reason=MulticlusterDisabled`. CRs without `clusterProfileRef` continue to reconcile unchanged.

## Register a remote cluster as a ClusterProfile

A `ClusterProfile` resource on the hub describes one spoke. Register it in one of two ways:

- **Managed by a fleet manager**: A fleet manager such as Open Cluster Management updates the `spec` and `status` of the `ClusterProfile` for you. Follow the fleet manager documentation; no extra steps are needed for Knative Operator.
- **Manual registration**: For proof-of-concept setups, you can apply the `ClusterProfile` and update its status by hand. See the next section.

### Register a ClusterProfile manually

Manual registration prepares the spoke first, then publishes its endpoint and credentials on the hub. The examples below use the `secretreader` plugin (`registry.k8s.io/cluster-inventory-api/secretreader:v0.1.0`); replace image references and configuration fields with those required by the plugin you choose.

1. On the spoke cluster, create a `ServiceAccount`, the required permissions, and a token `Secret`:

    ```bash
    kubectl create serviceaccount knative-operator-spoke --namespace kube-system
    kubectl create clusterrolebinding knative-operator-spoke \
      --clusterrole=cluster-admin \
      --serviceaccount=kube-system:knative-operator-spoke
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: knative-operator-spoke-token
      namespace: kube-system
      annotations:
        kubernetes.io/service-account.name: knative-operator-spoke
    type: kubernetes.io/service-account-token
    EOF
    ```

2. On the spoke cluster, capture the API server address, CA certificate, and bearer token:

    ```bash
    kubectl get secret knative-operator-spoke-token -n kube-system \
      -o jsonpath='{.data.token}' | base64 -d
    kubectl get secret knative-operator-spoke-token -n kube-system \
      -o jsonpath='{.data.ca\.crt}'
    kubectl cluster-info
    ```

    The reachable address depends on the cluster type. You can obtain the API server endpoint by running one of the following commands:

    {% raw %}
    - For kind, run `docker inspect <kind-control-plane> --format '{{.NetworkSettings.Networks.kind.IPAddress}}'` and use `https://<ip>:6443`, or run `kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}'`.
    - For EKS, run `aws eks describe-cluster --name <name> --query 'cluster.endpoint'`.
    - For GKE, run `gcloud container clusters describe <name> --zone <zone> --format='value(endpoint)'`.
    {% endraw %}

    The `kubectl get ... -o jsonpath='{.data.ca\.crt}'` output is already base64-encoded. Paste this string as-is into the `ClusterProfile` status `certificateAuthorityData` field shown in Step 5.

3. On the hub cluster, create a `Secret` that the credential plugin reads:

    ```bash
    kubectl create secret generic spoke-cluster-1-credentials \
      --namespace fleet-system \
      --from-literal=token=<spoke-token>
    ```

    The `secretreader` plugin reads the bearer token from the `data.token` field of this `Secret`. The CA certificate is provided separately through the `ClusterProfile` status in Step 5. If you use `kubeconfig-secretreader` or another plugin, store the credentials in the `Secret` according to that plugin's documentation.

4. On the hub cluster, apply the `ClusterProfile` spec:

    ```yaml
    apiVersion: multicluster.x-k8s.io/v1alpha1
    kind: ClusterProfile
    metadata:
      name: spoke-cluster-1
      namespace: fleet-system
      labels:
        x-k8s.io/cluster-manager: knative-operator
    spec:
      displayName: Spoke Cluster 1
      clusterManager:
        name: knative-operator
    ```

5. Update the `ClusterProfile` status as a subresource. The Operator reads `status.accessProviders` and `status.conditions[type=ControlPlaneHealthy]`:

    ```bash
    kubectl patch clusterprofile spoke-cluster-1 \
      --namespace fleet-system \
      --subresource=status \
      --type=merge \
      --patch-file=cluster-profile-status.yaml
    ```

    Where `cluster-profile-status.yaml` looks like:

    ```yaml
    status:
      conditions:
        - type: ControlPlaneHealthy
          status: "True"
          reason: Manual
          message: Status set manually
          lastTransitionTime: "2026-04-22T00:00:00Z"
      accessProviders:
        - name: secretreader
          cluster:
            server: https://<spoke-api-server>:6443
            certificateAuthorityData: <spoke-ca-base64>
    ```

    !!! important
        The `ClusterProfile` status is a subresource. Use `kubectl patch --subresource=status`; updates submitted with a plain `kubectl apply` are ignored.

6. Confirm the `ClusterProfile` is ready:

    ```bash
    kubectl get clusterprofile spoke-cluster-1 -n fleet-system \
      -o jsonpath='{.status.conditions[?(@.type=="ControlPlaneHealthy")].status}'
    ```

## Deploy Knative Serving to a remote cluster

After you enable multi-cluster on the Operator and register a `ClusterProfile`, set `spec.clusterProfileRef` on the `KnativeServing` CR.

Pick the ingress before you apply the CR:

- For the simplest path, use Kourier. The Operator deploys Kourier on the spoke; you only need a working `LoadBalancer` or `NodePort` on the spoke.
- For Istio or net-gateway-api, prepare the ingress on the spoke first. With Gateway API, you must apply a `GatewayClass` and a `Gateway` on the spoke before the Operator reconciles. See [Configuring Knative Serving CRDs](configuring-serving-cr.md) for the ingress field structure on the CR.

The following CR deploys Knative Serving with Kourier to `spoke-cluster-1`:

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
```

Apply the CR on the hub:

```bash
kubectl apply -f knative-serving.yaml
```

Check that the Operator resolved the spoke. The `Target Cluster` column reports the `ClusterProfile` reference:

```bash
kubectl get knativeserving -n knative-serving
```

## Deploy Knative Eventing to a remote cluster

Knative Eventing requires no ingress-specific preparation on the spoke. Set `spec.clusterProfileRef` on the `KnativeEventing` CR and apply it on the hub:

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

```bash
kubectl apply -f knative-eventing.yaml
kubectl get knativeeventing -n knative-eventing
```

## Configure remote namespace settings

You can pre-configure labels and annotations for the namespace that hosts Knative components on the spoke through `spec.namespaceConfiguration`:

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
  namespaceConfiguration:
    labels:
      pod-security.kubernetes.io/enforce: privileged
    annotations:
      example.com/owner: platform-team
```

The Operator applies these labels and annotations only when it creates the namespace on the spoke; it does not modify an existing namespace. To change settings on an existing spoke namespace, edit the namespace directly with `kubectl label` or `kubectl annotate`.

For the field reference, see [Configuring Knative Serving CRDs](configuring-serving-cr.md) and [Configuring Knative Eventing CRDs](configuring-eventing-cr.md).

## Understand remote resource garbage collection

The Operator creates a helper resource on the spoke that anchors ownership of namespace-scoped Knative resources. The helper carries the annotation `operator.knative.dev/protected: "true"` as a warning for human operators. The annotation is informational; the Operator does not enforce it through an admission webhook. If the helper is deleted, the next reconciliation recreates it.

- Namespace-scoped resources, such as Deployments, Services, and ConfigMaps, set an `ownerReference` to the helper. Standard Kubernetes garbage collection cascades their deletion when the helper is removed.
- Cluster-scoped resources, such as ClusterRoles, webhook configurations, and CRDs, do not carry an `ownerReference`. The hub-side finalizer deletes them explicitly when the CR is deleted.
- Always uninstall Knative from a remote cluster by deleting the CR on the hub. Deleting the helper resource on the spoke directly cascades to every namespace-scoped Knative resource and removes the deployment in one step, which is rarely the intended outcome.

!!! warning
    The exact name of the helper resource is an internal implementation detail and might change between releases. Do not write scripts that target it by name.

## Tune the remote readiness poll interval

The Operator polls Deployment readiness on the spoke after a successful apply. The flag `--remote-deployments-poll-interval` (or the Helm value `knative_operator.multicluster.remoteDeploymentsPollInterval`) sets the interval between polls. The default is `10s`. Values smaller than 1 second are ignored, and the default is used.

Pick a starting value that fits the size of your fleet:

| Number of spokes | Suggested starting value |
| ---------------- | ------------------------ |
| Fewer than 10 | `10s` |
| 10 to 100 | `30s` |
| More than 100 | `60s` |

To set the interval through Helm, update the value:

```yaml
knative_operator:
  multicluster:
    remoteDeploymentsPollInterval: 30s
```

To set the interval on an existing Operator Deployment, add the flag:

```bash
kubectl patch deployment knative-operator \
  --namespace knative-operator \
  --type=json \
  --patch='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--remote-deployments-poll-interval=30s"}]'
```

## Upgrade and downgrade

Upgrading the Operator to v1.22 does not enable multi-cluster on its own; the Helm value `multicluster.enabled` defaults to `false`. Existing CRs that do not set `clusterProfileRef` keep their behavior across the upgrade.

The field `spec.clusterProfileRef` is immutable once the resource is created. To move a `KnativeServing` or `KnativeEventing` resource to a different spoke, delete it and create a new one that points to a different `ClusterProfile`.

If you downgrade the Operator to a version earlier than v1.22, the older Operator does not recognize the `clusterProfileRef` field. Delete every CR that uses `clusterProfileRef` before you downgrade. Running such a CR against an Operator that does not recognize the field is unsupported, and the resulting behavior is undefined.

## Troubleshoot multi-cluster deployments

The CR exposes a `TargetClusterResolved` condition that reports whether the Operator was able to bind to the spoke. Read the condition with the following command:

```bash
kubectl get knativeserving <name> -n <namespace> \
  -o jsonpath='{.status.conditions[?(@.type=="TargetClusterResolved")]}'
```

Replace `knativeserving` with `knativeeventing` for an Eventing CR. The same condition appears on both kinds.

For a fuller view, including the `Events` tab and other status conditions, run:

```bash
kubectl describe knativeserving <name> -n <namespace>
```

### Resolve condition reasons

Use the following table to map the most common `TargetClusterResolved=False` reasons to a fix:

| Reason | Meaning | Remediation |
| ------ | ------- | ----------- |
| `ClusterProfileNotFound` | The `ClusterProfile` named in `spec.clusterProfileRef` does not exist in the referenced namespace. | Verify `spec.clusterProfileRef.name` and `spec.clusterProfileRef.namespace`, and confirm where the `ClusterProfile` is published. |
| `ClusterProfileNotReady` | The `ClusterProfile` exists but its status does not include `ControlPlaneHealthy=True`. | Wait for the fleet manager to update the status, or update the status manually as shown in [Register a ClusterProfile manually](#register-a-clusterprofile-manually). |
| `ClusterProfileUnavailable` | The `ClusterProfile` reports no access providers, or it advertises a provider name that the Operator does not know. | Confirm that `status.accessProviders[].name` matches a provider name in the Operator access provider configuration. |
| `MulticlusterDisabled` | The Operator was started without `--clusterprofile-provider-file`, so multi-cluster support is inactive. | If you installed the Operator with Helm, set `multicluster.enabled: true` and provide `multicluster.accessProvidersConfig` in your values file. If you applied the Operator manifests manually, add `--clusterprofile-provider-file` to the Operator Deployment. See [Enable multi-cluster on the Knative Operator](#enable-multi-cluster-on-the-knative-operator). |
| `AccessProviderFailed` | The credential plugin returned an error when the Operator invoked it. | Check the Operator logs for the plugin's stderr. Confirm that the plugin binary matches the node architecture and that any `Secret` the plugin reads exists in the Operator namespace. |
| `RemoteClientCreationFailed` | The Operator built a `rest.Config` from the plugin output, but client creation failed. | Confirm that the spoke API server is reachable, that the CA certificate is valid, and that the bearer token has not expired. |

### Transient reasons

The following reasons reflect short-lived internal states. They usually clear on the next reconcile:

- `RemoteClusterStale` indicates that the Operator's cached spoke client is being refreshed.
- `ClusterProviderClosed` indicates that the Operator is shutting down.

If one of these reasons persists, inspect the Operator Deployment logs and the Pod restart count.

## Uninstall Knative from a remote cluster

To uninstall Knative cleanly, delete the CR on the hub and let the finalizer remove resources on the spoke:

```bash
kubectl delete knativeserving knative-serving -n knative-serving
```

The finalizer waits until the spoke is reachable and then removes the Operator-managed resources from it.

!!! warning
    If the spoke cluster is permanently unreachable, the finalizer cannot complete and the CR stays in a terminating state indefinitely. To force deletion, remove the finalizer with the following command. This leaves orphan resources on the spoke.

    ```bash
    kubectl patch knativeserving <name> -n <namespace> \
      --type=merge -p '{"metadata":{"finalizers":null}}'
    ```

## Limitations

- `spec.clusterProfileRef` is immutable. To move a `KnativeServing` or `KnativeEventing` resource between clusters, delete and re-create it.
- Each CR targets exactly one `ClusterProfile`. To deploy to several spokes, create one CR per spoke.
- The Operator does not export a dedicated Prometheus metric for the `TargetClusterResolved` condition. Collect the CR status through `kube-state-metrics` CRD configuration or through the existing condition metrics.
- A permanently unreachable spoke leaves the CR in `TargetClusterResolved=False` until you delete the CR or restore connectivity.

## FAQ

- **`MulticlusterDisabled` persists on a CR with `clusterProfileRef`.** The Operator was started without `--clusterprofile-provider-file`. With Helm, set `multicluster.enabled: true` and provide `accessProvidersConfig`, then confirm that the new Operator Pod has rolled out. With manual deployment, add the flag to the Operator Deployment.
- **`AccessProviderFailed: exec format error`.** The credential plugin binary architecture does not match the Operator node architecture. Rebuild the plugin image for the right architecture, or schedule the Operator on nodes that match the existing plugin.
- **One hub deploys to many spokes.** Create one `KnativeServing` or `KnativeEventing` CR per spoke. Use a naming convention such as `knative-serving-<region>` to keep CRs distinct, and raise `--remote-deployments-poll-interval` to `60s` for fleets larger than 100 spokes.
- **Spoke credential rotation.** Update the `ClusterProfile` status or the `Secret` that the credential plugin reads. The CR briefly reports `RemoteClusterStale` while the cached client refreshes, then returns to `True` on the next reconcile.
- **A spoke is decommissioned but the CR still references it.** Deleting the CR triggers a finalizer that tries to reach the spoke and stalls. To remove the CR while the spoke is permanently unreachable, see the force-delete steps in [Uninstall Knative from a remote cluster](#uninstall-knative-from-a-remote-cluster).
- **The helper resource on the spoke was deleted by accident.** Namespace-scoped Knative resources on the spoke are garbage collected. Annotate the CR on the hub (for example with `kubectl annotate knativeserving <name> --overwrite reconcile.knative.dev/trigger=$(date +%s)`) to trigger a fresh reconcile; the Operator recreates the helper resource and the namespace-scoped resources.

## What's next

- [Configuring Knative Serving CRDs](configuring-serving-cr.md)
- [Configuring Knative Eventing CRDs](configuring-eventing-cr.md)
- [Cluster Inventory API (kubernetes-sigs)](https://github.com/kubernetes-sigs/cluster-inventory-api)
- [KEP-5339: Cluster Inventory API - ClusterProfile](https://github.com/kubernetes/enhancements/issues/5339)
