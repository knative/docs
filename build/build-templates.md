# Build Templates

This document defines "Build Templates" and their capabilities.

A set of curated and supported build templates is available in the
[`build-templates`](https://github.com/knative/build-templates) repo.

## What is a Build Template?

A `BuildTemplate` encapsulates a shareable [build](./builds.md)
process with some limited parameterization capabilities.

### Example template

For example, a `BuildTemplate` to encapsulate a `Dockerfile` build might look
something like this:

**Note:** Building a container image using `docker build` on-cluster is _very
unsafe_. Use [kaniko](https://github.com/GoogleContainerTools/kaniko) instead.
This is used only for the purposes of demonstration.

```yaml
spec:
  parameters:
  # This has no default, and is therefore required.
  - name: IMAGE
    description: Where to publish the resulting image.

  # These may be overridden, but provide sensible defaults.
  - name: DIRECTORY
    description: The directory containing the build context.
    default: /workspace
  - name: DOCKERFILE_NAME
    description: The name of the Dockerfile
    default: Dockerfile

  steps:
  - name: dockerfile-build
    image: gcr.io/cloud-builders/docker
    workingdir: "${DIRECTORY}"
    args: ["build", "--no-cache",
           "--tag", "${IMAGE}",
           "--file", "${DOCKERFILE_NAME}"
           "."]
    volumeMounts:
    - name: docker-socket
      mountPath: /var/run/docker.sock

  - name: dockerfile-push
    image: gcr.io/cloud-builders/docker
    args: ["push", "${IMAGE}"]
    volumeMounts:
    - name: docker-socket
      mountPath: /var/run/docker.sock

  # As an implementation detail, this template mounts the host's daemon socket.
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
      type: Socket
```

In this example, `parameters` describes the formal arguments for the template.
The `description` is used for diagnostic messages during validation (and maybe
in the future for UI). The `default` value enables a template to have a
graduated complexity, where options are overridden only when the user strays
from some set of sane defaults.

The `steps` and `volumes` parameters are just like in a [`Build`](./builds.md)
resource, but might contain references to parameters in the form:
`${PARAMETER_NAME}`.

The `steps` of a template replace those of its Build. The `volumes` of a
template augment those of its Build.

### Example Builds

For the sake of illustrating re-use, here are several example Builds
instantiating the `BuildTemplate` above (`dockerfile-build-and-push`).

Build `mchmarny/rester-tester`:
```yaml
spec:
  source:
    git:
      url: https://github.com/mchmarny/rester-tester.git
      revision: master
  template:
    name: dockerfile-build-and-push
    arguments:
    - name: IMAGE
      value: gcr.io/my-project/rester-tester
```

Build `googlecloudplatform/cloud-builder`'s `wget` builder:
```yaml
spec:
  source:
    git:
      url: https://github.com/googlecloudplatform/cloud-builders.git
      revision: master
  template:
    name: dockerfile-build-and-push
    arguments:
    - name: IMAGE
      value: gcr.io/my-project/wget
    # Optional override to specify the subdirectory containing the Dockerfile
    - name: DIRECTORY
      value: /workspace/wget
```

Build `googlecloudplatform/cloud-builder`'s `docker` builder with `17.06.1`:
```yaml
spec:
  source:
    git:
      url: https://github.com/googlecloudplatform/cloud-builders.git
      revision: master
  template:
    name: dockerfile-build-and-push
    arguments:
    - name: IMAGE
      value: gcr.io/my-project/docker
    # Optional overrides
    - name: DIRECTORY
      value: /workspace/docker
    - name: DOCKERFILE_NAME
      value: Dockerfile-17.06.1
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
