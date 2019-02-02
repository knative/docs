---
title: "Knative `Build` resources"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 5
---

Use the `Build` resource object to create and run on-cluster processes to
completion.

To create a build in Knative, you must define a configuration file, in which
specifies one or more container images that you have implemented to perform and
complete a task.

A build runs until all `steps` have completed or until a failure occurs.

---

- [Syntax](#syntax)
  - [Steps](#steps)
  - [Template](#template)
  - [Source](#source)
  - [Service Account](#service-account)
  - [Volumes](#volumes)
  - [Timeout](#timeout)
- [Examples](#examples)

---

### Syntax

To define a configuration file for a `Build` resource, you can specify the
following fields:

- Required:
  - [`apiVersion`][kubernetes-overview] - Specifies the API version, for example
    `build.knative.dev/v1alpha1`.
  - [`kind`][kubernetes-overview] - Specify the `Build` resource object.
  - [`metadata`][kubernetes-overview] - Specifies data to uniquely identify the
    `Build` resource object, for example a `name`.
  - [`spec`][kubernetes-overview] - Specifies the configuration information for
    your `Build` resource object. Build steps must be defined through either of
    the following fields:
    - [`steps`](#steps) - Specifies one or more container images that you want
      to run in your build.
    - [`template`](#template) - Specifies a reusable build template that
      includes one or more `steps`.
- Optional:
  - [`source`](#source) - Specifies a container image that provides information
    to your build.
  - [`serviceAccountName`](#service-account) - Specifies a `ServiceAccount`
    resource object that enables your build to run with the defined
    authentication information.
  - [`volumes`](#volumes) - Specifies one or more volumes that you want to make
    available to your build.
  - [`timeout`](#timeout) - Specifies timeout after which the build will fail.

[kubernetes-overview]:
  https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/#required-fields

The following example is a non-working sample where most of the possible
configuration fields are used:

```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: example-build-name
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
  steps:
  - image: gcr.io/example-builders/build-example
    args: ['echo', 'hello-example', 'build']
  steps:
  - name: dockerfile-pushexample
    image: gcr.io/example-builders/push-example
    args: ["push", "${IMAGE}"]
    volumeMounts:
    - name: docker-socket-example
      mountPath: /var/run/docker.sock
  volumes:
  - name: example-volume
    emptyDir: {}
```

#### Steps

The `steps` field is required if the `template` field is not defined. You define
one or more `steps` fields to define the body of a build.

Each `steps` in a build must specify a `Builder`, or type of container image
that adheres to the [Knative builder contract](../builder-contract/). For each
of the `steps` fields, or container images that you define:

- The `Builder`-type container images are run and evaluated in order, starting
  from the top of the configuration file.
- Each container image runs until completion or until the first failure is
  detected.

For details about how to ensure that you implement each step to align with the
"builder contract", see the [`Builder`](../builder-contract/) reference topic.

#### Template

The `template` field is a required if no `steps` are defined. Specifies a
[`BuildTemplate`](../build-templates/) resource object, in which includes
repeatable or sharable build `steps`.

For examples and more information about build templates, see the
[`BuildTemplate`](../build-templates/) reference topic.

#### Source

Optional. Specifies a container image. Use the `source` field to provide your
build with data or context that is needed by your build. The data is placed into
the `/workspace` directory within a mounted
[volume](https://kubernetes.io/docs/concepts/storage/volumes/) and is available
to all `steps` of your build.

The currently supported types of sources include:

- `git` - A Git based repository. Specify the `url` field to define the location
  of the container image. Specify a `revision` field to define a branch name,
  tag name, commit SHA, or any ref.
  [Learn more about revisions in Git](https://git-scm.com/docs/gitrevisions#_specifying_revisions).

- `gcs` - An archive that is located in Google Cloud Storage.

- `custom` - An arbitrary container image.

#### Service Account

Optional. Specifies the `name` of a `ServiceAccount` resource object. Use the
`serviceAccountName` field to run your build with the privileges of the
specified service account. If no `serviceAccountName` field is specified, your
build runs using the
[`default` service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server)
that is in the
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
of the `Build` resource object.

For examples and more information about specifying service accounts, see the
[`ServiceAccount`](../auth/) reference topic.

#### Volumes

Optional. Specifies one or more
[volumes](https://kubernetes.io/docs/concepts/storage/volumes/) that you want to
make available to your build, including all the build steps. Add volumes to
complement the volumes that are implicitly
[created during a build step](../builder-contract/).

For example, use volumes to accomplish one of the following common tasks:

- [Mount a Kubernetes secret](../auth/).

- Create an `emptyDir` volume to act as a cache for use across multiple build
  steps. Consider using a persistent volume for inter-build caching.

- Mount a host's Docker socket to use a `Dockerfile` for container image builds.

#### Timeout

Optional. Specifies timeout for the build. Includes time required for allocating
resources and execution of build.

- Defaults to 10 minutes.
- Refer to
  [Go's ParseDuration documentation](https://golang.org/pkg/time/#ParseDuration)
  for expected format.

### Examples

Use these code snippets to help you understand how to define your Knative
builds.

Tip: See the collection of simple
[test builds](https://github.com/knative/build/tree/master/test) for additional
code samples, including working copies of the following snippets:

- [`git` as `source`](#using-git)
- [`gcs` as `source`](#using-gcs)
- [`custom` as `source`](#using-custom)
- [Mounting extra volumes](#using-an-extra-volume)
- [Pushing an image](#using-steps-to-push-images)
- [Authenticating with `ServiceAccount`](#using-a-serviceaccount)
- [Timeout](#using-timeout)

#### Using `git`

Specifying `git` as your `source`:

```yaml
spec:
  source:
    git:
      url: https://github.com/knative/build.git
      revision: master
  steps:
    - image: ubuntu
      args: ["cat", "README.md"]
```

#### Using `gcs`

Specifying `gcs` as your `source`:

```yaml
spec:
  source:
    gcs:
      type: Archive
      location: gs://build-crd-tests/rules_docker-master.zip
  steps:
    - name: list-files
      image: ubuntu:latest
      args: ["ls"]
```

#### Using `custom`

Specifying `custom` as your `source`:

```yaml
spec:
  source:
    custom:
      image: gcr.io/cloud-builders/gsutil
      args: ["rsync", "gs://some-bucket", "."]
  steps:
    - image: ubuntu
      args: ["cat", "README.md"]
```

#### Using an extra volume

Mounting multiple volumes:

```yaml
spec:
  steps:
    - image: ubuntu
      entrypoint: ["bash"]
      args: ["-c", "curl https://foo.com > /var/my-volume"]
      volumeMounts:
        - name: my-volume
          mountPath: /var/my-volume

    - image: ubuntu
      args: ["cat", "/etc/my-volume"]
      volumeMounts:
        - name: my-volume
          mountPath: /etc/my-volume

  volumes:
    - name: my-volume
      emptyDir: {}
```

#### Using `steps` to push images

Defining a `steps` to push a container image to a repository.

```yaml
spec:
  parameters:
    - name: IMAGE
      description: The name of the image to push
    - name: DOCKERFILE
      description: Path to the Dockerfile to build.
      default: /workspace/Dockerfile
  steps:
    - name: build-and-push
      image: gcr.io/kaniko-project/executor
      args:
        - --dockerfile=${DOCKERFILE}
        - --destination=${IMAGE}
```

#### Using a `ServiceAccount`

Specifying a `ServiceAccount` to access a private `git` repository:

```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: test-build-with-serviceaccount-git-ssh
  labels:
    expect: succeeded
spec:
  serviceAccountName: test-build-robot-git-ssh
  source:
    git:
      url: git@github.com:knative/build.git
      revision: master

  steps:
    - name: config
      image: ubuntu
      command: ["/bin/bash"]
      args: ["-c", "cat README.md"]
```

Where `serviceAccountName: test-build-robot-git-ssh` references the following
`ServiceAccount`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-build-robot-git-ssh
secrets:
  - name: test-git-ssh
```

And `name: test-git-ssh`, references the following `Secret`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: test-git-ssh
  annotations:
    build.knative.dev/git-0: github.com
type: kubernetes.io/ssh-auth
data:
  # Generated by:
  # cat id_rsa | base64 -w 0
  ssh-privatekey: LS0tLS1CRUdJTiBSU0EgUFJJVk.....[example]
  # Generated by:
  # ssh-keyscan github.com | base64 -w 0
  known_hosts: Z2l0aHViLmNvbSBzc2g.....[example]
```

Note: For a working copy of this `ServiceAccount` example, see the
[build/test/git-ssh](https://github.com/knative/build/tree/master/test/git-ssh)
code sample.

#### Using `timeout`

Specifying `timeout` for your `build`:

```yaml
spec:
  timeout: 20m
  source:
    git:
      url: https://github.com/knative/build.git
      revision: master
  steps:
    - image: ubuntu
      args: ["cat", "README.md"]
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
