# Knative Build

A `build` is a custom resource in Knative that allows you to define an
process that runs to completion and provides status, for example `Complete`  or  `Failed`.

A Knative `build` is an implementation of a 
[Kubernetes Custom Resource Definition (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that runs on-cluster.

Given a `builder` or container image that you have created to perform a task 
or action, you can define a Knative `build` through a single configuration file.

## Key features of Knative builds

* A `build-template` can be used to defined to reusable templates.
* A `build` can include multiple `steps` where each step specifies a `builder`.
* A `builder` is a container image that you create to acomplish any task, whether 
    that's a single step in a process, or the whole process itself.
* Each `builder` can reside in different repositories.
* A `source` can be defined to mount data to a Kubernetes Volume.
* A `build` can connect to:
     * `git` repositories
     * Google Container Registry
     * Google Cloud Storage
     * Directly to arbitrary container images
* Uses Kubernetes Secrets for authentication.


### Simple `build` configuration example

The follow example is a configuration file for a build that includes multiple steps and uses multiple repositories: 

    apiVersion: build.knative.dev/v1alpha1
    kind: Build
    metadata:
      name: hello-build
    spec:
    serviceAccountName: build-sample
    source:
      git:
        url: https://github.com/sample/build-sample.git
        revision: master
      steps:
      - name: hello-ubuntu
        image: ubuntu
        args: ["hello", "SECRETS.md"]
      steps:
      - image: gcr.io/sample-builders/build-sample
        args: ['echo', 'hello', 'build']


### Learn more 

See the following reference topics for more inforamation about the components of a Knative build:

* [Builds](https://github.com/knative/docs/blob/master/build/builds.md)
* [Build Templates](https://github.com/knative/docs/blob/master/build/build-templates.md)
* [Builders](https://github.com/knative/docs/blob/master/build/builder-contract.md)
* [Authentication](https://github.com/knative/docs/blob/master/build/auth.md)


## Sample Knative build

 * [app-from-source](../serving/samples/source-to-url-go) sample
