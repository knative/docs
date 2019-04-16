---
title: "Creating a simple Knative build"
linkTitle: "Creating a build"
weight: 30
type: "docs"
---

Use this page to learn how to create and then run a simple build in Knative. In
this topic, you create a Knative Build configuration file for a simple app,
deploy that build to Knative, and then test that the build completes.

The following demonstrates the process of deploying and then testing that the
build completed successfully. This sample build uses a hello-world-type app that
uses [busybox](https://docs.docker.com/samples/library/busybox/) to simply print
"_hello build_".

Tip: See the
[build code samples](./builds.md#get-started-with-knative-build-samples) for
examples of more complex builds, including code samples that use container
images, authentication, and include multiple steps.

## Before you begin

Before you can run a Knative Build, you must have Knative installed in your
Kubernetes cluster, and it must include the Knative Build component:

- For details about installing a new instance of Knative in your Kubernetes
  cluster, see [Installing Knative](../install/README.md).

- If you have a component of Knative installed and running, you must
  [ensure that the Knative Build component is also installed](./installing-build-component.md).

## Creating and running a build

1. Create a configuration file named `build.yaml` that includes the following
   code.

   This `Build` resource definition includes a single
   "[step](./builds.md#steps)" that performs the task of simply printing "_hello
   build_":

   ```yaml
   apiVersion: build.knative.dev/v1alpha1
   kind: Build
   metadata:
     name: hello-build
   spec:
     steps:
       - name: hello
         image: busybox
         args: ["echo", "hello", "build"]
   ```

   Notice that this definition specifies `kind` as a `Build`, and that the name
   of this `Build` resource is `hello-build`. For more information about
   defining build configuration files, See the
   [`Build` reference topic](./builds.md).

1. Deploy the `build.yaml` configuration file and run the `hello-build` build on
   Knative by running the
   [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)
   command:

   ```shell
   kubectl apply --filename build.yaml
   ```

   Response:

   ```shell
   build "hello-build" created
   ```

1. Verify that the `hello-build` build resource has been created by running the
   [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get)
   command:

   ```shell
   kubectl get builds
   ```

   Response:

   ```shell
   NAME          AGE
   hello-build   4s
   ```

1. After the build is created, you can run the following
   [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get)
   command to retrieve details about the `hello-build` build, specifically, in
   which cluster and pod the build is running:

   ```shell
   kubectl get build hello-build --output yaml
   ```

   Response:

   ```shell
   apiVersion: build.knative.dev/v1alpha1
   kind: Build

   ...

   status:
     builder: Cluster
     cluster:
       namespace: default
       podName: hello-build-jx4ql
     conditions:
     - state: Complete
       status: "True"
     stepStates:
     - terminated:
         reason: Completed
     - terminated:
         reason: Completed
   ```

   Notice that the values of `completed` indicate that the build was successful,
   and that `hello-build-jx4ql` is the pod where the build ran.

   Tip: You can also retrieve the `podName` by running the following command:

   ```shell
   kubectl get build hello-build --output jsonpath={.status.cluster.podName}
   ```

1. Optional: Run the following
   [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get)
   command to retrieve details about the `hello-build-[ID]` pod, including the
   name of the
   [Init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/):

   ```shell
   kubectl get pod hello-build-[ID] --output yaml
   ```

   where `[ID]` is the suffix of your pod name, for example `hello-build-jx4ql`.

   The response of this command includes a lot of detail, as well as the
   `build-step-hello` name of the Init container.

   Tip: The name of the Init container is determined by the `name` that is
   specified in the `steps` field of the build configuration file, for example
   `build-step-[ID]`.

1. To verify that your build performed the single task of printing "_hello
   build_", you can run the
   [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs)
   command to retrieve the log files from the `build-step-hello` Init container
   in the `hello-build-[ID]` pod:

   ```shell
   kubectl logs $(kubectl get build hello-build --output jsonpath={.status.cluster.podName}) --container build-step-hello
   ```

   Response:

   ```shell
   hello build
   ```

### Learn more

To learn more about the objects and commands used in this topic, see:

- [Knative `Build` resources](./builds.md)
- [Kubernetes Init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Kubernetes kubectl CLI](https://kubernetes.io/docs/reference/kubectl/kubectl/)

For information about contributing to the Knative Build project, see the
[Knative Build code repo](https://github.com/knative/build/).

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
