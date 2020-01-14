---
title: "Upgrading your installation"
weight: 21
type: "docs"
---

To upgrade your Knative components and plugins, run the `kubectl apply` command
to install the subsequent release. We recommend upgrading by a single minor
version number. For example, if you have v0.6.0 installed, you should upgrade to
v0.7.0 before attempting to upgrade to v0.8.0. To verify the version number you
currently have installed, see
[Checking your installation version](./check-install-version.md).

If you installed Knative using the Operator plug-in, the upgrade process will
differ. See []() to learn how to upgrade an install managed by the Operator.

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
namespace. For example, if you are upgrading Knative Serving, Eventing, and the
monitoring plug-in, enter the following commands to see the current state of
each namespace:

```bash
kubectl get pods --namespace knative-serving
```

```bash
kubectl get pods --namespace knative-eventing
```

```bash
kubectl get pods --namespace knative-monitoring
```

### Upgrading plug-ins

If you have a plug-in installed, make sure to upgrade it at the same time as
you upgrade your Knative components. For example, if you have the
monitoring plug-in installed, upgrade it alongside Knative Serving and Eventing.

## Performing the upgrade

To upgrade, apply the `.yaml` files for the new Knative version of your desired
Knative components and features to your Kubernetes cluster, remembering to only
upgrade by one minor version at a time. For a cluster running v0.10.0 of the
Knative Serving and Eventing components and the monitoring plug-in, the
following command upgrades the installation to v0.11.0:

```bash
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.11.0/serving.yaml \
--filename https://github.com/knative/eventing/releases/download/v0.11.0/release.yaml \
--filename https://github.com/knative/serving/releases/download/v0.11.0/monitoring.yaml
```

For a full list of all Knative `.yaml` files, see
[Customizing your installation](./Knative-custom-install.md#installing-knative-components).

## Verifying the upgrade

To confirm that your components and plugins have successfully upgraded, view the
status of their pods in the relevant namespaces. All pods will restart during
the upgrade and their age will reset. If you upgraded Knative Serving, Eventing,
and the monitoring plug-in, enter the following commands to get information
about the pods for each namespace:

```bash
kubectl get pods --namespace knative-serving
```

```bash
kubectl get pods --namespace knative-eventing
```

```bash
kubectl get pods --namespace knative-monitoring
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

```

```bash
NAME                                READY   STATUS        RESTARTS   AGE

```

If the age of all your pods has been reset and all pods are up and running, the
upgrade was completed successfully. You might notice a status of "Terminating"
for the old pods as they are cleaned up. 

If necessary, repeat the upgrade process until your reach your desired minor
version number.