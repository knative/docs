# Docker preview

From the repository root:

```bash
./hack/docker/run.sh
```

Open <http://127.0.0.1:8000/docs/>, edit files, and save for live reload.
By default, only the working copy is built. Add `--all-versions` to include cached
releases from `config/versions.txt`; the working copy then lives at `/development/`.
During live reload, working edits reuse rendered release HTML and CSS/JS edits
only update assets. Shared dependencies and page-index changes trigger full
rebuilds. Python hooks are loaded in fresh renderer processes; failed builds keep
the last successful site available.
Press Ctrl+C to stop; the container is removed automatically. Only Docker is
required—no host Python or uv installation.

```bash
# Test the version selector with all configured releases
./hack/docker/run.sh --all-versions

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
