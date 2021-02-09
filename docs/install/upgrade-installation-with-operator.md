---
title: "Upgrading your installation"
weight: 21
type: "docs"
---

The upgrade is relatively more straightforward, if you install Knative with the Knative Operator. We support upgrading
by a single [minor](https://semver.org/) version number. For example, if you have v0.17 installed, you must upgrade to
v0.18 before attempting to upgrade to v0.19. The attribute `spec.version` is the only field you need to change in the
Serving or Eventing CR to perform an upgrade. You do not need to specify the version in terms of the `patch` number,
because the Knative Operator will match the latest available `patch` number, as long as you specify `major.minor` for
the version. For example, you only need to specify `0.19` to upgrade to the latest v0.19 release. There is no need to
know the exact `patch` number.

The Knative Operator implements a minus 3 principle to support the Knative versions, which means the current version
of the Operator can support Knative with the version back 3 in terms of the `minor` number. For example, if the
current version of the Operator is 0.19.x, it bundles and supports the installation of Knative with the versions,
0.16.x, 0.17.x, 0.18.x and 0.19.x.

## Before you begin

Knative Operator maximizes the automation for the upgrade process, all you need to know is the current version of your
Knative, and the target version of your Knative. You need to know the namespaces for your Knative installation. In the
following instruction, we use `knative-serving` as the name of the Serving CR && the namespace of Knative Serving and
`knative-eventing` as the name of th Eventing CR && the namespace of Knative Eventing.

### Check the current version of the installed Knative

If you want to check the version of the installed Knative Serving, you can apply the following command:

```
kubectl get KnativeServing knative-serving --namespace knative-serving
```

If your current version for Knative Serving is 0.19.x, you will get the result as below:

```
NAME              VERSION         READY   REASON
knative-serving   0.19.0          True
```

As Knative only supports the upgrade with one single `minor` version, the target version is 0.20 for Knative Serving.
The status `True` means the Serving CR and Knative Serving are in good status.

If you want to check the version of the installed Knative Eventing, you can apply the following command:

```
kubectl get KnativeEventing knative-eventing --namespace knative-eventing
```

If your current version for Knative Eventing is 0.19.x, you will get the result as below:

```
NAME               VERSION         READY   REASON
knative-eventing   0.19.0          True
```

As Knative only supports the upgrade with one single `minor` version, the target version is 0.20 for Knative Eventing.
The status `True` means the Eventing CR and Knative Eventing are in good status.

## Performing the upgrade

To upgrade, apply the Operator CRs with the same spec, but a different target version for the attribute `spec.version`.
If your existing Serving CR is as below:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: "0.19"
```

then apply the following CR to upgrade to 0.20:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: "0.20"
```

If your existing Eventing CR is as below:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: "0.19"
```

then apply the following CR to upgrade to 0.20:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: "0.20"
```

## Verifying the upgrade

To confirm that your Knative components have successfully upgraded, view the status of their pods in the relevant namespaces.
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
NAME                                                     READY   STATUS      RESTARTS   AGE
activator-6875896748-gdjgs                               1/1     Running     0          58s
autoscaler-6bbc885cfd-vkrgg                              1/1     Running     0          57s
autoscaler-hpa-5cdd7c6b69-hxzv4                          1/1     Running     0          55s
controller-64dd4bd56-wzb2k                               1/1     Running     0          57s
istio-webhook-75cc84fbd4-dkcgt                           1/1     Running     0          50s
networking-istio-6dcbd4b5f4-mxm8q                        1/1     Running     0          51s
storage-version-migration-serving-serving-0.20.0-82hjt   0/1     Completed   0          50s
webhook-75f5d4845d-zkrdt                                 1/1     Running     0          56s
```

```bash
NAME                                              READY   STATUS      RESTARTS   AGE
eventing-controller-6bc59c9fd7-6svbm              1/1     Running     0          38s
eventing-webhook-85cd479f87-4dwxh                 1/1     Running     0          38s
imc-controller-97c4fd87c-t9mnm                    1/1     Running     0          33s
imc-dispatcher-c6db95ffd-ln4mc                    1/1     Running     0          33s
mt-broker-controller-5f87fbd5d9-m69cd             1/1     Running     0          32s
mt-broker-filter-5b9c64cbd5-d27p4                 1/1     Running     0          32s
mt-broker-ingress-55c66fdfdf-gn56g                1/1     Running     0          32s
storage-version-migration-eventing-0.20.0-fvgqf   0/1     Completed   0          31s
sugar-controller-684d5cfdbb-67vsv                 1/1     Running     0          31s
```

You can also verify the status of Knative by checking the CRs:

```bash
kubectl get KnativeServing knative-serving --namespace knative-serving
```

```bash
kubectl get KnativeEventing knative-eventing --namespace knative-eventing
```

These commands return something similar to:

```
NAME              VERSION         READY   REASON
knative-serving   0.20.0          True
```

```
NAME               VERSION        READY   REASON
knative-eventing   0.20.0         True
```

## Rollback

If the upgrade fails, you can always have a rollback solution to restore your Knative to the current version. If your
current version is 0.19, you can apply the following CR to restore Knative Serving and Eventing.

For Knative Serving:
```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: "0.19"
```

For Knative Eventing:

```
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: "0.19"
```
