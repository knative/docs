---
title: "Upgrading your installation"
weight: 21
type: "docs"
---

To upgrade your Knative components and plugins, run the `kubectl apply` command
to install the subsequent release. We support upgrading by a single
[minor](https://semver.org/) version number. For example, if you have v0.14.0 installed,
you must upgrade to v0.15.0 before attempting to upgrade to v0.16.0. To verify the version
number you currently have installed, see
[Checking your installation version](./check-install-version.md).

If you installed Knative using the either the [eventing-operator](https://github.com/knative/eventing-operator) or [serving-operator](https://github.com/knative/serving-operator) plug-ins, the upgrade process will differ. See the [serving-operator upgrade guide](https://github.com/knative/serving-operator/blob/main/doc/upgrade_guide.md) and the [eventing-operator upgrade guide](https://github.com/knative/eventing-operator/blob/main/doc/upgrade_guide.md) to learn how to upgrade an install managed by the operators.

## Before you begin

Before upgrading, there are a few steps you must take to ensure a successful
upgrade process.

### Identify breaking changes

You should be aware of any breaking changes between your current and desired
versions of Knative. Breaking changes between Knative versions are documented in
the Knative release notes. Before upgrading, review the release notes for the
target version to learn about any changes you might need to make to your Knative
applications:

- [Serving](https://github.com/knative/serving/releases)
- [Eventing](https://github.com/knative/eventing/releases)
- [Eventing-Contrib](https://github.com/knative/eventing-contrib/releases)

Release notes are published with each version on the "Releases" page of their
respective repositories in GitHub.

### View current pod status

Before upgrading, view the status of the pods for the namespaces you plan on
upgrading. This allows you to compare the before and after state of your
namespace. For example, if you are upgrading Knative Serving and Eventing, enter the following commands to see the current state of
each namespace:

```bash
kubectl get pods --namespace knative-serving
```

```bash
kubectl get pods --namespace knative-eventing
```

### Upgrading plug-ins

If you have a plug-in installed, make sure to upgrade it at the same time as
you upgrade your Knative components.

### Run pre-install tools before upgrade

In some upgrades there are some steps that must happen before the actual
upgrade, and these are identified in the release notes. For example, upgrading
from v0.15.0 to v0.16.0 for Eventing you have to run:

```bash
kubectl apply --filename {{< artifact repo="eventing" file="eventing-pre-install-jobs.yaml" >}}
```

### Upgrade existing resources to the latest stored version

Our custom resources are stored within Kubernetes at a particular version.
As we introduce newer and remove older versions you'll need to migrate our resources
to the designated stored version. This ensures removing older versions
will succeed when upgrading.

For the various subprojects - we have a K8s job to help operators perform this migration.
The release notes for each release will explicitly whether a migration is required.

ie.
```bash
kubectl create --filename {{< artifact repo="serving" file="serving-post-install-jobs.yaml" >}}
```

## Performing the upgrade

To upgrade, apply the `.yaml` files for the subsequent minor versions of all
your installed Knative components and features, remembering to only
upgrade by one minor version at a time. For a cluster running v0.15.2 of the
Knative Serving and Eventing components, the
following command upgrades the installation to v0.16.0:

```bash
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.16.0/serving-core.yaml \
--filename https://github.com/knative/eventing/releases/download/v0.16.0/eventing.yaml \
```

### Run post-install tools after the upgrade

In some upgrades there are some steps that must happen after the actual
upgrade, and these are identified in the release notes. For example, after
upgrading from v0.15.0 to v0.16.0 for Eventing you should run:

```bash
kubectl apply --filename {{< artifact repo="eventing" file="eventing-post-install-jobs.yaml" >}}
```

## Verifying the upgrade

To confirm that your components and plugins have successfully upgraded, view the status of their pods in the relevant namespaces.
All pods will restart during the upgrade and their age will reset.
If you upgraded Knative Serving and Eventing, enter the following commands to get information about the pods for each namespace:

```bash
kubectl get pods --namespace knative-serving
```

```bash
kubectl get pods --namespace knative-eventing
```

These commands return something similar to:

```bash
NAME                                READY   STATUS        RESTARTS   AGE
activator-79f674fb7b-dgvss          2/2     Running       0          43s
autoscaler-96dc49858-b24bm          2/2     Running       1          43s
autoscaler-hpa-d887d4895-njtrb      1/1     Running       0          43s
controller-6bcdd87fd6-zz9fx         1/1     Running       0          41s
networking-istio-7fcd97cbf7-z2xmr   1/1     Running       0          40s
webhook-747b799559-4sj6q            1/1     Running       0          41s
```

```bash
NAME                                READY   STATUS        RESTARTS   AGE
eventing-controller-69ffcc6f7d-5l7th   1/1     Running   0          83s
eventing-webhook-6c56fcd86c-42dr8      1/1     Running   0          81s
imc-controller-6bcf5957b5-6ccp2        1/1     Running   0          80s
imc-dispatcher-f59b7c57-q9xcl          1/1     Running   0          80s
sources-controller-8596684d7b-jxkmd    1/1     Running   0          83s
```

If the age of all your pods has been reset and all pods are up and running, the upgrade was completed successfully.
You might notice a status of `Terminating` for the old pods as they are cleaned up.

If necessary, repeat the upgrade process until you reach your desired minor version number.
