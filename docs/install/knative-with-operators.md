---
title: "Installing Knative components using Operator"
weight: 10
type: "docs"
---

Knative provides an [operator](https://github.com/knative/operator) as a tool to install, configure and manage Knative. The Knative operator leverages custom objects
in the cluster to define and manage the installed Knative software. This guide explains how to install and uninstall
Knative using Knative operator.

## Before you begin

Knative installation using the Operator requires the following:

- A Kubernetes cluster v1.16 or newer, as well as a compatible kubectl. This guide assumes that you've already created
a Kubernetes cluster. If you have only one node for your cluster, set CPUs to at least 6, Memory to at least 6.0 GB,
Disk storage to at least 30 GB. If you have multiple nodes for your cluster, set CPUs to at least 2, Memory to at least
4.0 GB, Disk storage to at least 20 GB for each node.
- The Kubernetes cluster must be able to access the internet, since the Knative operator downloads images online.
- [Download and install Istio](./installing-istio.md).

## Limitations of Knative Operator:

Knative Operator is still in Alpha phase. It has not been tested in a production environment, and should be used
for development or test purposes only.

## Install Knative with the Knative Operator

You can find the release information of Knative Operator on the [Releases page](https://github.com/knative/operator/releases).

### Installing the Knative Operator

__From releases__:

Install the latest Knative operator with the following command:

```
kubectl apply -f {{< artifact org="knative" repo="operator" file="operator.yaml" >}}
```

__From source code__:

You can also install Knative Operator from source using `ko`.

1. Install the [ko](https://github.com/google/ko) build tool.
1. Download the source code using the following command:

```
git clone https://github.com/knative/operator.git
```

1. Install the operator in the root directory of the source using the following command:

```
ko apply -f config/
```

### Verify the operator installation

Verify the installation of Knative Operator using the command:

```
kubectl get deployment knative-operator
```

If the operator is installed correctly, the deployment should show a `Ready` status. Here is a sample output:

```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
knative-operator   1/1     1            1           19h
```

### Track the log

Use the following command to track the log of the operator:

```
kubectl logs -f deploy/knative-operator
```

### Installing the Knative Serving component

1. Create and apply the Knative Serving CR:

      <!-- This indentation is important for things to render properly. -->

   {{< tabs name="serving_cr" default="Install Current Serving (default)" >}}
   {{% tab name="Install Current Serving (default)" %}} You can install the latest available Knative Serving in the
   operator by applying a YAML file containing the following:

```
apiVersion: v1
kind: Namespace
metadata:
 name: knative-serving
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
```

If you do not specify a version by using spec.version, the operator defaults to the latest available version.

{{< /tab >}}

{{% tab name="Install Future Knative Serving" %}} You do not need to upgrade the operator to a newer version to install
new releases of Knative Serving. If Knative Serving launches a new version, e.g. `{{spec.version}}`, you can install it by
applying a YAML file containing the following:

```
apiVersion: v1
kind: Namespace
metadata:
 name: knative-serving
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: {{spec.version}}
  manifests:
    - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-core.yaml
    - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-hpa.yaml
    - URL: https://github.com/knative/serving/releases/download/v${VERSION}/serving-post-install-jobs.yaml
    - URL: https://github.com/knative/net-istio/releases/download/v0.17.0/net-istio.yaml
```

The field `spec.version` is used to set the version of Knative Serving. Replace `{{spec.version}}` with the correct version number.
The tag `${VERSION}` is automatically replaced with the version number from `spec.version` by the operator.

The field `spec.manifests` is used to specify one or multiple URL links of Knative Serving component. Do not forget to
add the valid URL of the Knative network ingress plugin. Knative Serving component is still tightly-coupled with a network
ingress plugin in the operator. As in the above example, you can use `net-istio`. The ordering of the URLs is critical.
Put the manifest you want to apply first on the top.

{{< /tab >}}

{{% tab name="Install Customized Knative Serving" %}} The operator provides you the flexibility to install customized
Knative Serving based your own requirements. As long as the manifests of customized Knative Serving are accessible to
the operator, they can be installed.

For example, the version of the customized Knative Serving is `{{spec.version}}`, and it is available at `https://my-serving/serving.yaml`.
You choose `net-istio` as the ingress plugin, which is available at `https://my-net-istio/net-istio.yaml`.
You can create the content of Serving CR as below:

```
apiVersion: v1
kind: Namespace
metadata:
 name: knative-serving
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: {{spec.version}}
  manifests:
    - URL: https://my-serving/serving.yaml
    - URL: https://my-net-istio/net-istio.yaml
```

You can make the customized Knative Serving available in one or multiple links, as the `spec.manifests` supports a list
of links. The ordering of the URLs is critical. Put the manifest you want to apply first on the top. We strongly recommend
you to specify the version and the valid links to the customized Knative Serving, by leveraging both `spec.version`
and `spec.manifests`. Do not skip either field.

{{< /tab >}}

{{< /tabs >}}

2. Verify the Knative Serving deployment:

```
kubectl get deployment -n knative-serving
```

If Knative Serving has been successfully deployed, all deployments of the Knative Serving will show `READY` status. Here
is a sample output:

```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
activator          1/1     1            1           18s
autoscaler         1/1     1            1           18s
autoscaler-hpa     1/1     1            1           14s
controller         1/1     1            1           18s
istio-webhook      1/1     1            1           12s
networking-istio   1/1     1            1           12s
webhook            1/1     1            1           17s
```

3. Check the status of Knative Serving Custom Resource:

```
kubectl get KnativeServing knative-serving -n knative-serving
```

If Knative Serving is successfully installed, you should see:

```
NAME              VERSION             READY   REASON
knative-serving   <version number>    True
```

### Installing the Knative Eventing component

1. Create and apply the Knative Eventing CR:

      <!-- This indentation is important for things to render properly. -->

   {{< tabs name="eventing_cr" default="Install Current Eventing (default)" >}}
   {{% tab name="Install Current Eventing (default)" %}} You can install the latest available Knative Eventing in the
   operator by applying a YAML file containing the following:

```
apiVersion: v1
kind: Namespace
metadata:
 name: knative-eventing
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
```

If you do not specify a version by using spec.version, the operator defaults to the latest available version.

{{< /tab >}}

{{% tab name="Install Future Knative Eventing" %}} You do not need to upgrade the operator to a newer version to install
new releases of Knative Eventing. If Knative Eventing launches a new version, e.g. `{{spec.version}}`, you can install it by
applying a YAML file containing the following:

```
apiVersion: v1
kind: Namespace
metadata:
 name: knative-eventing
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: {{spec.version}}
  manifests:
    - URL: https://github.com/knative/eventing/releases/download/v${VERSION}/eventing.yaml
    - URL: https://github.com/knative/eventing/releases/download/v${VERSION}/eventing-post-install-jobs.yaml
```

The field `spec.version` is used to set the version of Knative Eventing. Replace `{{spec.version}}` with the correct version number.
The tag `${VERSION}` is automatically replaced with the version number from `spec.version` by the operator.

The field `spec.manifests` is used to specify one or multiple URL links of Knative Eventing component. Do not forget to
add the valid URL of the Knative network ingress plugin. The ordering of the URLs is critical. Put the manifest you want
to apply first on the top.

{{< /tab >}}

{{% tab name="Install Customized Knative Eventing" %}} The operator provides you the flexibility to install customized
Knative Eventing based your own requirements. As long as the manifests of customized Knative Eventing are accessible to
the operator, they can be installed.

For example, the version of the customized Knative Eventing is `{{spec.version}}`, and it is available at `https://my-eventing/eventing.yaml`.
You can create the content of Eventing CR as below:

```
apiVersion: v1
kind: Namespace
metadata:
 name: knative-eventing
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: {{spec.version}}
  manifests:
    - URL: https://my-eventing/eventing.yaml
```

You can make the customized Knative Eventing available in one or multiple links, as the `spec.manifests` supports a list
of links. The ordering of the URLs is critical. Put the manifest you want to apply first on the top. We strongly recommend
you to specify the version and the valid links to the customized Knative Eventing, by leveraging both `spec.version`
and `spec.manifests`. Do not skip either field.

{{< /tab >}}

{{< /tabs >}}

2. Verify the Knative Eventing deployment:

```
kubectl get deployment -n knative-eventing
```

If Knative Eventing has been successfully deployed, all deployments of the Knative Eventing will show `READY` status. Here
is a sample output:

```
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
broker-controller      1/1     1            1           63s
broker-filter          1/1     1            1           62s
broker-ingress         1/1     1            1           62s
eventing-controller    1/1     1            1           67s
eventing-webhook       1/1     1            1           67s
imc-controller         1/1     1            1           59s
imc-dispatcher         1/1     1            1           59s
mt-broker-controller   1/1     1            1           62s
```

3. Check the status of Knative Eventing Custom Resource:

```
kubectl get KnativeEventing knative-eventing -n knative-eventing
```

If Knative Eventing is successfully installed, you should see:

```
NAME               VERSION             READY   REASON
knative-eventing   <version number>    True
```

## Uninstall Knative

### Removing the Knative Serving component

Remove the Knative Serving CR:

```
kubectl delete KnativeServing knative-serving -n knative-serving
```

### Removing Knative Eventing component

Remove the Knative Eventing CR:

```
kubectl delete KnativeEventing knative-eventing -n knative-eventing
```

Knative operator prevents unsafe removal of Knative resources. Even if the Knative Serving and Knative Eventing CRs are
successfully removed, all the CRDs in Knative are still kept in the cluster. All your resources relying on Knative CRDs
can still work.

### Removing the Knative Operator:

If you have installed Knative using the Release page, remove the operator using the following command:

```
kubectl delete -f {{< artifact org="knative" repo="operator" file="operator.yaml" >}}
```

If you have installed Knative from source, uninstall it using the following command while in the root directory
for the source:

```
ko delete -f config/
```

## What's next

- [Configure Knative Serving using Operator](./operator/configuring-serving-cr.md)
- [Configure Knative Eventing using Operator](./operator/configuring-eventing-cr.md)
