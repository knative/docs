# Knative Build

A `Build` is a custom resource in Knative that allows you to define an process that runs
to completion and can provide status. For example, fetch, build, and package your 
code by using a Knative `Build` that sends status messages like `Complete`  or  `Failed`.

A Knative `Build` runs on-cluster and is implemented by a 
[Kubernetes Custom Resource Definition (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).

Given a `Builder`, or container image that you have created to perform a task 
or action, you can define a Knative `Build` through a single configuration file.

Also consider using a Knative `Build` to build the source code of your apps into container images,
which you can then run on [Knative `serving`](https://github.com/knative/docs/blob/master/serving/README.md).
More information about this use case is demonstrated in 
[this sample](https://github.com/knative/docs/blob/master/serving/samples/source-to-url-go).

## Key features of Knative builds

* A `Build` can include multiple `steps` where each step specifies a `Builder`.
* A `Builder` is a container image that you create to accomplish any task, whether 
    that's a single step in a process, or the whole process itself.
* A `BuildTemplate` can be used to defined reusable templates.
* The  `source` in a  `Build` can be defined to mount data to a Kubernetes Volume.
* A `Build` can connect to:
     * `git` repositories
     * Google Cloud Storage
     * An arbitrary container image
* Authenticate with `ServiceAccount` using Kubernetes Secrets.

### Learn more 

See the following reference topics for information about each of the build components:

* [`Build`](https://github.com/knative/docs/blob/master/build/builds.md)
* [`BuildTemplate`](https://github.com/knative/docs/blob/master/build/build-templates.md)
* [ `Builder`](https://github.com/knative/docs/blob/master/build/builder-contract.md)
* [`ServiceAccount`](https://github.com/knative/docs/blob/master/build/auth.md)

## Configuration syntax example

Use the following example to understand the syntax and structure of the various components of a 
Knative `Build`. Note that not all elements of a `Build` configuration file are included in the following 
example but you can reference the [Knative build samples](#get-started-with-knative-build-samples) 
section along with the [reference files](#learn-more) above for more information.

The following example demonstrates a build that uses authentication and includes multiple `steps` and 
multiple repositories: 

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: example-build
spec:
serviceAccountName: build-auth-example
source:
  git:
    url: https://github.com/sample/build-sample.git
    revision: master
  steps:
  - name: ubuntu-example
    image: ubuntu
    args: ["ubuntu-build-example", "SECRETS.md"]
  steps:
  - image: gcr.io/sample-builders/build-sample
    args: ['echo', 'hello', 'build']
```


## Get started with Knative build samples

Use the following samples to learn how to configure your Knative builds to perform simple tasks.

Tip: Review and reference multiple samples to piece together more complex builds.

### Simple build samples

* [Collection of simple test builds](https://github.com/knative/build/tree/master/test).

### Build templates
 
 * [Repository of sample build templates](https://github.com/knative/build-templates).
 
 ### Complex samples
 
 * [Use Knative to build apps from source code and then run those containers](https://github.com/knative/docs/blob/master/serving/samples/source-to-url-go).
 
 
 ## Related info
 
 If you are interested in contributing to the Knative build project, see the
 [Knative Build code repository](https://github.com/knative/build).
