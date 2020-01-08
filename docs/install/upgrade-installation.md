---
title: "Upgrading your installation"
weight: 21
type: "docs"
---

If you already have Knative installed, upgrade your installation by running the
install command for the new version. We recommend upgrading by a single version
number. For example, if you have v0.6.0 installed, you should upgrade to v0.7.0
before attempting to upgrade to v0.8.0. To verify the version number you
currently have installed, see
[Checking your installation version](./check-install-version.md).

## Breaking changes

Breaking changes between Knative versions are documented in the Knative release
notes. Before upgrading, review the release notes for the target version to
learn about any changes you might need to make to your Knative applications.

The [Serving](https://github.com/knative/serving/releases) and
[Eventing](https://github.com/knative/eventing/releases) release notes are
published with each version on the "Releases" page of their respective
repositories in GitHub.

## How to upgrade

To upgrade, apply the `.yaml` files for the new Knative version of your desired
Knative components and features to your Kubernetes cluster. For example, for a
cluster running v0.10.0 of the Knative Serving component, the  following command
upgrades the installation to v0.11.0:

```bash
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.11.0/serving.yaml
```

For a full list of all Knative `.yaml` files, see
[Customizing your installation](./Knative-custom-install.md).

## Verifying the upgrade

To confirm that the upgrade took place, view the status of the pods for the
relevant namespace. All pods will restart during the upgrade and their age will
reset to 0. If you upgraded Knative Serving, enter the following command to get
information about the pods for the `knative-serving` namespace:

```bash
kubectl get pods --namespace knative-serving
```

This returns something similar to:

```bash
NAME                                READY   STATUS        RESTARTS   AGE
activator-79f674fb7b-dgvss          2/2     Running       0          43s
autoscaler-96dc49858-b24bm          2/2     Running       1          43s
autoscaler-hpa-d887d4895-njtrb      1/1     Running       0          43s
controller-6bcdd87fd6-zz9fx         1/1     Running       0          41s
networking-istio-7fcd97cbf7-z2xmr   1/1     Running       0          40s
webhook-747b799559-4sj6q            1/1     Running       0          41s
```

You may also notice a status of "Terminating" for the old pods as they are
cleaned up. 

If the age of all your pods has been reset and all pods are up and running, the
upgrade was completed successfully.