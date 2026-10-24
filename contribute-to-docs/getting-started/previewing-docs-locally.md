# Previewing the website locally

The Knative website uses [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).
For everyday edits, preview just your checkout instead of assembling every
published release. You don't need a Kubernetes cluster, Node.js, a GitHub token,
or release branches.

## Quick start: uv

Install [uv](https://docs.astral.sh/uv/getting-started/installation/), then run
this command from a clone of this repository:

```bash
./hack/mkdocs.sh
```

uv selects Python 3.13 (from `.python-version`), downloads it if necessary,
creates `.venv/`, and installs the exact dependencies from `uv.lock`. The first
run requires internet access. Later runs reuse the environment and check that it
matches the lockfile. You don't need to install Python manually, activate the
environment, or install packages globally.

Open <http://127.0.0.1:8000/docs/>. Edit Markdown under `docs/`, save, and the
browser reloads automatically. Press **Ctrl+C** to stop.

### Where to edit

- Knative documentation: `docs/versioned/`
- Documentation navigation: `docs/versioned/.nav.yml`
- Shared snippets: `docs/snippets/`
- Blog, community, and about pages: their respective directories under `docs/`
- Website templates and styles: `overrides/` and `docs/stylesheets/`

The preview serves `docs/versioned/` at `/docs/`, so the homepage and Docs header
links work as they do on the published website. It reads your working files
directly; there is no copy step between editing and previewing.

### Useful commands

```bash
# Use another port
./hack/mkdocs.sh serve --dev-addr 127.0.0.1:8001

# Faster reloads for edits to a single existing page
./hack/mkdocs.sh serve --dirtyreload

# Build this checkout without starting a server (output: site/)
./hack/mkdocs.sh build

# Treat build warnings as errors
./hack/mkdocs.sh build --strict

# Sync the environment to the committed lockfile
./hack/mkdocs.sh setup
```

Use normal reloads when adding/deleting pages or changing navigation, snippets,
or templates: `--dirtyreload` can leave other pages stale.

The helper is just a shortcut for uv. You can also run commands directly:

```bash
uv run --locked mkdocs serve --livereload --config-file mkdocs.local.yml
```

### Updating dependencies

`pyproject.toml` declares dependencies; `uv.lock` pins the resolved versions.
Local previews, Docker, CI, and Netlify install directly from `uv.lock`; no
`requirements.txt` export is needed.

After changing dependencies in `pyproject.toml`, run:

```bash
uv lock
./hack/mkdocs.sh build --strict
```

To update all packages within their declared constraints, use `uv lock --upgrade`
instead of `uv lock`. Commit `pyproject.toml` and `uv.lock` together when changing
dependency declarations. Preview and hosted build commands use `--locked` so a
stale lockfile fails rather than silently choosing new versions.

### Updating uv

The `tools` dependency group in `pyproject.toml` pins the uv used by CI, Netlify,
and Docker; each reads the locked version from `uv.lock`. Dependabot updates it
like any other dependency. To upgrade manually, change the pin and run `uv lock`.

`required-version` sets the minimum uv for local builds. Newer versions work.

### Troubleshooting

- **Port already in use:** choose another port with `--dev-addr` as shown above.
- **Python environment no longer works after a Python upgrade:** remove the
  generated `.venv/` directory and rerun `./hack/mkdocs.sh`.
- **uv is missing or too old:** follow the
  [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/)
  and install at least the version in `required-version` in `pyproject.toml`.
- **The lockfile is stale:** if you changed `pyproject.toml`, follow the dependency
  update steps above. Otherwise, make sure you checked out the matching `uv.lock`.
- **Python download fails:** check network access, or install Python 3.13 yourself;
  uv can use a compatible interpreter already on your machine.
- **Unexpected versioned artifact links or GitHub API errors:** unset
  `KNATIVE_VERSION` for the normal development preview. By default, artifact
  macros link to nightly downloads without querying GitHub releases.

## Alternative: Docker

If you prefer not to install uv or manage a host environment, use a
Docker-compatible engine such as
[Docker Desktop](https://www.docker.com/products/docker-desktop) or
[colima](https://github.com/abiosoft/colima). Only the Docker CLI is required.

From the repository root:

```bash
./hack/docker/run.sh
```

Open <http://127.0.0.1:8000/docs/>. Your checkout is mounted into the container
and changes reload automatically. Press **Ctrl+C** to stop; the container is
removed automatically.

The script builds locally for your machine's architecture and installs dependencies
directly from `uv.lock`. It doesn't depend on a published Knative image, host
Python, or host uv. Container dependencies live in `/opt/venv`, separate from your
host's `.venv/`. Source edits reload immediately. Each launch checks the image
build, reusing Docker's cached layers when dependencies haven't changed.

```bash
# Choose another host port
PORT=8001 ./hack/docker/run.sh

# Faster reloads for a single existing page
./hack/docker/run.sh serve --dirtyreload

# Check the checkout without starting a server (output: site/)
./hack/docker/run.sh build --strict
```

The default local image tag is `knative-docs:local`. Set `IMAGE` to choose a
different local build tag; the script never pushes it.

## Local preview versus a full release build

The local preview builds the current checkout only, with no version selector.
It uses the API reference files already in the repository and development/nightly
artifact links. It does not fetch API references or published release branches.
After dependencies are installed, the preview build needs no network access;
external links and browser-loaded resources may still require internet access.

Production configuration is still `mkdocs.yml`. To test release assembly, including
older versions and freshly downloaded API references, use:

```bash
# First export GITHUB_TOKEN in your shell, then:
./hack/docker/run.sh release
```

That separate workflow requires Docker, network access, and a `GITHUB_TOKEN`
[personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
It writes the complete static site to `site/`. To serve that output with Python:

```bash
python3 -m http.server 8000 --directory site
```

When you submit a pull request, a hosted preview link is also posted on the PR.
