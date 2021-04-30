---
title: "Upgrading using the Knative Operator"
weight: 21
type: "docs"
aliases:
  - /docs/install/upgrade-installation-with-operator
---

The attribute `spec.version` is the only field you need to change in the
Serving or Eventing custom resource to perform an upgrade. You do not need to specify the version for the `patch` number, because the Knative Operator matches the latest available `patch` number, as long as you specify `major.minor` for the version. For example, you only need to specify `"0.22"` to upgrade to the 0.22 release, you do not need to specify the exact `patch` number.

The Knative Operator supports up to the last three major releases. For example, if the current version of the Operator is 0.22, it bundles and supports the installation of Knative versions 0.19, 0.20, 0.21 and 0.22.

**NOTE:** In the following examples, Knative Serving custom resources are installed in the `knative-serving` namespace, and  Knative Eventing custom resources are installed in the `knative-eventing` namespace.

## Performing the upgrade

To upgrade, apply the Operator custom resources, adding the `spec.version` for the Knative version that you want to upgrade to:

```yaml
kubectl apply -f - <<EOF
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: "0.22"
EOF

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

You can also verify the status of Knative by checking the custom resources:

```bash
kubectl get KnativeServing knative-serving --namespace knative-serving
```

```bash
kubectl get KnativeEventing knative-eventing --namespace knative-eventing
```

These commands return something similar to:

```bash
NAME              VERSION         READY   REASON
knative-serving   0.20.0          True
```

```bash
NAME               VERSION        READY   REASON
knative-eventing   0.20.0         True
```

## Rollback

If the upgrade fails, you can rollback to restore your Knative to the previous version. For example, if something goes wrong with an upgrade to 0.22, and your previous version is 0.21, you can apply the following custom resources to restore Knative Serving and Eventing to version 0.21.

For Knative Serving:

```yaml
kubectl apply -f - <<EOF
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: "0.21"
EOF

For Knative Eventing:

```yaml
kubectl apply -f - <<EOF
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: "0.21"
EOF
