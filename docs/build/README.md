A `Build` is a custom resource in Knative that allows you to define a process
that runs to completion and can provide status. For example, fetch, build, and
package your code by using a Knative `Build` that communicates whether the
process succeeds.

A Knative `Build` runs on-cluster and is implemented by a
[Kubernetes Custom Resource Definition (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).

Given a _builder_, or container image that you have created to perform a task or
action, you can define a Knative `Build` through a single configuration file.

## Key features of Knative Builds

- A `Build` can include multiple `steps` where each step specifies a `Builder`.
- A _builder_ is a type of container image that you create to accomplish any
  task, whether that's a single step in a process, or the whole process itself.
- The `steps` in a `Build` can push to a registry.
- A `BuildTemplate` can be used to define reusable templates.
- The `source` in a `Build` can be defined to mount data to a Kubernetes Volume,
  and supports:
  - `git` repositories
  - Google Cloud Storage
  - An arbitrary container image
- Authenticate with `ServiceAccount` using Kubernetes Secrets.

### Learn more

See the following reference topics for information about each of the build
components:

- [`Build`](./builds.md)
- [`BuildTemplate`](./build-templates.md)
- [`Builder`](./builder-contract.md)
- [`ServiceAccount`](./auth.md)

## Install the Knative Build component

Because all Knative components stand alone, you can decide which components to
install. Knative Serving is not required to create and run builds.

Before you can run a Knative Build, you must install the Knative Build component
in your Kubernetes cluster:

- For details about installing a new instance of Knative in your Kubernetes
  cluster, see [Installing Knative](../install/README.md).

- If you have a component of Knative installed and running, you can
  [add and install the Knative Build component](./installing-build-component.md).

## Configuration syntax example

Use the following example to understand the syntax and structure of the various
components of a Knative `Build`. Note that not all elements of a `Build`
configuration file are included in the following example but you can reference
the [Knative Build samples](#get-started-with-knative-build-samples) section
along with the [reference files](#learn-more) above for more information.

The following example demonstrates a build that uses authentication and includes
multiple `steps` and multiple repositories:

```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: example-build
spec:
  serviceAccountName: build-auth-example
  source:
    git:
      url: https://github.com/example/build-example.git
      revision: master
  steps:
    - name: ubuntu-example
      image: ubuntu
      args: ["ubuntu-build-example", "SECRETS-example.md"]
    - image: gcr.io/example-builders/build-example
      args: ["echo", "hello-example", "build"]
```

## Get started with Knative Build samples

[See Knative Build code samples](./samples.md)

## Related info

If you are interested in contributing to the Knative Build project, see the
[Knative Build code repository](https://github.com/knative/build).

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
