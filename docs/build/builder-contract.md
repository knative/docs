---
title: "Builders"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 15
---

This document defines builder images and the conventions to which they are
expected to adhere.

## What is a builder?

A builder image is a special classification for images that run as a part of the
Build CRD's `steps`.

For example, in the following Build the images, `gcr.io/cloud-builders/gcloud`
and `gcr.io/cloud-builders/docker` are "builders":

```yaml
spec:
  steps:
  - image: gcr.io/cloud-builders/gcloud
    ...
  - image: gcr.io/cloud-builders/docker
    ...
```

### Typical builders

A builder is typically a purpose-built container whose entrypoint is a tool that
performs some action and exits with a zero status on success. These entrypoints
are often command-line tools, for example, `git`, `docker`, `mvn`, and so on.

Typical builders set their `command:` (aka `ENTRYPOINT`) to be the command they
wrap and expect to take `args:` to direct their behavior.

See [here](https://github.com/googlecloudplatform/cloud-builders) and
[here](https://github.com/googlecloudplatform/cloud-builders-community) for more
builders.

### Atypical builders

It it possible, although less typical to implement the builder convention by
overriding `command:` and `args:` for example:

```yaml
steps:
  - image: ubuntu
    command: ["/bin/bash"]
    args: ["-c", "echo hello $FOO"]
    env:
      - name: "FOO"
        value: "world"
```

### Specialized builders

It is also possible for advanced users to create purpose-built builders. One
example of this are the
["FTL" builders](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/ftl#ftl).

## What are the builder conventions?

Builders should expect a Build to implement the following conventions:

- `/workspace`: The default working directory will be `/workspace`, which is a
  volume that is filled by the `source:` step and shared across build `steps:`.

- `/builder/home`: This volume is exposed to steps via `$HOME`.

- Credentials attached to the Build's service account may be exposed as Git or
  Docker credentials as outlined [here](../auth/).

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
