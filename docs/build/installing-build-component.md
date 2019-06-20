---
title: "Installing the Knative Build component"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 10
type: "docs"
---

Before you can run a Knative Build, you must install the Knative Build component
in your Kubernetes cluster. Use this page to add the Knative Build component to
an existing Knative installation.

You have the option to install and use only the components of Knative that you
want, for example Knative serving is not required to create and run builds.

## Before you begin

You must have a component of Knative installed and running in your Kubernetes
cluster. For complete installation instructions, including how to install the
Knative Build component, see [Installing Knative](../install/README.md).

## Adding the Knative Build component

To add only the Knative Build component to an existing installation:

1. Run the
   [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)
   command to install [Knative Build](https://github.com/knative/build) and its
   dependencies:

   ```bash
   kubectl apply --filename https://github.com/knative/build/releases/download/v0.6.0/build.yaml
   ```

1. Run the
   [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get)
   command to monitor the Knative Build components until all of the components
   show a `STATUS` of `Running`:

   ```bash
   kubectl get pods --namespace knative-build
   ```

   Tip: Instead of running the `kubectl get` command multiple times, you can
   append the `--watch` flag to view the component's status updates in real
   time. Use CTRL + C to exit watch mode.

You are now ready to create and run Knative Builds, see
[Creating a simple Knative Build](./creating-builds.md) to get started.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
