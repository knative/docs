---
audience: developer
components:
  - functions
function: how-to
hide_prev: true
hide_next: true
---

# Build an image

Build an OCI container image from an existing function project without running,
pushing, or deploying it. If you want to build **and deploy** in one step
(locally or on a cluster with Tekton), see [Deploy a function](deploying-functions.md).

## Requirements

- An initialized function project containing `func.yaml` and source code.
  [Create a project](running-functions.md#create-a-project) if needed.
- A running [Docker](https://docs.docker.com/get-started/get-docker/) engine
  for containerized builders (`pack` or `s2i`).
- Run commands from inside the function project directory.

<span id="local-builds"></span>

## Build

Pass an explicit local image name so the build does not prompt for a registry:

=== "func"

    ```bash
    func build --builder pack \
      --image localhost/my-function:latest
    ```

=== "kn func"

    ```bash
    kn func build --builder pack \
      --image localhost/my-function:latest
    ```

`localhost/my-function:latest` is a local tag — nothing is pushed to a registry
or deployed to a cluster. To prepare an image for a registry, pass
`--registry <registry>` (for example `ghcr.io/alice` or `docker.io/alice`) or
set `FUNC_REGISTRY`.

## Verify the image

Confirm the image exists in Docker:

```bash
docker image ls localhost/my-function:latest
```

A row with tag `latest` and an image ID confirms the build succeeded. This does
not push or start the container.

<span id="on-cluster-builds"></span>

## Other builders

`func build` supports `--builder pack` (Cloud Native Buildpacks), `--builder s2i`
(Source-to-Image), and `--builder host` (host-native builds for supported
languages). For remote on-cluster builds with Tekton, see
[Deploy a function — Build and deploy remotely](deploying-functions.md#build-and-deploy-remotely).
For all flags and builder options, see the
[`func build` reference](https://github.com/knative/func/blob/main/docs/reference/func_build.md){target=_blank}.
