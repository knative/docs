---
title: "Install on OpenShift"
linkTitle: "OpenShift"
weight: 15
type: "docs"
---

# Knative Install on OpenShift

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) on
[OpenShift](https://github.com/openshift/origin) by using the Knative Serving
Operator. The operator is available on the OpenShift OperatorHub. After you
install Knative Serving, this guide walks you through creating and deploying an
image of a sample "Hello World" app onto the new Knative cluster.

You can find [guides for other platforms here](./README.md).

## Before you begin

- An OpenShift 4 cluster is required for installation. Visit
  [try.openshift.com](https://try.openshift.com) for information on setting up a
  cluster. You will need cluster administrator privileges to install and use
  Knative on an OpenShift cluster.

## Installing the Knative Serving Operator

1. Go to **Catalog > OperatorHub** in the
   [OpenShift Web Console](https://www.openshift.com/). A list of operators for
   OpenShift, provided by Red Hat as well as a community of partners and
   open-source projects is provided. Click on the **Knative Serving Operator**
   tile.

> **NOTE:** Use the **Filter by Keyword** box to help you find the Knative
> Serving operator in the catalog.

![KSO Tile](./images/knative_serving_tile_highlighted.png)

2. A **Show Community Operator** dialog box will open. Click **Continue** to
   proceed.

3. The **Knative Serving Operator** descriptor screen will appear. Click
   **Install**.

![KSO Install Screen](./images/knative_serving_operator_screen.png)

4. On the **Create the Operator Subscription** screen, create a new subscription
   by clicking on the **Subscribe** button. This will install the Knative
   Serving Operator in the project `openshift-operators` and Knative Serving in
   the `knative-serving` project.

![KSO Namespaces Default](./images/knative_serving_namespaces_default.png)

> **NOTE:** The Operator Lifecycle Manager (OLM) installs the operator, which
> will automatically install Knative. This installation will create the
> `knative-serving`, `istio-operator`, and `istio-system` namespaces.

5. Verify the subscription status for the installation operator, by viewing the
   **Subscription Overview**. The **UPGRADE STATUS** will update from `0
   Installing` to `1 Installed`.

> **NOTE:** The screen will update after a few minutes. Wait for the
> `knative-serving` namespace to appear in the project drop-down menu. Refresh
> the page if needed.

![KSO Upgrade Status](./images/knative_serving_installed_sub.png)

6. Knative Serving is now installed. Navigate to **Catalog > Installed
   Operators** to confirm the operator is installed. Click on
   **knative-serving** to view the install status.

![KSO installed](./images/knative_serving_installed_operator.png)

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](./getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

> **NOTE:** When looking up the IP address to use for accessing your app, you
> need to look up the NodePort for the `istio-ingressgateway` well as the IP
> address used for OpenShift. You can use the following command to look up the
> value to use for the {IP_ADDRESS} placeholder used in the samples:

```shell
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

export IP_ADDRESS=$(oc get node  -o 'jsonpath={.items[0].status.addresses[0].address}'):$(oc get svc $INGRESSGATEWAY -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

## Uninstalling the Knative Serving Operator

1. Go to **Catalog > OperatorHub** in the OpenShift Web Console.

2. Click on the **Knative Serving Operator** tile.

![KSO Uninstall Tile](./images/knative_serving_uninstall_tile.png)

> **NOTE:** The operator tile will indicate it is installed.

3. The **Show Community Operator**` dialog box will appear. Click **Continue**
   to proceed.

4. Once the **Knative Serving Operator** descriptor screen appears, click
   **Uninstall**.

![KSO Uninstall](./images/knative_serving_uninstall_operator.png)

5. Select **Also completely remove the Operator from the selected namespace**,
   in the **Remove Operator Subscription** dialog box.

6. Click **Remove**.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
