# Docker preview

From the repository root:

```bash
./hack/docker/run.sh
```

Open <http://127.0.0.1:8000/docs/>, edit files, and save for live reload.
Press Ctrl+C to stop; the container is removed automatically. Only Docker is
required—no host Python or uv installation.

```bash
# Another host port
PORT=8001 ./hack/docker/run.sh

# Local build check (output: site/)
./hack/docker/run.sh build --strict

# Optional full release build (export GITHUB_TOKEN first)
./hack/docker/run.sh release
```

The script builds `knative-docs:local` for your architecture and uses uv to install
`uv.lock`. Docker caches unchanged dependencies in the image at `/opt/venv`,
separate from your host's `.venv/`. Set `IMAGE` to choose another local build tag.

For more details, see the
[local preview guide](../../contribute-to-docs/getting-started/previewing-docs-locally.md#alternative-docker).

## Publishing the image

GitHub Actions builds and publishes the image directly using
`.github/workflows/knative-docs-image.yaml` and this directory's `Dockerfile`.
It does not depend on `build-image.sh`.

`./hack/docker/build-image.sh` is retained for manual ARM64/AMD64 publishing to
`ghcr.io/knative/knative-docs:latest`. It requires registry credentials and a
multi-platform Buildx builder, and **pushes** the image. Use `run.sh` for local
preview instead.
