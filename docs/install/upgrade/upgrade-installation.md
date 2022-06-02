# Upgrading with kubectl

If you installed Knative using YAML, you can use the `kubectl apply` command in
this topic to upgrade your Knative components and plugins.
If you installed using the Operator, see [Upgrading using the Knative Operator](upgrade-installation-with-operator.md).

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

Release notes are published with each version on the "Releases" page of their
respective repositories in GitHub.

### View current pod status

Before upgrading, view the status of the pods for the namespaces you plan on
upgrading. This allows you to compare the before and after state of your
namespace. For example, if you are upgrading Knative Serving and Eventing, enter the following commands to see the current state of
each namespace:

```bash
kubectl get pods -n knative-serving
```

```bash
kubectl get pods -n knative-eventing
```

### Upgrade plugins

If you have a plugin installed, make sure to upgrade it at the same time as
you upgrade your Knative components.

### Run pre-install tools before upgrade

For some upgrades, there are steps that must be completed before the actual
upgrade. These steps, where applicable, are identified in the release notes.

### Upgrade existing resources to the latest stored version

Knative custom resources are stored within Kubernetes at a particular version.
As we introduce newer and remove older supported versions, you must migrate the resources to the designated stored version. This ensures removing older versions
will succeed when upgrading.

For the various subprojects there is a K8s job to help operators perform this migration. The release notes for each release will state explicitly whether a migration is required.

## Performing the upgrade

To upgrade, apply the YAML files for the subsequent minor versions of all your installed Knative components and features, remembering to only upgrade by one minor version at a time.

Before upgrading, [check your Knative version](check-install-version.md).

For a cluster running version 1.1 of the Knative Serving and Knative Eventing components, the following command upgrades the installation to version 1.2:

```bash
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.2.0/serving-core.yaml \
-f https://github.com/knative/eventing/releases/download/knative-v1.2.0/eventing.yaml \
```

### Run post-install tools after the upgrade

In some upgrades there are some steps that must happen after the actual
upgrade, and these are identified in the release notes.

## Verifying the upgrade

To confirm that your components and plugins have successfully upgraded, view the status of their pods in the relevant namespaces.
All pods will restart during the upgrade and their age will reset.
If you upgraded Knative Serving and Eventing, enter the following commands to get information about the pods for each namespace:

```bash
kubectl get pods -n knative-serving
```

```bash
kubectl get pods -n knative-eventing
```

These commands return something similar to:

```bash
NAME                                READY   STATUS        RESTARTS   AGE
activator-79f674fb7b-dgvss          2/2     Running       0          43s
autoscaler-96dc49858-b24bm          2/2     Running       1          43s
autoscaler-hpa-d887d4895-njtrb      1/1     Running       0          43s
controller-6bcdd87fd6-zz9fx         1/1     Running       0          41s
net-istio-controller-7fcdf7-z2xmr   1/1     Running       0          40s
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
